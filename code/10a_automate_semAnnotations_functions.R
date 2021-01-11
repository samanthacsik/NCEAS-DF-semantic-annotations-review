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

get_datapackage_metadata <- function(current_resource_map){
  
  # get pkg using resource map 
  current_pkg <- getDataPackage(d1c_test, identifier = current_resource_map, lazyLoad = TRUE, quiet = FALSE)
  
  # get eml version for use in 'selectMember()'
  format_id_version <- get_eml_version(pkg = current_pkg) 
  
  # get metadata pid from pkg 
  if(isTRUE(str_detect(format_id_version, "2.1.1"))) {
    current_metadata_pid  <- selectMember(current_pkg, name = "sysmeta@formatId", value = "eml://ecoinformatics.org/eml-2.1.1")
    message("eml version 2.1.1")
  } else if(isTRUE(str_detect(format_id_version, "2.2.0"))) {
    current_metadata_pid  <- selectMember(current_pkg, name = "sysmeta@formatId", value = "https://eml.ecoinformatics.org/eml-2.2.0")
    message("eml version 2.2.0")
  } else {
    warning("The eml version of this metadata file is not recognized.")
    print("NOTE FOR SAM: need to figure out how to acutally deal with this if it ever comes up")
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