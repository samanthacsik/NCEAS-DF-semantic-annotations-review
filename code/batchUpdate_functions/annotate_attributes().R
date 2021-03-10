#' Add semantic annotations to EML metadata
#'
#' @param doc eml metadata 
#' @param entity_num index of entity (see for loop in 'process_entites_by_type()')
#' @param dataTable_or_otherEntity character string; "dataTable" or "otherEntity"
#' @param current_eml_entity the entity from doc at index 'entity_num' (i.e. all_entities_byType[[entity_num]])
#' @param is_single_entity TRUE or FALSE
#'
#' @return doc
#' @export
#'
#' @examples

annotate_attributes <- function(doc, entity_num, dataTable_or_otherEntity, current_eml_entity, is_single_entity){
  
  # ---------------------------------------------------------------------------------------------
  # Setup; get entity-specific data
  # ---------------------------------------------------------------------------------------------
  
  # initialize annotation counter to track number of annotations added to doc
  annotation_counter <- 0
  
  # get current dataTable or otherEntity name from eml metadata; determine how many attributes exist in the eml entity
  current_entityName_from_eml <- current_eml_entity$entityName
  num_attributes_in_eml_entity <- length(current_eml_entity$attributeList$attribute)
  
  # subset 'current_datapackage_subset' accordingly
  current_entity_subset <- current_datapackage_subset %>%
    filter(entityName == current_entityName_from_eml)
  
  # ---------------------------------------------------------------------------------------------
  # if there are any attributes in the current eml entity, continue processing; if not, skip and move to next entity
  # ---------------------------------------------------------------------------------------------
  
  # GATE: Only lets past any entities that contain attributes i.e. if the current entity has NO associated attributes, skip it
  if(isTRUE(num_attributes_in_eml_entity == 0)){
    message("The current entity ", current_entityName_from_eml, " contains ", num_attributes_in_eml_entity, " attributes. Moving to next eml entity.")
    message("*****************************************************")
    return(doc)
  } 
  
  # if 'single_attribute' == TRUE, then the current entity contains a single, unpacked attribute; if FALSE, then it contains multiple attributes
  is_single_attribute <- isTRUE(is.character(current_eml_entity$attributeList$attribute[[1]]))
  
  # set entity_path (to either "dataTables" or "otherEntities")
  entity_path <- eml_get(doc$dataset, dataTable_or_otherEntity)
  
  # ---------------------------------------------------------------------------------------------
  # if the current entity contains more than 1 attribute (i.e. `is_single_attribute` == FALSE), annotate the attributes using the following methods
  # ---------------------------------------------------------------------------------------------
  
  if(isFALSE(is_single_attribute)){
    
    for(eml_att_num in 1:num_attributes_in_eml_entity){

      # get attributeName from metadata
      attributeName_eml <- current_eml_entity$attributeList$attribute[[eml_att_num]]$attributeName
      
      # subset df for corresnponding attributeName 
      attributeName_subset <- current_entity_subset %>% 
        filter(attributeName == attributeName_eml)
      
      # GATE: if there is no match for the current eml attribute in our df, skip it and move to next attribute
      if(length(attributeName_subset$attributeName) == 0){
        next
      }
  
      # if current attribute makes it past the above GATE, it means there's a match; add 1 to 'annotation_counter'
      annotation_counter <- annotation_counter + 1
      
      # if the current entity is a 'dataTable' process with the following methods
      if(dataTable_or_otherEntity == "dataTable"){
        
        # if the current dataTable is the singular dataTable (therefore unpacked), process using the following method:
        if(is_single_entity){
          
          current_attribute_id <- build_attributeID(entity_num, eml_att_num, entity_path, current_eml_entity) 
          validate_attributeID_hash <- verify_attributeID_isUnique(current_attribute_id)
          doc <- annotate_single_dataTable_multiple_attributes(doc, eml_att_num, current_attribute_id, attributeName_subset)
          
          # otherwise, the current dataTable is one of multiple dataTables, process using the following method:
        } else{
    
          current_attribute_id <- build_attributeID(entity_num, eml_att_num, entity_path, current_eml_entity) 
          validate_attributeID_hash <- verify_attributeID_isUnique(current_attribute_id)
          doc <- annotate_multiple_dataTables_multiple_attributes(doc, entity_num, eml_att_num, current_attribute_id, attributeName_subset)

        }
      
        # if the current entity is an 'otherEntity' process with the following methods
      } else if(dataTable_or_otherEntity == "otherEntity"){
        
        # if the current otherEntity is the singular otherEntity (therefore unpacked), process using the following method:
        if(is_single_entity){
          
          current_attribute_id <- build_attributeID(entity_num, eml_att_num, entity_path, current_eml_entity) 
          validate_attributeID_hash <- verify_attributeID_isUnique(current_attribute_id)
          doc <- annotate_single_otherEntity_multiple_attributes(doc, eml_att_num, current_attribute_id, attributeName_subset)
          
          # otherwise, the current otherEntity is one of multiple otherEntities, process using the following method:
        } else{
          
          current_attribute_id <- build_attributeID(entity_num, eml_att_num, entity_path, current_eml_entity) 
          validate_attributeID_hash <- verify_attributeID_isUnique(current_attribute_id)
          doc <- annotate_multiple_otherEntities_multiple_attributes(doc, entity_num, eml_att_num, current_attribute_id, attributeName_subset)
          
        }
        
        # if the current entity is not a 'dataTable' or 'otherEntity' give warning
      } else{
        warning("DON'T KNOW WHAT THIS ENTITY TYPE IS")
      }
    }
  }
  
  # ---------------------------------------------------------------------------------------------
  # if the current entity contains only a single (unpacked) attribute, annotate using the following methods
  # ---------------------------------------------------------------------------------------------
  
  if(isTRUE(is_single_attribute)){
    
    # get attributeName from metadata
    attributeName_eml <- current_eml_entity$attributeList$attribute$attributeName
    
    # subset df for corresnponding attributeName 
    attributeName_subset <- current_entity_subset %>% 
      filter(attributeName == attributeName_eml)
    
    # GATE: if the single eml entity does not have a match in the df, move to the next entity in the datapackage
    if(length(attributeName_subset$attributeName) == 0){
      message("The current entity contains ONE unpacked attribute, ", attributeName_eml, ", which does not have a match in the df. Moving to the next entity in the datapackage")
      return(doc)
    }
    
    # if attribute makes it past the above GATE, it means there's a match; add 1 to 'annotation_counter'
    annotation_counter <- annotation_counter + 1
    
    # if the current entity is a 'dataTable' process with the following methods
    if(dataTable_or_otherEntity == "dataTable"){
      
      # if the current dataTable is the singular dataTable (therefore unpacked), process using the following method:
      if(is_single_entity){
        
        current_attribute_id <- build_attributeID(entity_num, eml_att_num, entity_path, current_eml_entity) 
        validate_attributeID_hash <- verify_attributeID_isUnique(current_attribute_id)
        doc <- annotate_single_dataTable_single_attribute(doc, current_attribute_id, attributeName_subset)
        
        # otherwise, the current dataTable is one of multiple dataTables, process using the following method:
      } else{
        
        current_attribute_id <- build_attributeID(entity_num, eml_att_num, entity_path, current_eml_entity) 
        validate_attributeID_hash <- verify_attributeID_isUnique(current_attribute_id)
        doc <- annotate_multiple_dataTables_single_attribute(doc, entity_num, current_attribute_id, attributeName_subset)
        
      }
      
      # if the current entity is an 'otherEntity' process with the following methods
    } else if(dataTable_or_otherEntity == "otherEntity"){
      
      # if the current otherEntity is the singular otherEntity (therefore unpacked), process using the following method:
      if(is_single_entity){
        
       current_attribute_id <- build_attributeID(entity_num, eml_att_num, entity_path, current_eml_entity) 
       validate_attributeID_hash <- verify_attributeID_isUnique(current_attribute_id)
       doc <- annotate_single_otherEntity_single_attribute(doc, current_attribut_id, attributeName_subset)
        
       # otherwise, the current otherEntity is one of multiple otherEntities, process using the following method:
      } else{
        
        current_attribute_id <- build_attributeID(entity_num, eml_att_num, entity_path, current_eml_entity) 
        validate_attributeID_hash <- verify_attributeID_isUnique(current_attribute_id)
        doc <- annotate_multiple_otherEntities_single_attribute(doc, entity_num, current_attribute_id, attributeName_subset)
        
      }
      
      # if the current entity is not a 'dataTable' or 'otherEntity' give warning
    } else{
      warning("DON'T KNOW WHAT THIS IS")
    }
  }
  
  # ---------------------------------------------------------------------------------------------
  # messaging for mental checks
  # ---------------------------------------------------------------------------------------------
  
  attributes_to_annotate <- length(current_entity_subset$attributeName)
  message("Processed ", dataTable_or_otherEntity, ": ", entity_num, " | ",  current_entityName_from_eml)
  message("Attributes in Metadata -> ", num_attributes_in_eml_entity, " | attributes to annotate -> ", attributes_to_annotate, " | Added -> ", annotation_counter, " | Complete -> ", (attributes_to_annotate == annotation_counter))
  message("*****************************************************")
  
  return(doc)
}
