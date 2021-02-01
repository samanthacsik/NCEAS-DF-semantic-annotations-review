##############################
# build attribute id
  # NOTE CHANGES:
      # dataTable_number --> entity_number
      # doc$dataset$dataTable --> entity_path
##############################

build_attributeID <- function(entity_number, attribute_number, entity_path){
  
  # if multiple entities present
  if(isTRUE(is.list(all_entities_path[[1]]))){
    entity_name <- tolower(paste("entity", entity_number, sep = "")) 
    attribute_name <- tolower(entity_path[[entity_number]]$attributeList$attribute[[attribute_number]]$attributeName)
    attribute_name_combo <- (paste("attribute", attribute_name, sep = "_")) 
    attribute_id <- paste(entity_name, attribute_name, sep = "_")
    
    # if single, unpacked entity present
  } else if(isTRUE(is.character(all_entities_path[[1]]))){
    entity_name <- tolower(paste("entity", entity_number, sep = "")) 
    attribute_name <- tolower(entity_path$attributeList$attribute[[attribute_number]]$attributeName)
    attribute_name_combo <- (paste("attribute", attribute_name, sep = "_")) 
    attribute_id <- paste(entity_name, attribute_name, sep = "_")
  }
}



