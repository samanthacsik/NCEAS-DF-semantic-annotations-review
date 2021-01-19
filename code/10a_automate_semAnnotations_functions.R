# title: Custom Functions for automated semantic annotations
# author: "Sam Csik"
# date created: "2020-12-29"
# date edited: "2021-01-08"
# R version: 3.6.3
# input: NA
# output: NA

##############################
#  Extracts eml version (e.g. 2.1.1, 2.2.0) from data objects
##############################

get_eml_version <- function(pkg){
  
  # get data objects from current_pkg
  obj <- pkg@objects
  
  # get names of objects
  keys <- names(obj)
  
  # format_id_version <- NULL
  
  for(i in 1:length(keys)){
    
    # get info for each data object
    data <- obj[[keys[i]]]
    
    # extract formatId of data object 
    formatId <- getFormatId(data)
    
    # if the formatId of the data object matches this string, then split and grab the part containing the version number
    if (str_detect(formatId, "ecoinformatics.org")) {
      format_id_version <- str_split(formatId, "-")[[1]][2]
    }
  
  }
  
  return(format_id_version)
}

##############################
#  load metadata as 'doc'
##############################

get_datapackage_metadata <- function(current_datapackage_id){
  
  # Use arcticdatautils `get_package()` to get rm pid 
  pkg <- get_package(d1c_test@mn, 
                     current_datapackage_id, # this is actually the metadata pid from solr (will throw a warning but that's okay)
                     file_names = TRUE)
  
  # extract resource map
  resource_pid <-  pkg$resource_map
  
  # get pkg using resource map 
  current_pkg <- getDataPackage(d1c_test, identifier = resource_pid, lazyLoad = TRUE, quiet = FALSE)
  
  # get eml version for use in 'selectMember()'
  format_id_version <- get_eml_version(pkg = current_pkg) 
  
  # get metadata pid from pkg (this is redundant but leaving in anyways)
  if(isTRUE(str_detect(format_id_version, "2.1.1"))) {
    current_metadata_pid  <- selectMember(current_pkg, name = "sysmeta@formatId", value = "eml://ecoinformatics.org/eml-2.1.1")
    message("eml version 2.1.1")
  } else if(isTRUE(str_detect(format_id_version, "2.2.0"))) {
    current_metadata_pid  <- selectMember(current_pkg, name = "sysmeta@formatId", value = "https://eml.ecoinformatics.org/eml-2.2.0")
    message("eml version 2.2.0")
  } else {
    warning("The eml version of this metadata file is not recognized.")
    print("NOTE FOR SAM: need to figure out how to actually deal with this if it ever comes up")
  }
  
  # read in eml metadata using pid 
  doc <- read_eml(getObject(d1c_test@mn, current_metadata_pid)) 
  message("Imported eml medatadata for datapackage: ", current_datapackage_id)
  
  # create list to return
  step1_list <- list(current_pkg, current_metadata_pid, doc)
  
  return(step1_list)
}

##############################
# build attribute id
##############################

build_attributeID <- function(dataTable_number, attribute_number){
  
  entity_name <- tolower(paste("entity", dataTable_number, sep = "")) 
  attribute_name <- tolower(doc$dataset$dataTable[[dataTable_number]]$attributeList$attribute[[attribute_number]]$attributeName)
  attribute_name_combo <- (paste("attribute", attribute_name, sep = "_")) 
  attribute_id <- paste(entity_name, attribute_name, sep = "_")
  
}

##############################
# verify that attribute ID created is unique
##############################

verify_attributeID_isUnique <- function(current_attribute_id){
  
  # search hash table for an id (key) match; if no match, add to table (value = TRUE)
  if (is.null(my_hash[[current_attribute_id]])) {
    my_hash[[current_attribute_id]] <- TRUE
    message("'", current_attribute_id, "' is unique and has been added to the hash")
  # if duplicate, add to vector (value = NULL)
  } else {
    warning("the following id is a duplicate: ", current_attribute_id)
    duplicate_ids <- current_attribute_id
  }
}

##############################
# add attribute id to metadata
##############################

