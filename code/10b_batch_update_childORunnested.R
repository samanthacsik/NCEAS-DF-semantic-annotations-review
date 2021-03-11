# title: batch update of datapackages with semantic annotations (workflow currently for standalone packages only)
# author: "Sam Csik"
# date created: "2021-01-04"
# date edited: "2021-03-09"
# R version: 3.6.3
# input: "code/10b_batch_update_setup.R"
# output: no output, but publishes updates to arcticdata.io 

##########################################################################################
# Summary - READ BEFORE RUNNING
##########################################################################################

# Where can I find a list of attributes that need to be annotated?
  # data/outputs/attributes_to_annotate/all_attributes_to_annotate_sorted_by_pkgType_2020-01-19.csv

# Things to do prior to running an update:
  # check over script '10b_batch_update_setup.R' to ensure that you're working with the correct subset of data
  # be sure to assign data subset to an object called 'attributes' 
  # update file path for writing eml for each update run in section 5.3; eml/run#_pkgType (e.g. run1_standaloneDOI)

# After running an update: 
    # add any updated packages to this google sheet (for tracking purposes): 
      # https://docs.google.com/spreadsheets/d/1J4xE4FFWMQYSoEY9qq98kbBsvAxLyMU2WLCueIqaf0s/edit?usp=sharing

##########################################################################################
# Things to Consider
##########################################################################################

# Is there a way to avoid downloading all package objects and just downloading xlm file? massive packages take FOREVER

# NOTES:
  # doi shoulder -- e.g. 10.##; probably fine
  # be sure to let data team know about minting new DOIs or UUIDs
  # parent signifies what its children are (look at datapack); start with leaf node child pkg, update first, then update parent; parent rm points to child rm by identifier
  # arcticdatautils has some code for inspiration (publish_update())
  # Convert to package; benefit of R package is keeping things clean; write tests

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
source(here::here("code", "batchUpdate_functions", "annotate_attributes_packedEntity().R"))
source(here::here("code", "batchUpdate_functions", "annotate_attributes_unpackedEntity().R"))
source(here::here("code", "batchUpdate_functions", "annotate_eml_attributes().R"))
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
# STEP 1: update eml documents with semantic annotations
##########################################################################################

##############################
# get vector of all unique datapackages
##############################

unique_datapackage_ids <- unique(attributes$identifier)

##############################
# annotate datapackages -- CURRENTLY WRAPPING WHOLE LOOP IN TRYLOG() BUT NOT SURE IF THIS IS THE WAY TO GO JUST YET
##############################

list_of_pkgs_to_publish_update <- list() # packages that will be updated (needed for 2nd for loop)
list_of_docs_to_publish_update <- list() # modified docs that passed validation
list_of_pkgs_failed_INITIAL_validation <- list() # packages that failed initial validation (before modifications)
list_of_pkgs_failed_FINAL_validation <- list() # packages that failed final validation (after modifications)
list_of_docs_failed_FINAL_validation <- list() # docs that failed final validation (after modifications)

# -------------------------------------------------------------------------------------------------------------
# ----------------- get metadata/info for a particular datapackage and run initial validation -----------------
# -------------------------------------------------------------------------------------------------------------

