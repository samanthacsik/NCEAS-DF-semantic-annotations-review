# title: batch update of datapackages with semantic annotations (workflow currently for standalone packages only)
# author: "Sam Csik"
# date created: "2021-01-04"
# date edited: "2021-02-18"
# R version: 3.6.3
# input: "code/10b_batch_update_setup.R"
# output: no output, but publishes updates to arcticdata.io 

##########################################################################################
# Summary - READ BEFORE RUNNING
##########################################################################################

# This is still a work in progress!

# attributes to annotate are found in the following csv file: "data/outputs/attributes_to_annotate/all_attributes_to_annotate_sorted_by_pkgType_2020-01-19.csv"; some minor processing is done in script `10a_batch_update_setup.R`, which is sourced below

# README please
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

# load data/setup
source(here::here("code", "10a_batch_update_setup.R"))

# load functions
source(here::here("code", "batchUpdate_functions", "get_datapackage_metadata().R"))
source(here::here("code", "batchUpdate_functions", "get_eml_version().R"))
source(here::here("code", "batchUpdate_functions", "download_datapackage().R"))
source(here::here("code", "batchUpdate_functions", "get_entities().R"))
source(here::here("code", "batchUpdate_functions", "build_attributeID().R"))
source(here::here("code", "batchUpdate_functions", "verify_attributeID_isUnique().R"))
source(here::here("code", "batchUpdate_functions", "process_results().R"))
source(here::here("code", "batchUpdate_functions", "annotate_attributes().R"))
source(here::here("code", "batchUpdate_functions", "annotate_single_dataTable_multiple_attributes().R"))
source(here::here("code", "batchUpdate_functions", "annotate_multiple_dataTables_multiple_attributes().R"))
source(here::here("code", "batchUpdate_functions", "annotate_single_dataTable_single_attribute().R"))
source(here::here("code", "batchUpdate_functions", "annotate_multiple_dataTables_single_attribute().R"))
source(here::here("code", "batchUpdate_functions", "annotate_single_otherEntity_multiple_attributes().R"))
source(here::here("code", "batchUpdate_functions", "annotate_multiple_otherEntities_multiple_attributes().R"))
source(here::here("code", "batchUpdate_functions", "annotate_single_otherEntity_single_attribute().R"))
source(here::here("code", "batchUpdate_functions", "annotate_multiple_otherEntities_single_attribute().R"))
source(here::here("code", "batchUpdate_functions", "process_entities_by_type().R"))

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

# ----------------- get metadata/info for a particular datapackage -----------------

tryLog(for(dp_num in 1:length(unique_datapackage_ids)){
  
  # download datapackage & parse
  outputs <- download_datapackage(dp_num, unique_datapackage_ids, attributes)
  doc <- outputs[[1]]
  current_datapackage_subset <- outputs[[2]]
  current_datapackage_id <- outputs[[3]]
  
  # report how many dataTables and otherEntities are present in the current datapackage (informational only)
  get_entities(doc)
  
  # ----------------- get a dataTables and/or otherEntities from metadata; find matching data in df & annotate attributes -----------------
  
  has_dataTables <- isFALSE(is.null(doc$dataset$dataTable))
  message("Has dataTables: ", has_dataTables)
  has_otherEntities <- isFALSE(is.null(doc$dataset$otherEntity))
  message("Has otherEntities: ", has_otherEntities)
  message("*****************************************************")
  
  # process any dataTables
  if(has_dataTables){
    doc <- process_entities_by_type(doc, "dataTable", doc$dataset$dataTable)
  } 
  
  # process any otherEntities
  if(has_otherEntities){
    doc <- process_entities_by_type(doc, "otherEntity", doc$dataset$otherEntity)
  }
  
  # ----------------- add modified doc to list so that it can be manually reviewed (if necessary) -----------------
  
  # add modified 'doc' to list for storage
  list_of_docs_to_publish_update[[dp_num]] <- doc
  names(list_of_docs_to_publish_update)[[dp_num]] <- current_datapackage_id
  message("-------------- doc ", dp_num, " (", current_datapackage_id, ") has been added to the list --------------")
  
}, write.error.dump.file = TRUE, write.error.dump.folder = "dump_files", include.full.call.stack = FALSE) 













# some space to breathe...






























##########################################################################################
# validate docs and publish updates to arctic.io -- DOES NOT WORK YET
##########################################################################################

# tryLog(for(doc_num in 1:length(list_of_docs_to_publish_update)){
#   
#   # ----------------- validate doc -----------------
#   
#   # validate doc 
#   message("validating eml.....")
#   current_doc <- list_of_docs_to_publish_update[[doc_num]]
#   validated <- eml_validate(current_doc)
#   message("-------------- doc ",  doc_num," passes validation -> ",  validated[1], " --------------")
#   
#   # get metadata pid for current datapackage
#   current_metadata_pid <- current_doc$packageId
#   
#   # generate new pid (either doi or uuid depending on what the original had) for metadata 
#   if(isTRUE(str_detect(current_metadata_pid, "(?i)doi"))) {
#     new_id <- dataone::generateIdentifier(d1c_prod@mn, "DOI")
#     message("Generating a new metadata DOI: ", new_id)
#   } else if(isTRUE(str_detect(current_metadata_pid, "(?i)urn:uuid"))) {
#     new_id <- dataone::generateIdentifier(d1c_prod@mn, "UUID")
#     message("Generating a new metadata uuid: ", new_id)
#   } else {
#     warning("The original metadata ID format, ", current_metadata_pid, " is not recognized. No new ID has been generated.") # not sure yet what to do if this ever happens
#   }
#   
#   # write eml path -- UPDATE WITH NEW FILE PATH FOR EACH RUN
#   eml_path <- paste("/Users/samanthacsik/Repositories/NCEAS-DF-semantic-annotations-review/eml/run1_test/datapackage", doc_num, ".xml", sep = "") 
#   
#   # write eml
#   write_eml(current_doc, eml_path) 
#   
#   # ----------------- publish update -----------------
#   
#   # 6.1) get current_pkg from list based on index that matched doc_num -- NEED TO BUILD THIS IN A WAY TO PREVENT ERRORS 
#   current_pkg <- list_of_pkgs_to_publish_update[[doc_num]]
#   
#   # 6.1) replace original metadata pid with new pid
#   dp <- replaceMember(current_pkg, current_metadata_pid, replacement = eml_path, newId = new_id)
#   
#   # 6.2)  datapackage
#   newPackageId <- uploadDataPackage(d1c_test, dp, public = FALSE, quiet = FALSE)
#   message("--------------Datapackage ", doc_num, " has been updated!--------------")
#   
# })


















