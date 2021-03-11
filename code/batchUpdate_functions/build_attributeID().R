#' Build a unique attribute ID for datasets with mulitple (packed) entities
#'
#' @param entity_num index of entity
#' @param eml_att_num index of eml attribute 
#' @param entity_path an EML element; either EML dataTables or EML other Entities 
#' @param current_eml_entity the entity from doc at index 'entity_num' (i.e. all_entities_byType[[entity_num]])
#'
#' @return
#' @export
#'
#' @examples
#' 
build_attributeID_packedEntity <- function(entity_num, eml_att_num, entity_path, current_eml_entity){
  
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
    
    # if not multiple entities, throw error
  } else {
    
    stop("This dataset contains multiple, packed entities. Double check version of 'build_attributeID()' in use.")
    
  }
}


#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------


#' Build a unique attribute ID for datasets with a single (unpacked) entities
#'
#' @param eml_att_num index of eml attribute 
#' @param entity_path an EML element; either EML dataTables or EML other Entities 
#' @param current_eml_entity the entity from doc at index 'entity_num' (i.e. all_entities_byType[[entity_num]])
#'
#' @return
#' @export
#'
#' @examples
#' 
build_attributeID_unpackedEntity <- function(eml_att_num, entity_path, current_eml_entity){
  
  # if single, unpacked entity present 
  if(isTRUE(is.character(current_eml_entity[[1]]))){  # current_eml_entity WAS entity_path
    
    # single entity, single attribute
    if(isTRUE(is.character(current_eml_entity$attributeList$attribute[[1]]))){ # entity path WAS current_eml_entity
      entity_name <- "singleEntity"
      attribute_name <- current_eml_entity$attributeList$attribute$attributeName
      attribute_name_combo <- paste("attribute", attribute_name, sep = "_")
      attribute_id <- paste(entity_name, attribute_name_combo, sep = "_")
      
      # single entity, multiple attributes
    } else if(isTRUE(is.list(current_eml_entity$attributeList$attribute[[1]]))){
      entity_name <- "singleEntity"
      attribute_name <- current_eml_entity$attributeList$attribute[[eml_att_num]]$attributeName
      attribute_name_combo <- paste("attribute", attribute_name, sep = "_")
      attribute_id <- paste(entity_name, attribute_name_combo, sep = "_")
    }
   
    # if not a single, unpacked entity, throw error
  } else {
    
    stop("This dataset contains a single, unpacked entity. Double check version of 'build_attributeID()' in use.")
    
  }
}























# build_attributeID <- function(entity_num, eml_att_num, entity_path, current_eml_entity){
#   
#   # if multiple entities present
#   if(isTRUE(is.list(entity_path[[1]]))){
#     
#     # multiple entities, single attribute
#     if(isTRUE(is.character(current_eml_entity$attributeList$attribute[[1]]))){
#       entity_name <- paste("entity", entity_num, sep = "")
#       attribute_name <- entity_path[[entity_num]]$attributeList$attribute$attributeName
#       attribute_name_combo <- paste("attribute", attribute_name, sep = "_")
#       attribute_id <- paste(entity_name, attribute_name_combo, sep = "_")
#       
#       # multiple entities, multiple attributes
#     } else if(isTRUE(is.list(current_eml_entity$attributeList$attribute[[1]]))){
#       entity_name <- paste("entity", entity_num, sep = "")
#       attribute_name <- entity_path[[entity_num]]$attributeList$attribute[[eml_att_num]]$attributeName
#       attribute_name_combo <- paste("attribute", attribute_name, sep = "_") 
#       attribute_id <- paste(entity_name, attribute_name_combo, sep = "_")
#     }
#     
#     # if single, unpacked entity present
#   } else if(isTRUE(is.character(entity_path[[1]]))){
#     
#     # single entity, single attribute
#     if(isTRUE(is.character(current_eml_entity$attributeList$attribute[[1]]))){
#       entity_name <- paste("entity", entity_num, sep = "")
#       attribute_name <- entity_path[[entity_num]]$attributeList$attribute$attributeName
#       attribute_name_combo <- paste("attribute", attribute_name, sep = "_")
#       attribute_id <- paste(entity_name, attribute_name_combo, sep = "_")
#       
#       # single entity, multiple attributes
#     } else if(isTRUE(is.list(current_eml_entity$attributeList$attribute[[1]]))){
#       entity_name <- paste("entity", entity_num, sep = "") 
#       attribute_name <- entity_path$attributeList$attribute[[eml_att_num]]$attributeName
#       attribute_name_combo <- paste("attribute", attribute_name, sep = "_")
#       attribute_id <- paste(entity_name, attribute_name_combo, sep = "_")
#     }
#   }
# }



