# title: batch update of datapackages with semantic annotations (workflow currently for standalone packages only)
# author: "Sam Csik"
# date created: "2021-01-04"
# date edited: "2021-03-16"
# R version: 3.6.3
# input: "code/10a.3_batch_update_setup.R"
# output: no output, but publishes updates to arcticdata.io 

##########################################################################################
# Summary - READ BEFORE RUNNING
##########################################################################################

# This script contains code for automating a batch update of ADC datapackages with semantic annotations. I (Sam Csik) manually assessed non-annotated attributes within the ADC corpus and determined term URIs that I felt would best semantically describe 27000+ attributes across 1061 unique datapackages. These attributes, and the corresponding URIs I've assigned to them can be found in file, "data/outputs/attributes_to_annotate/script10a2_attributes_to_annotate/attributes_to_annotate_2021Mar12.csv" -- this file will be imported and stored as an object called 'attributes'

# Feel free to ignore scripts 10a.1_determine_pkg_sizes.R and 10a.2_batch_update_data_wrangling.R -- I use these to get the attribute and datapackage info into the right format for working with

# Below, I source in script 10a.3_batch_update_setup.R -- this is where you can subset the 'attributes' df for a few packages at a time for testing purposes. See lines 80-84 as an example. Just be sure to that whatever subset you're working with is still called 'attributes'

# I also source in all the functions that I've written. Each function has it's own script (with one or two exceptions). Those can be found in "code/batchUpdate_functions/*" -- NOTE: I haven't quite gotten around to fully documenting them all yet...but that's on my TODO list

# You'll need to update the file path in lines 329 and 337 (haven't figured out how to make this more flexible yet)

# Line 377 is commented out so that you won't actually publish any updates to arctic.io (I haven't actually tested running that yet, but I don't have any reason (yet) to believe that it won't work)

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Bryce -- you don't really need to worry so much about these steps for testing purposes -- mostly thinking about how I can stay organized re: which pkgs have been updated vs. those that still need to be once when we actually start this process for real. You should feel free to play around with step 1 under 'Pre-update steps,' however.

# Pre-update steps:
#------------------
# 1) filter 'attributes' df for a subset of packages to be updated (do this in script 10a.3_batch_update_setup.R)
# 2) rename subset as 'attributes' (do this in THIS script, 10b_batch_update_childORunnested.R)
# 2) update file path for writing EML (naming convention: eml/run#_pkgTypeIDtype_sizeClass_date, e.g. run1_standaloneDOI_small_2021Mar11)

# Post-update steps: 
#-------------------
# 1) save 'old_new_PIDs' df to a .csv file with the same naming convention as above (e.g. run1_standaloneDOI_small_2021Mar11) 
# 2) note any updated package as "complete" in the attributes df (do this in script 10a_batch_update_setup.R)

# Rinse, repeat

##########################################################################################
# General Setup
##########################################################################################

# load data/setup
source(here::here("code", "10a.3_batch_update_setup.R"))

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
# ensure subset of data is named 'attributes'
##############################

attributes <- run2_standaloneDOI_small

##############################
# get vector of all unique datapackages
##############################

unique_datapackage_ids <- unique(attributes$identifier)

##############################
# create empty lists for sorting pkgs and docs into 
##############################

list_of_docs_to_publish_update <- list() # modified docs that passed validation
list_of_pkgs_to_publish_update <- list() # corresponding packages that will be updated (needed for 2nd for loop)
list_of_docs_failed_INITIAL_validation <- list() # docs that failed initial validation (before modifications)
list_of_pkgs_failed_INITIAL_validation <- list() # corresponding pkgs that failed initial validation (before modifications)
list_of_docs_failed_FINAL_validation <- list() # docs that failed final validation (after modifications)
list_of_pkgs_failed_FINAL_validation <- list() # corresponding packages that failed final validation (after modifications)

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
    list_of_docs_failed_INITIAL_validation[[dp_num]] <- doc
    list_of_pkgs_failed_INITIAL_validation[[dp_num]] <- current_pkg
    names(list_of_docs_failed_INITIAL_validation)[[dp_num]] <- current_metadata_pid
    names(list_of_pkgs_failed_INITIAL_validation)[[dp_num]] <- current_metadata_pid
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
# BE SURE TO MANUALLY INSPECT LISTS BELOW AND ASSESS BLANK ELEMENTS -- MAKE SURE LISTS MATCH (though there is check for this built into step 3 below)
# !!!!!!!!!

