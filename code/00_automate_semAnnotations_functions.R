# title: Custom Functions for automated semantic annotations
# author: "Sam Csik"
# date created: "2020-12-29"
# date edited: "2020-12-29"
# packages updated: __
# R version: __
# input: NA
# output: NA


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
    message(current_attribute_id, " has been added")
  # if duplicate, add to vector (value = NULL)
  } else {
    warning("the following id is a duplicate: ", current_attribute_id)
    duplicate_ids <- current_attribute_id
  }
}

##############################
# create_propertyURI
##############################

add_semAnn_propertyURI <- function(dataTable_number, attribute_number){
  doc$dataset$dataTable[[dataTable_number]]$attributeList$attribute[[attribute_number]]$annotation$propertyURI <- list(label = "contains meausurements of",
                                                                                        propertyURI = "http://ecoinformatics.org/oboe/oboe.1.2/oboe-core.owl#containsMeasurementsOfType")
}




































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
