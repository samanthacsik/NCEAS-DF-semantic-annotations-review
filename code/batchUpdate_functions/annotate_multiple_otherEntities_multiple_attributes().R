annotate_multiple_otherEntities_multiple_attributes <- function(doc, entity_num, eml_att_num, current_attribute_id, attributeName_subset){
 
  # add attribute id to metadata
  doc$dataset$otherEntity[[entity_num]]$attributeList$attribute[[eml_att_num]]$id <- current_attribute_id
  # message("Added attributeID, '", current_attribute_id, "' to metadata")
  
  # add property URI to metadata (this is the same for all attributes)
  containsMeasurementsofType <- "http://ecoinformatics.org/oboe/oboe.1.2/oboe-core.owl#containsMeasurementsOfType"
  doc$dataset$otherEntity[[entity_num]]$attributeList$attribute[[eml_att_num]]$annotation$propertyURI <- list(label = "contains meausurements of",
                                                                                                              propertyURI = containsMeasurementsofType)
  
  # add value URI to metadata
  current_valueURI <- attributeName_subset$assigned_valueURI
  current_label <- attributeName_subset$prefName
  doc$dataset$otherEntity[[entity_num]]$attributeList$attribute[[eml_att_num]]$annotation$valueURI <- list(label = current_label,
                                                                                                           valueURI = current_valueURI)
  # message("Added semantic annotation URI, '", current_valueURI, "' to metadata for attribute, '", current_attribute_name_from_eml, "'")
  
  return(doc)
}

