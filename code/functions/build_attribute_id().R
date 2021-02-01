##############################
# build attribute id using index of current entity and attributeName from eml
  # entity_num: index of entity
  # attribute_num: index of attribute in current entity attribute
  # entity_path: 'eml_get(doc$dataset, dataTable_or_otherEntity)'
##############################

build_attributeID <- function(entity_num, attribute_num, entity_path){
  
  # if multiple entities present
  if(isTRUE(is.list(entity_path[[1]]))){
    entity_name <- tolower(paste("entity", entity_num, sep = "")) 
    attribute_name <- tolower(entity_path[[entity_num]]$attributeList$attribute[[attribute_num]]$attributeName)
    attribute_name_combo <- (paste("attribute", attribute_name, sep = "_")) 
    attribute_id <- paste(entity_name, attribute_name, sep = "_")
    
    # if single, unpacked entity present
  } else if(isTRUE(is.character(entity_path[[1]]))){
    entity_name <- tolower(paste("entity", entity_num, sep = "")) 
    attribute_name <- tolower(entity_path$attributeList$attribute[[attribute_num]]$attributeName)
    attribute_name_combo <- (paste("attribute", attribute_name, sep = "_")) 
    attribute_id <- paste(entity_name, attribute_name, sep = "_")
  }
}



