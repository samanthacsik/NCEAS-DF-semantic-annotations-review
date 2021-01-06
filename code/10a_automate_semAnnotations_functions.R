# title: Custom Functions for automated semantic annotations
# author: "Sam Csik"
# date created: "2020-12-29"
# date edited: "2021-01-05"
# R version: 3.6.3
# input: NA
# output: NA

##############################
#  THIS ALL HAS TO CHANGE
##############################

get_datapackage_metadata <- function(current_resource_map){
  
  # get pkg using resource map 
  current_pkg <- getDataPackage(d1c_test, identifier = current_resource_map, lazyLoad = TRUE, quiet = FALSE)
  # current_pkg <- get_package(adc_test, 
  #                            current_resource_map,
  #                            file_names = TRUE)
  
  # get metadata pid from pkg --- USE datapack::getDataPackage HERE INSTEAD!!
  current_metadata_pid  <- selectMember(current_pkg, name = "sysmeta@formatId", value = "eml://ecoinformatics.org/eml-2.1.1")
  # current_metadata_pid <- current_pkg$metadata
  
  # read in eml metadata using pid 
  doc <- read_eml(getObject(d1c_test@mn, current_metadata_pid)) 
  message("Imported eml medatadata for datapackage: ", current_datapackage_id)
  
  return(doc)
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

add_attributeID <- function(dataTable_number, attribute_number, attributeID){
  doc$dataset$dataTable[[dataTable_number]]$attributeList$attribute[[attribute_number]]$id <- attributeID
}

##############################
# add propertyURI to metadata
##############################

add_propertyURI <- function(dataTable_number, attribute_number){
  doc$dataset$dataTable[[dataTable_number]]$attributeList$attribute[[attribute_number]]$annotation$propertyURI <- list(label = "contains meausurements of",
                                                                                        propertyURI = "http://ecoinformatics.org/oboe/oboe.1.2/oboe-core.owl#containsMeasurementsOfType")
}


##############################
# add valueURI to metadata
##############################

add_valueURI <- function(dataTable_number, attribute_number, current_label, current_valueURI){
  doc$dataset$dataTable[[dataTable_number]]$attributeList$attribute[[attribute_number]]$annotation$valueURI <- list(label = current_label,
                                                                                      valueURI = current_valueURI)
}























# Station
# doc$dataset$dataTable[[1]]$attributeList$attribute[[1]]$id <- "entity_location_attribute_stationID1"
# doc$dataset$dataTable[[1]]$attributeList$attribute[[1]]$annotation$propertyURI <- list(label = "contains meausurements of",
#                                                                                        propertyURI = "http://ecoinformatics.org/oboe/oboe.1.2/oboe-core.owl#containsMeasurementsOfType")
# doc$dataset$dataTable[[1]]$attributeList$attribute[[1]]$annotation$valueURI <- list(label = "station identifier",
#                                                                                     valueURI = "http://purl.dataone.org/odo/ECSO_00002393")








##############################
#### ORIGINAL ####
##############################

# # iterate through all entities in the datapackage
# for(i in 1:numberOf_dataTables){
#   
#   message("Processing dataTable ", i, " of ", numberOf_dataTables)
#   
#   # see all attribute names in current dataTable
#   current_attribute_list <- eml_get_simple(doc$dataset$dataTable[[i]]$attributeList, "attributeName")
#   
#   # iterate through attributes to build id and add to hash table
#   for(j in 1:length(current_attribute_list)){
#     
#     # build attribute_id
#     entity_name <- tolower(paste("entity", i, sep = "")) 
#     attribute_name <- tolower(doc$dataset$dataTable[[i]]$attributeList$attribute[[j]]$attributeName)
#     attribute_name_combo <- (paste("attribute", attribute_name, sep = "_")) 
#     current_attribute_id <- paste(entity_name, attribute_name, sep = "_")
#     
#     # search hash table for an id (key) match; if no match, add to table (value = TRUE); if duplicate, add to vector (value = NULL)
#     if (is.null(my_hash[[current_attribute_id]])) {
#       my_hash[[current_attribute_id]] <- TRUE
#       message(current_attribute_id, " has been added")
#     } else {
#       warning("the following id is a duplicate: ", current_attribute_id)
#       duplicate_ids <- current_attribute_id
#     }
#   }
# }
