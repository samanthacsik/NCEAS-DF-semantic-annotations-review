# 2 separate functions for packed vs unpacked entities

# need to deal with the following:

# if attributes are present --> annotate; if not present --> skip (next)
# if there are multiple attributes in the current entitiy (packed) vs. if there is a single attribute in the current entity (unpacked) 
# if you are working with dataTables vs. otherEntities





annotate_attributes <- function(doc, entity_num, dataTable_or_otherEntity, current_eml_entity){ 
  
  # message("working on: ", entity_num, " for: ", dataTable_or_otherEntity)
  
  # ---------------------------------------------------------------------------------------------
  # Setup; get entity-specific data
  # ---------------------------------------------------------------------------------------------
  
  # initiate annotation counter to track number of annotations added to doc
  annotation_counter <- 0
  
  # get current dataTable or otherEntity name from eml metadata; determine how many attributes exist in the eml entity
  current_entityName_from_eml <- current_eml_entity$entityName
  num_attributes_in_eml_entity <- length(current_eml_entity$attributeList$attribute)
  
  # subset 'current_datapackage_subset' accordingly
  current_entity_subset <- current_datapackage_subset %>%
    filter(entityName == current_entityName_from_eml)
  
  # ---------------------------------------------------------------------------------------------
  # get attributes from eml and find matches in df 
  # ---------------------------------------------------------------------------------------------
  
  for(att_num in 1:num_attributes_in_eml_entity){
    
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # if there are multiple attributes in current entity, do this:
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if(isTRUE(is.list(current_eml_entity$attributeList$attribute[[1]]))){
      
      # get attributeName fom entity in eml
      current_attribute_name_from_eml <- current_eml_entity$attributeList$attribute[[att_num]]$attributeName
      # message("--> Found attribute #", att_num, " : '", current_attribute_name_from_eml, "'")
      
      # subset df using current_attribute_name_from_eml
      current_attribute_subset <- current_entity_subset %>%
        filter(attributeName == current_attribute_name_from_eml)
      
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # if there is only one attribute in current entity, do this instead: 
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    } else if(isTRUE(is.character(current_eml_entity$attributeList$attribute[[1]]))){
      
      # get attributeName fom entity in eml
      current_attribute_name_from_eml <- current_eml_entity$attributeList$attribute$attributeName
      # message("--> Found attribute #", att_num, " : '", current_attribute_name_from_eml, "'")
      
      # subset df using current_attribute_name_from_eml
      current_attribute_subset <- current_entity_subset %>%
        filter(attributeName == current_attribute_name_from_eml)
    }
    
    #---------------------------------------------------------------------------------------------
    # if eml attribute exists in df, continue, if not move to next attribute in eml
    #---------------------------------------------------------------------------------------------
    
    if(length(current_attribute_subset$attributeName > 0)){
      # message("The corresponding attribute to #", att_num, " in the df is: '", current_attribute_subset$attributeName, "'")
      
      # create attribute id using entity index (entity_num) and attributeName from eml
      current_attribute_id <- build_attributeID(entity_num, att_num, eml_get(doc$dataset, dataTable_or_otherEntity))
      
      # verify that the attribute id is unique across datapackage
      verify_attributeID_isUnique(current_attribute_id = current_attribute_id)
      
      #---------------------------------------------------------------------------------------------
      # add semantic annotation elements to dataTables
      #---------------------------------------------------------------------------------------------
      
      if (dataTable_or_otherEntity == 'dataTable') {
        
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        # if multiple attributes exist in the current dataTable, do this:
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        
        if(isTRUE(is.list(doc$dataset$dataTable$attributeList$attribute[[1]]))){
          
          # add attribute id to metadata
          doc$dataset$dataTable[[entity_num]]$attributeList$attribute[[att_num]]$id <- current_attribute_id
          # message("Added attributeID, '", current_attribute_id, "' to metadata")
          
          # add property URI to metadata (this is the same for all attributes)
          containsMeasurementsofType <- "http://ecoinformatics.org/oboe/oboe.1.2/oboe-core.owl#containsMeasurementsOfType"
          doc$dataset$dataTable[[entity_num]]$attributeList$attribute[[att_num]]$annotation$propertyURI <- list(label = "contains meausurements of",
                                                                                                                propertyURI = containsMeasurementsofType)
          
          # add value URI to metadata
          current_valueURI <- current_attribute_subset$assigned_valueURI
          current_label <- current_attribute_subset$prefName
          doc$dataset$dataTable[[entity_num]]$attributeList$attribute[[att_num]]$annotation$valueURI <- list(label = current_label,
                                                                                                             valueURI = current_valueURI)
          # message("Added semantic annotation URI, '", current_valueURI, "' to metadata for attribute, '", current_attribute_name_from_eml, "'")
          
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          # if a single (unpacked) attribute exists in the current dataTable, do this instead:
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          
        } else if(isTRUE(is.character(doc$dataset$dataTable$attributeList$attribute[[1]]))){
          
          # add attribute id to metadata
          doc$dataset$dataTable[[entity_num]]$attributeList$attribute$id <- current_attribute_id
          # message("Added attributeID, '", current_attribute_id, "' to metadata")
          
          # add property URI to metadata (this is the same for all attributes)
          containsMeasurementsofType <- "http://ecoinformatics.org/oboe/oboe.1.2/oboe-core.owl#containsMeasurementsOfType"
          doc$dataset$dataTable[[entity_num]]$attributeList$attribute$annotation$propertyURI <- list(label = "contains meausurements of",
                                                                                                     propertyURI = containsMeasurementsofType)
          
          # add value URI to metadata
          current_valueURI <- current_attribute_subset$assigned_valueURI
          current_label <- current_attribute_subset$prefName
          doc$dataset$dataTable[[entity_num]]$attributeList$attribute$annotation$valueURI <- list(label = current_label,
                                                                                                  valueURI = current_valueURI)
          # message("Added semantic annotation URI, '", current_valueURI, "' to metadata for attribute, '", current_attribute_name_from_eml, "'")
          
        }
        
        #---------------------------------------------------------------------------------------------
        # add semantic annotation elements to otherEntities
        #---------------------------------------------------------------------------------------------
        
      } else {
        
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        # if multiple attributes exist in the current otherEntity, do this:
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        
        if(isTRUE(is.list(doc$dataset$otherEntity$attributeList$attribute[[1]]))){
          
          doc$dataset$otherEntity[[entity_num]]$attributeList$attribute[[att_num]]$id <- current_attribute_id
          # message("Added attributeID, '", current_attribute_id, "' to metadata")
          
          # create/add property URI to metadata (same for all attributes)
          containsMeasurementsofType <- "http://ecoinformatics.org/oboe/oboe.1.2/oboe-core.owl#containsMeasurementsOfType"
          doc$dataset$otherEntity[[entity_num]]$attributeList$attribute[[att_num]]$annotation$propertyURI <- list(label = "contains meausurements of",
                                                                                                                  propertyURI = containsMeasurementsofType)
          # add value URI to metadata
          current_valueURI <- current_attribute_subset$assigned_valueURI
          current_label <- current_attribute_subset$prefName
          doc$dataset$otherEntity[[entity_num]]$attributeList$attribute[[att_num]]$annotation$valueURI <- list(label = current_label,
                                                                                                               valueURI = current_valueURI)
          # message("Added semantic annotation URI, '", current_valueURI, "' to metadata for attribute, '", current_attribute_name_from_eml, "'")
          
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          # if a single (unpacked) attribute exists in the current otherEntity do this instead:
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          
        } else if(isTRUE(is.character(doc$dataset$otherEntity$attributeList$attribute[[1]]))){
          
          doc$dataset$otherEntity[[entity_num]]$attributeList$attribute$id <- current_attribute_id
          # message("Added attributeID, '", current_attribute_id, "' to metadata")
          
          # create/add property URI to metadata (same for all attributes)
          containsMeasurementsofType <- "http://ecoinformatics.org/oboe/oboe.1.2/oboe-core.owl#containsMeasurementsOfType"
          doc$dataset$otherEntity[[entity_num]]$attributeList$attribute$annotation$propertyURI <- list(label = "contains meausurements of",
                                                                                                       propertyURI = containsMeasurementsofType)
          # add value URI to metadata
          current_valueURI <- current_attribute_subset$assigned_valueURI
          current_label <- current_attribute_subset$prefName
          doc$dataset$otherEntity[[entity_num]]$attributeList$attribute$annotation$valueURI <- list(label = current_label,
                                                                                                    valueURI = current_valueURI)
          # message("Added semantic annotation URI, '", current_valueURI, "' to metadata for attribute, '", current_attribute_name_from_eml, "'")
          
        }
        
      }
      
      annotation_counter <- annotation_counter + 1
      
    } else {
      
      # message("No match was found in the df for the attribute: '", current_attribute_name_from_eml, "'")
      
      next
    }
    
  }
  
  # messaging for mental checks
  attributes_to_annotate <- length(current_entity_subset$attributeName)
  message("Processed entity: ", entity_num, " | ",  current_entityName_from_eml)
  message("Attributes in Metadata -> ", num_attributes_in_eml_entity, " | attributes to annotate -> ", attributes_to_annotate, " | Added -> ", annotation_counter, " | Complete -> ", (attributes_to_annotate == annotation_counter))
  message("*****************************************************")
  
  return(doc)
  
}