tryLog(for(dp_num in 1:length(unique_datapackage_ids)){
  
  # get a package_id from unique_datapackage_ids vector
  pkg_identifier <- unique_datapackage_ids[[dp_num]]
  
  # download datapackage & parse
  outputs <- download_pkg_filter_data(pkg_identifier, attributes)
  doc <- outputs[[1]]
  current_pkg <- outputs[[2]]
  current_datapackage_subset <- outputs[[3]]
  current_metadata_pid <- outputs[[4]] 
  
  # initial validation
  initial_validation <- eml_validate(doc)
  
  # GATE to stop non-valid docs from processing
  if(isFALSE(initial_validation[1])){
    message("-------------- doc ", dp_num, " passes INTIAL validation -> ",  initial_validation[1], " --------------")
    list_of_docs_failed_validation[[dp_num]] <- doc
    names(list_of_docs_failed_INITIAL_validation)[[dp_num]] <- current_metadata_pid
    message("--------------Skipping to next doc...--------------")
    next
  }
  
  # for packages that passed initial validation, print message
  message("-------------- doc ", dp_num, " (", current_metadata_pid, ") passes INITIAL validation -> ",  initial_validation[1], " --------------")
  
  # GATE: ensure that the current metadata pid matches the packageId; if not, update the packageId with the current metadata pid
  if(current_metadata_pid != doc$packageId){
    message("!!!!!!!!!!!")
    message("doc_name (", current_metadata_pid, ") does not match packageId (", doc$packageId, ")")
    message("!!!!!!!!!!!")
    doc$packageId <- current_metadata_pid
    message("Updating packageId with the correct metadata pid...")
    message("!!!!!!!!!!!")
    message("packageId is now: ", doc$packageId)
    message("!!!!!!!!!!!")
  }
  
  # report how many dataTables and otherEntities are present in the current datapackage (informational only)
  get_entities(doc)
  
  # ---------------------------------------------------------------------------------------------------------------------------------------
  # -------------------------------- add annotations from the 'attributes' df to attributes in the EML doc --------------------------------
  # ---------------------------------------------------------------------------------------------------------------------------------------

  doc <- annotate_eml_attributes(doc)
  
  # ----------------------------------------------------------------------------------------------------------------------------------------
  # ----------------- validate modified doc and add to appropriate list so that it can be manually reviewed (if necessary) -----------------
  # ----------------------------------------------------------------------------------------------------------------------------------------
  
  # validate doc
  final_validation <- eml_validate(doc)
  
  # if doc passes validation, add to 'list_of_docs_to_publish_update()'
  if(isTRUE(final_validation[1])){
    message("-------------- doc ", dp_num, " (", current_metadata_pid, ") passes FINAL validation -> ",  final_validation[1], " --------------") 
    list_of_docs_to_publish_update[[dp_num]] <- doc
    list_of_pkgs_to_publish_update[[dp_num]] <- current_pkg
    names(list_of_docs_to_publish_update)[[dp_num]] <- current_metadata_pid 
    names(list_of_pkgs_to_publish_update)[[dp_num]] <- current_metadata_pid
    message("-------------- doc & pkg ", dp_num, " (", current_metadata_pid, ") have been added to the PUBLISH_UPDATE lists --------------")
  }
  
  # if doc fails validation, add to 'list_of_docs_failed_validation()' and 'list_of_pkgs_failed_validation()'
  if(isFALSE(final_validation[1])){
    message("-------------- doc ", dp_num, " (", current_metadata_pid, ") passes FINAL validation -> ",  final_validation[1], " --------------") 
    list_of_docs_failed_FINAL_validation[[dp_num]] <- doc
    list_of_pkgs_failed_FINAL_validation[[dp_num]] <- current_pkg
    names(list_of_docs_failed_FINAL_validation)[[dp_num]] <- current_metadata_pid 
    names(list_of_pkgs_failed_FINAL_validation)[[dp_num]] <- current_metadata_pid
    message("-------------- doc & pkg ", dp_num, " (", current_metadata_pid, ") have been added to the FAILED lists --------------")
  }
   
}, write.error.dump.file = TRUE, write.error.dump.folder = "dump_files", include.full.call.stack = FALSE) 



















# some space to breathe...


##########################################################################################
# STEP 2: clean up environment, make sure lists are cleaned (no empty elements)
##########################################################################################

# clean up global environment...
rm(current_datapackage_subset, current_pkg, doc, outputs, current_metadata_pid, dp_num, duplicate_ids, final_validation, initial_validation, pkg_identifier, unique_datapackage_ids, validate_attributeID_hash)

# !!!!!!!!!
# BE SURE TO MANUALLY INSPECT LISTS BELOW AND ASSESS BLANK ELEMENTS -- MAKE SURE LISTS MATCH
# !!!!!!!!!

# clean up lists (manually inspect and remove empty (NA) element(s))
publish_update_docs <- list_of_docs_to_publish_update
publish_update_pkgs <- list_of_pkgs_to_publish_update






























##########################################################################################
# STEP 3: publish updates to arctic.io 
##########################################################################################

##############################
# create empty df to store old and new pids in (in case needed for reference) 
##############################

old_new_metadataPIDs <- data.frame(old_metadataPID = as.character(),
                                   new_metadataPID = as.character())

##############################
# create empty lists for docs/pkgs that don't match
##############################

nonmatching_docs <- list()
nonmatching_pkgs <- list()
id_not_in_dp <- list()

##############################
# publish updates
##############################

