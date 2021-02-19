##############################
# build attribute id using index of current entity and attributeName from eml (NEED TO COME BACK TO STREAMLINE THIS LATER)
  # entity_num: index of entity
  # attribute_num: index of attribute in current entity attribute
  # entity_path: 'eml_get(doc$dataset, dataTable_or_otherEntity)'
##############################

build_attributeID <- function(entity_num, eml_att_num, entity_path, current_eml_entity){
  
  # if multiple entities present
  if(isTRUE(is.list(entity_path[[1]]))){
    
    # multiple entities, single attribute
    if(isTRUE(is.character(current_eml_entity$attributeList$attribute[[1]]))){
      entity_name <- paste("entity", entity_num, sep = "")
      attribute_name <- entity_path[[entity_num]]$attributeList$attribute$attributeName
      attribute_name_combo <- paste("attribute", attribute_name, sep = "_")
      attribute_id <- paste(entity_name, attribute_name_combo, sep = "_")
      
      # multiple entities, multiple attributes
    } else if(isTRUE(is.list(current_eml_entity$attributeList$attribute[[1]]))){
      entity_name <- paste("entity", entity_num, sep = "")
      attribute_name <- entity_path[[entity_num]]$attributeList$attribute[[eml_att_num]]$attributeName
      attribute_name_combo <- paste("attribute", attribute_name, sep = "_") 
      attribute_id <- paste(entity_name, attribute_name_combo, sep = "_")
    }
    
    # if single, unpacked entity present
  } else if(isTRUE(is.character(entity_path[[1]]))){
    
    # single entity, single attribute
    if(isTRUE(is.character(current_eml_entity$attributeList$attribute[[1]]))){
      entity_name <- paste("entity", entity_num, sep = "")
      attribute_name <- entity_path[[entity_num]]$attributeList$attribute$attributeName
      attribute_name_combo <- paste("attribute", attribute_name, sep = "_")
      attribute_id <- paste(entity_name, attribute_name_combo, sep = "_")
      
      # single entity, multiple attributes
    } else if(isTRUE(is.list(current_eml_entity$attributeList$attribute[[1]]))){
      entity_name <- paste("entity", entity_num, sep = "") 
      attribute_name <- entity_path$attributeList$attribute[[eml_att_num]]$attributeName
      attribute_name_combo <- paste("attribute", attribute_name, sep = "_")
      attribute_id <- paste(entity_name, attribute_name_combo, sep = "_")
    }
  }
}
  







# build_attributeID <- function(entity_num, attribute_num, entity_path){
#   
#   # if multiple entities present
#   if(isTRUE(is.list(entity_path[[1]]))){
#     entity_name <- tolower(paste("entity", entity_num, sep = "")) 
#     attribute_name <- tolower(entity_path[[entity_num]]$attributeList$attribute[[attribute_num]]$attributeName)
#     attribute_name_combo <- (paste("attribute", attribute_name, sep = "_")) 
#     attribute_id <- paste(entity_name, attribute_name, sep = "_")
#     
#     # if single, unpacked entity present
#   } else if(isTRUE(is.character(entity_path[[1]]))){
#     entity_name <- tolower(paste("entity", entity_num, sep = "")) 
#     attribute_name <- tolower(entity_path$attributeList$attribute[[attribute_num]]$attributeName)
#     attribute_name_combo <- (paste("attribute", attribute_name, sep = "_")) 
#     attribute_id <- paste(entity_name, attribute_name, sep = "_")
#   }
#   
#   return(attribute_id)
# }
