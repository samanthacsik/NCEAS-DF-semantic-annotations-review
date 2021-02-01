# title: batch update of datapackages with semantic annotations (workflow currently for standalone packages only)
# author: "Sam Csik"
# date created: "2021-01-04"
# date edited: "2021-01-27"
# R version: 3.6.3
# input: "code/10b_batch_update_setup.R"
# output: no output, but publishes updates to arcticdata.io 

##########################################################################################
# Summary - READ BEFORE RUNNING
##########################################################################################

# README
  # Things to do prior to running an update:
    # check over script '10b_batch_update_setup.R' to ensure that you're working with the correct subset of data
    # be sure to assign data subset to an object called 'attributes' 
    # update file path for writing eml for each update run in section 5.3; eml/run#_pkgType (e.g. run1_standaloneDOI)
  # After running an update: 
    # add datasets updated to google sheet: 
      # https://docs.google.com/spreadsheets/d/1J4xE4FFWMQYSoEY9qq98kbBsvAxLyMU2WLCueIqaf0s/edit?usp=sharing

##########################################################################################
# General Setup
##########################################################################################

# load functions
source(here::here("code", "functions", "get_datapackage_metadata().R"))
source(here::here("code", "functions", "get_eml_version().R"))
source(here::here("code", "functions", "download_datapackage().R"))
source(here::here("code", "functions", "get_entities().R"))
source(here::here("code", "functions", "build_attribute_id().R"))
source(here::here("code", "functions", "verify_attribute_id_isUnique().R"))
source(here::here("code", "functions", "get_result().R"))
source(here::here("code", "functions", "process_results().R"))
source(here::here("code", "functions", "annotate_attributes().R"))
source(here::here("code", "functions", "process_entities_and_annotate().R"))
source(here::here("code", "functions", "process_dT_and_oE_and_annotate().R"))

# load data/setup
source(here::here("code", "10a_batch_update_setup.R"))

##########################################################################################
# update eml documents with semantic annotations
##########################################################################################

##############################
# get vector of all unique datapackages
##############################

unique_datapackage_ids <- unique(attributes$identifier)

##############################
# annotate datapackages -- CURRENTLY WRAPPING WHOLE LOOP IN TRYLOG() BUT NOT SURE IF THIS IS THE WAY TO GO JUST YET
##############################

list_of_docs_to_publish_update <- list()
list_of_pkgs_to_publish_update <- list()

# ----------------------- 1) get metadata/info for a particular datapackage -----------------------

tryLog(for(dp_num in 1:length(unique_datapackage_ids)){
  
  # 1.1) download datapackage
  outputs <- download_datapackage(dp_num, unique_datapackage_ids, attributes)
  doc <- outputs[[1]]
  current_datapackage_subset <- outputs[[2]]
  current_datapackage_id <- outputs[[3]]
  
  # 1.2) extract dataTables and otherEntities
  all_entities <- get_entities(doc)
  
  # create new list of dataTables
  # create new list of otherEntities
  
  # iterate over dataTables, process them
  # iterate over otherEntities, process them
  
  # ----------------------- 2) get a dataTables and/or otherEntities from metadata; 3) find matching data in df & annotate attributes -----------------------
  
  # for pkgs that have both dataTables & otherEntities
  if(isTRUE(length(all_entities) == 2)){
    message("Processing both dataTables & otherEntities")
    # doc <- process_dT_and_oE_and_annotate()
    
    # for pkgs with just dataTables 
  } else if(isTRUE(names(all_entities) == "dataTables")){
    entity_path <- doc$dataset$dataTable
    all_entities_path <- all_entities$dataTables
    doc <- process_entities_and_annotate(all_entities)
    
    # for pkgs with just otherEntities 
  } else if(isTRUE(names(all_entities) == "otherEntities")){
    entity_path <- doc$dataset$otherEntity
    all_entities_path <- all_entities$otherEntities
    doc <- process_entities_and_annotate(all_entities)
  }
  
  # ----------------------- 4) add modified doc to list so that it can be manually reviewed (if necessary) -----------------------
  
  # 4.1) add modified pkg 'doc' to list for storage
  list_of_docs_to_publish_update[[dp_num]] <- doc
  message("-------------- doc ", dp_num, " (", current_datapackage_id, ") has been added to the list --------------")
  
}, write.error.dump.file = TRUE, write.error.dump.folder = "dump_files", include.full.call.stack = FALSE) 












# some space to breathe...






























##########################################################################################
# validate docs and publish updates to arctic.io
##########################################################################################

tryLog(for(doc_num in 1:length(list_of_docs_to_publish_update)){
  
  # ----------------------- 5) validate doc -----------------------
  
  # 5.1) validate doc 
  message("validating eml.....")
  current_doc <- list_of_docs_to_publish_update[[doc_num]]
  validated <- eml_validate(current_doc)
  message("-------------- doc ",  doc_num," passes validation -> ",  validated[1], " --------------")
  
  # 5.2) get metadata pid for current datapackage
  current_metadata_pid <- current_doc$packageId
  
  # 5.2) generate new pid (either doi or uuid depending on what the original had) for metadata 
  if(isTRUE(str_detect(current_metadata_pid, "(?i)doi"))) {
    new_id <- dataone::generateIdentifier(d1c_test@mn, "DOI")
    message("Generating a new metadata DOI: ", new_id)
  } else if(isTRUE(str_detect(current_metadata_pid, "(?i)urn:uuid"))) {
    new_id <- dataone::generateIdentifier(d1c_test@mn, "UUID")
    message("Generating a new metadata uuid: ", new_id)
  } else {
    warning("The original metadata ID format, ", current_metadata_pid, " is not recognized. No new ID has been generated.") # not sure yet what to do if this ever happens
  }
  
  # 5.3) write eml path -- UPDATE WITH NEW FILE PATH FOR EACH RUN
  eml_path <- paste("/Users/samanthacsik/Repositories/NCEAS-DF-semantic-annotations-review/eml/run1_test/datapackage", doc_num, ".xml", sep = "") 
  
  # 5.4) write eml
  write_eml(current_doc, eml_path) # save your metadata
  
  # ----------------------- 6) publish update -----------------------
  
  # 6.1) get current_pkg from list based on index that matched doc_num -- NEED TO BUILD THIS IN A WAY TO PREVENT ERRORS 
  current_pkg <- list_of_pkgs_to_publish_update[[doc_num]]
  
  # 6.1) replace original metadata pid with new pid
  dp <- replaceMember(current_pkg, current_metadata_pid, replacement = eml_path, newId = new_id)
  
  # 6.2)  datapackage
  newPackageId <- uploadDataPackage(d1c_test, dp, public = FALSE, quiet = FALSE)
  message("--------------Datapackage ", doc_num, " has been updated!--------------")
  
})


















