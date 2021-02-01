##############################
# annotate attributes (NOTE THERE ARE TWO DIFFERENT FUNCTIONS HERE)
##############################

annotate_attributes <- function(doc, entity_num, current_entityName_from_eml, num_attributes_in_eml_entity, current_entity_subset, entity_path){
  
  annotation_counter <- 0
  
  for(att_num in 1:num_attributes_in_eml_entity){
    
    # 3.1) get attribute from dataTable in eml 
    current_attribute_name_from_eml <- entity_path[[entity_num]]$attributeList$attribute[[att_num]]$attributeName
    # message("--> Found attribute #", att_num, " : '", current_attribute_name_from_eml, "'")
    
    # 3.2) subset df using current_attribute_name_from_eml 
    current_attribute_subset <- current_entity_subset %>% 
      filter(attributeName == current_attribute_name_from_eml)
    
    # 3.3) if eml attribute exists in df, continue, if not move to next attribute in eml
    if(length(current_attribute_subset$attributeName > 0)){ 
      
      # message("The corresponding attribute to #", att_num, " in the df is: '", current_attribute_subset$attributeName, "'")
      
      # 3.4) create attribute id 
      current_attribute_id <- build_attributeID(entity_num, att_num, entity_path)
      
      # 3.5) verify that the attribute id is unique across datapackage
      verify_attributeID_isUnique(current_attribute_id = current_attribute_id)
      
      # 3.6) add attribute id to metadata
      entity_path[[entity_num]]$attributeList$attribute[[att_num]]$id <- current_attribute_id
      # message("Added attributeID, '", current_attribute_id, "' to metadata")
      
      # 3.7) create/add property URI to metadata (same for all attributes)
      entity_path[[entity_num]]$attributeList$attribute[[att_num]]$annotation$propertyURI <- list(label = "contains meausurements of",
                                                                                                        propertyURI = "http://ecoinformatics.org/oboe/oboe.1.2/oboe-core.owl#containsMeasurementsOfType")
      
      # 3.8) add value URI to metadata
      current_valueURI <- current_attribute_subset$assigned_valueURI
      current_label <- current_attribute_subset$prefName
      entity_path[[entity_num]]$attributeList$attribute[[att_num]]$annotation$valueURI <- list(label = current_label,
                                                                                                     valueURI = current_valueURI)
      # message("Added semantic annotation URI, '", current_valueURI, "' to metadata for attribute, '", current_attribute_name_from_eml, "'")
      
      annotation_counter <- annotation_counter + 1
      
    } else {
      
      # message("No match was found in the df for the attribute: '", current_attribute_name_from_eml, "'")
      
      next
    }
    
  }
  
  # messaging for mental checks
  print("used 'annotate_attributes() function'")
  attributes_to_annotate <- length(current_entity_subset$attributeName)
  message("Processed entity: ", entity_num, " | ",  current_entityName_from_eml)
  message("Attributes in Metadata -> ", num_attributes_in_eml_entity, " | attributes to annotate -> ", attributes_to_annotate, " | Added -> ", annotation_counter, " | Complete -> ", (attributes_to_annotate == annotation_counter))
  message("*****************************************************")

  return(doc)
}


##############################
# annotated attributes from UNPACKED entities (i.e. when there is only ONE entity present and it's elements are not collapsed inside a nested list)
##############################

annotate_attributes_unpacked <- function(doc, current_entityName_from_eml, num_attributes_in_eml_entity, current_entity_subset, entity_path){
  
  annotation_counter <- 0
  
  for(att_num in 1:num_attributes_in_eml_entity){
    
    # 3.1) get attribute from dataTable in eml 
    current_attribute_name_from_eml <- entity_path$attributeList$attribute[[att_num]]$attributeName
    # message("--> Found attribute #", att_num, " : '", current_attribute_name_from_eml, "'")
    
    # 3.2) subset df using current_attribute_name_from_eml 
    current_attribute_subset <- current_entity_subset %>% 
      filter(attributeName == current_attribute_name_from_eml)
    
    # 3.3) if eml attribute exists in df, continue, if not move to next attribute in eml
    if(length(current_attribute_subset$attributeName > 0)){ 
      
      # message("The corresponding attribute to #", att_num, " in the df is: '", current_attribute_subset$attributeName, "'")
      
      # 3.4) create attribute id 
      current_attribute_id <- build_attributeID(entity_num, att_num, entity_path)
      
      # 3.5) verify that the attribute id is unique across datapackage
      verify_attributeID_isUnique(current_attribute_id = current_attribute_id)
      
      # 3.6) add attribute id to metadata
      entity_path$attributeList$attribute[[att_num]]$id <- current_attribute_id
      # message("Added attributeID, '", current_attribute_id, "' to metadata")
      
      # 3.7) create/add property URI to metadata (same for all attributes)
      entity_path$attributeList$attribute[[att_num]]$annotation$propertyURI <- list(label = "contains meausurements of",
                                                                                    propertyURI = "http://ecoinformatics.org/oboe/oboe.1.2/oboe-core.owl#containsMeasurementsOfType")
      
      # 3.8) add value URI to metadata
      current_valueURI <- current_attribute_subset$assigned_valueURI
      current_label <- current_attribute_subset$prefName
      entity_path$attributeList$attribute[[att_num]]$annotation$valueURI <- list(label = current_label,
                                                                                 valueURI = current_valueURI)
      
      # message("Added semantic annotation URI, '", current_valueURI, "' to metadata for attribute, '", current_attribute_name_from_eml, "'")
      
      annotation_counter <- annotation_counter + 1
      
    } else {
      
      # message("No match was found in the df for the attribute: '", current_attribute_name_from_eml, "'")
      
      next
    }
  }
  
  # messaging for mental checks
  print("used 'annotate_attributes_unpacked() function'")
  attributes_to_annotate <- length(current_entity_subset$attributeName)
  message("Processed entity: 1 (only one) | ",  current_entityName_from_eml)
  message("Attributes in Metadata -> ", num_attributes_in_eml_entity, " | attributes to annotate -> ", attributes_to_annotate, " | Added -> ", annotation_counter, " | Complete -> ", (attributes_to_annotate == annotation_counter))
  message("*****************************************************")
  
  return(doc)
}