# clean up lists (manually inspect and remove empty (NA) element(s), if necessary...if all docs passed initial/final validation then you won't need to worry about removing NAs)
publish_update_docs <- list_of_docs_to_publish_update
publish_update_pkgs <- list_of_pkgs_to_publish_update






























##########################################################################################
# STEP 3: publish updates to arctic.io 
##########################################################################################

##############################
# create empty df to store old and new pids in (in case they are needed for later reference) 
##############################

old_new_PIDs <- data.frame(old_metadataPID = as.character(),
                           old_resource_map = as.character(),
                           new_metadataPID = as.character(),
                           new_resource_map = as.character())

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
  original_rm <- dp@resmapId
  
  # -----------------------------------------------------------------------------------
  # -------------------------- make sure doc and pkg matches --------------------------
  # -----------------------------------------------------------------------------------
  
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
  
  # # filter attributes df using metadata_pid
  # atts_filtered <- attributes %>% 
  #   filter(identifier == doc_name)
  # 
  # # get package_type
  # package_type <- atts_filtered[[1, 12]]
  
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
    eml_path <- paste("/Users/samanthacsik/Repositories/NCEAS-DF-semantic-annotations-review/eml/run2_standaloneDOI_small_2021Mar17/", eml_name, sep = "")
    message("eml path: ", eml_path)
  } else if(isTRUE(str_detect(doc_name, "(?i)urn:uuid"))) {
    new_id <- dataone::generateIdentifier(d1c_prod@mn, "UUID")
    message("Generating a new metadata uuid: ", new_id)
    original_urn_short <- str_split(doc_name, "-")[[1]][5] 
    new_urn_short <- str_split(new_id, "-")[[1]][5]
    eml_name <- paste("doc", doc_num, "_old_", original_urn_short, "_new_", new_urn_short, ".xml", sep = "")
    eml_path <- paste("/Users/samanthacsik/Repositories/NCEAS-DF-semantic-annotations-review/eml/run2_standaloneDOI_small_2021Mar17/", eml_name, sep = "")
  } else {
    stop("The original metadata ID format, ", metadata_pid, " is not recognized. No new ID has been generated.")
  }
  
  # write eml
  write_eml(doc, eml_path)
  
  # ---------------------------------------------------------------
  # ------------------------ publish update -----------------------
  # ---------------------------------------------------------------
  
  # get DataObject names in current dp  
  message("Getting DataObject names from current package...")
  pkg_objects <- names(dp@objects)
  
  # check to make sure that the doc_name has a matching DataObject name in the current package; if so, replaceMember   
  if(isTRUE(str_subset(pkg_objects, pkg_name) == pkg_name)){
    dp <- replaceMember(dp, doc_name, replacement = eml_path, newId = new_id, formatId = "https://eml.ecoinformatics.org/eml-2.2.0") 
    double_check_sysmeta_formatId <- getSystemMetadata(d1c_prod@mn, new_id)
    message("formatId is 2.2.0: ", double_check_sysmeta@formatId == "https://eml.ecoinformatics.org/eml-2.2.0")
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
  new_rm <- uploadDataPackage(d1c_prod, dp, public = TRUE, quiet = FALSE)
  message("Old metadata PID: " , doc_name, " | New metadata PID: ", new_id)
  message("-------------- Datapackage ", doc_num, " has been updated! --------------")
  
  # ---------------------------------------------------------------------------
  # ----------------- save old + new pids to df for reference -----------------
  # ---------------------------------------------------------------------------
  
  pids <- data.frame(old_metadataPID = doc_name,
                     old_resource_map = original_rm,
                     new_metadataPID = new_id, 
                     new_resource_map = new_rm)
  
  old_new_PIDs <- rbind(old_new_PIDs, pids)
  
  message("______ PIDS SAVED ______")
  
})

# ---------------------------------------------------------------
# ------------- save old/new metadata PIDs to a .csv ------------
# ---------------------------------------------------------------

# Be sure to update file name before saving!!
# write_csv(old_new_PIDs, here::here("data", "updated_pkgs", "run2_standaloneDOI_small_2021Mar17.csv"))












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
# parent_metadata_pid <- attributes[[1,15]]
# child_metadata_pid <- attributes[[1,1]]
# 
# # 1) get the resource map of the parent
# parent_ids <- get_package(d1c_prod@mn, 
#                    parent_metadata_pid, 
#                    file_names = TRUE)
# parent_rm <- parent_ids$resource_map
# 
# # 2) get original resource map of child
# child_ids <- get_package(d1c_prod@mn,
#                    child_metadata_pid,
#                    file_names = TRUE)
# 
# original_child_rm <- child_ids$resource_map