# add_attributeID <- function(dataTable_number, attribute_number, attributeID){
#   doc$dataset$dataTable[[dataTable_number]]$attributeList$attribute[[attribute_number]]$id <- attributeID
# }

##############################
# add propertyURI to metadata
##############################

# add_propertyURI <- function(dataTable_number, attribute_number){
#   doc$dataset$dataTable[[dataTable_number]]$attributeList$attribute[[attribute_number]]$annotation$propertyURI <- list(label = "contains meausurements of",
#                                                                                         propertyURI = "http://ecoinformatics.org/oboe/oboe.1.2/oboe-core.owl#containsMeasurementsOfType")
# }


##############################
# add valueURI to metadata
##############################

# add_valueURI <- function(dataTable_number, attribute_number, current_label, current_valueURI){
#   doc$dataset$dataTable[[dataTable_number]]$attributeList$attribute[[attribute_number]]$annotation$valueURI <- list(label = current_label,
#                                                                                       valueURI = current_valueURI)
# }


##################################################################################################

##############################
# download package (using arcticdatautils::get_package()) and add results to hash
##############################

process_package <- function(index, unique_datapackage_ids) {
  message("**** Working on datapackage ", index, " of ", length(unique_datapackage_ids), " ****")
  
  has_existing_result <- !is.null(results_hash[[as.character(index)]])
  # should_skip <- index != 786
  message("**** Has Existing Result: ", has_existing_result, " ****")
  # message("**** Should Skip: ", should_skip, " ****")
  
  # if the datapackage at index has already been stored in the hash, don't rerun (allows us to pick back up where we left off if error halts processes)
  if(has_existing_result) { # || should_skip
    message("**** Skipping: ", index, " ****")
    return()
  }
  
  # get package using its metadata pid (i.e. the 'identifier' from the 'attributes' df)
  pkg <- get_package(d1c_prod@mn,
                     unique_datapackage_ids[index],
                     file_names = TRUE)
  
  results_hash[[as.character(index)]] <- get_result(pkg, pkg$resource_map, unique_datapackage_ids[index])
}

##############################
# add results to hash (used in process_package() above)
##############################

get_result <- function(pkg, parent_rm, parent_metadata_pid) {
  
  results <- NULL
  
  # check to see if there are child packages; if so, save information
  if(length(pkg$child_packages) > 0){
    
    message("**** I have this many child packages: ", length(pkg$child_packages), " ****")
    
    # create empty df to store data in (this df will get stored in a hash for each iteration of the loop)
    results_df <- data.frame(child_rm = as.character(),
                             parent_rm = as.character(),
                             parent_metadata_pid = as.character(),
                             stringsAsFactors=FALSE)
    
    # extract rm for each child package and store in vector along with the associated parent rm
    for(j in 1:length(pkg$child_packages)){
      
      message("extracting rm ", j, " of ", length(pkg$child_packages))
      
      # save child resource map
      child_rm <- pkg$child_packages[[j]]
      
      # put child and parent datapackage rm & pid into vector, then add to empty df, 'results_df'
      stuff <- c(parent_rm, parent_metadata_pid, child_rm) # THIS ORDER IS OFF, should be 'c(child_rm, parent_rm, parent_metadata_pid)'
      # stuff <- c(child_rm, parent_rm, parent_metadata_pid)
      row <- nrow(results_df) + 1
      results_df[row, ] <- stuff
    }
    
    results <- results_df
    
    # if there are not child datapackages associated with the current unique_datapackage_id, add to results_hash as such
  } else {
    message("there are NO child packages")
    results <- "NO CHILD PACKAGES"
  }
  return(results)
}

##############################
# combine all results into single 'all_results_df' 
##############################

process_results <- function(result, all_results_df) {
  
  # if value in hash is a type list, it means there is child pkg info that needs to be combined in the 'all_results_df'
  should_process <- (typeof(result) == "list")
  message("**** Should Process: ", should_process, " ****")
  
  if (should_process) {
    all_results_df <- rbind(all_results_df, result)
  }
  
  return(all_results_df)
  
}