tryLog(for(doc_num in 1:length(publish_update_docs)){ 

  # ----------------------------------------------------------------------------------------------
  # ----------------- get doc + metadata pid from the publish_update_docs() list -----------------
  # ----------------------------------------------------------------------------------------------
  
  # get doc from list
  doc <- publish_update_docs[[doc_num]]
  doc_name <- names(publish_update_docs)[[doc_num]]
  message("Grabbing doc ", doc_num, ": ", doc_name)
  
  # -----------------------------------------------------------------------------------
  # ----------- extract DataPackage instance from publish_update_pkgs() list-----------
  # -----------------------------------------------------------------------------------
  
  # get DataPackage instance from list based on index that matched doc_num 
  dp <- publish_update_pkgs[[doc_num]]
  pkg_name <- names(publish_update_pkgs)[[doc_num]]
  
  # GATE: make sure doc and pkg names from both lists match; if not, throw a warning, save to lists, and move to next doc/pkg pair
  if(doc_name != pkg_name){
    warning("The doc name matches the pkg name: ", doc_name == pkg_name, " |  Saving to lists and moving to next doc/pkg pair.")
    nonmatching_docs[[doc_num]] <- doc
    names(nonmatching_docs)[[doc_num]] <- doc_name
    nonmatching_pkgs[[doc_num]] <- dp
    names(nonmatching_docs)[[doc_num]] <- pkg_name
    next
  } 
  
  # print message if doc and package match
  message("The doc name matches the pkg name: ", doc_name == pkg_name)
  
  # -----------------------------------------------------------------------------------
  # ------------- get package_type from 'attributes' df using metadata_pid ------------
  # -----------------------------------------------------------------------------------
  
  # filter attributes df using metadata_pid
  atts_filtered <- attributes %>% 
    filter(identifier == doc_name)
  
  # get package_type
  package_type <- atts_filtered[[1, 12]]
  
  # ---------------------------------------------------------------------
  # ----------------- generate new pid and write to eml -----------------
  # ---------------------------------------------------------------------

  # generate new pid (either doi or urn:uuid depending on what the original had) for metadata and write eml path (using old & new pids in eml file name)
  # !!!!!UPDATE WITH NEW FILE PATH FOR EACH RUN!!!!!
  if(isTRUE(str_detect(doc_name, "(?i)doi"))) {
    new_id <- dataone::generateIdentifier(d1c_prod@mn, "DOI")
    message("Generating a new metadata DOI: ", new_id)
    original_doi_short <- str_split(doc_name, "/")[[1]][2]
    new_doi_short <- str_split(new_id, "/")[[1]][2]
    eml_name <- paste("doc", doc_num, "_old_", original_doi_short, "_new_", new_doi_short, ".xml", sep = "")
    eml_path <- paste("/Users/samanthacsik/Repositories/NCEAS-DF-semantic-annotations-review/eml/run1_test/", eml_name, sep = "")
    message("eml path: ", eml_path)
  } else if(isTRUE(str_detect(doc_name, "(?i)urn:uuid"))) {
    new_id <- dataone::generateIdentifier(d1c_prod@mn, "UUID")
    message("Generating a new metadata uuid: ", new_id)
    original_urn_short <- str_split(doc_name, "-")[[1]][5] 
    new_urn_short <- str_split(new_id, "-")[[1]][5]
    eml_name <- paste("doc", doc_num, "_old_", original_urn_short, "_new_", new_urn_short, ".xml", sep = "")
    eml_path <- paste("/Users/samanthacsik/Repositories/NCEAS-DF-semantic-annotations-review/eml/run1_test/", eml_name, sep = "")
  } else {
    stop("The original metadata ID format, ", metadata_pid, " is not recognized. No new ID has been generated.")
  }
  
  # write eml
  write_eml(doc, eml_path)
  
  # ---------------------------------------------------------------------------
  # ----------------- save old + new pids to df for reference -----------------
  # ---------------------------------------------------------------------------
  
  CURRENT_old_new_metadataPIDs <- data.frame(old_metadataPID = doc_name,
                                             new_metadataPID = new_id)
  
  old_new_metadataPIDs <- rbind(old_new_metadataPIDs, CURRENT_old_new_metadataPIDs)

  # ---------------------------------------------------------------
  # ------------------------ publish update -----------------------
  # ---------------------------------------------------------------
  
  # get DataObject names in current dp  
  message("Getting DataObject names from current package...")
  pkg_objects <- names(dp@objects)
  
  # check to make sure that the doc_name has a matching DataObject name in the current package; if so, replaceMember   
  if(isTRUE(str_subset(pkg_objects, pkg_name) == pkg_name)){
    
    dp <- replaceMember(dp, doc_name, replacement = eml_path, newId = new_id) 
    message("replaceMember() complete!")

    # if no match is found, add to the 'id_not_in_dp()' list and move to next DataPackage
  } else{
    message("DataObject for id ", doc_name, " was not found in the DataPackage. Adding to list and skipping to next DataPackage.")
    id_not_in_dp[[doc_num]] <- dp
    names(id_not_in_dp)[[doc_num]] <- doc_name
    next
  }
    
  # publish update
  message("Publishing update for the following data package: ", doc_name)
  # newPackageId <- uploadDataPackage(d1c_test, dp, public = FALSE, quiet = FALSE)
  message("Old metadata PID: " , doc_name, " | New metadata PID: ", new_id)
  message("-------------- Datapackage ", doc_num, " has been updated! --------------")
    
})











# more space to breathe


#-----------------------------------------------
# GENERAL STEPS
# you just have to get the resource map of the parent, and replace the old resource map of the child that you updated with the new version
# so you can do all of your updates, then for the parents you'll run:
#-----------------------------------------------

# ids <- get_package(mn, parent)

# new_children <- ... (write some code here that replaces the pid you updated in ids$child_pkg with the new one. this is a vector of child resource map pids (NOT metadata pids)

# update_resource_map(mn, metadata_pid = ids$metdata, resource_map_pid = ids$resource_map, data_pids = ids$data, child_pkgs = new_children)





# for testing (one parent metadata pid, which has four associated child packages that were updated)
parent_metadata_pid <- attributes[[1,15]]
child_metadata_pid <- attributes[[1,1]]

# 1) get the resource map of the parent
parent_ids <- get_package(d1c_prod@mn, 
                   parent_metadata_pid, 
                   file_names = TRUE)
parent_rm <- parent_ids$resource_map

# 2) get original resource map of child
child_ids <- get_package(d1c_prod@mn,
                   child_metadata_pid,
                   file_names = TRUE)

original_child_rm <- child_ids$resource_map












