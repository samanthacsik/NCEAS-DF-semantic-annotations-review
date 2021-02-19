##############################
# process & annotate dataTables
  # doc: eml metadata
  # dataTable_or_otherEntity: character string, "dataTable" or "otherEntity"
  # all_entities_byType (previously called `all_named_entities`): a path to the appropriate entity location in the doc (doc$dataset$dataTable, or doc$dataset$otherEntity)
##############################

process_entities_by_type <- function(doc, dataTable_or_otherEntity, all_entities_byType){
  
  is_single_entity <- isTRUE(is.character(all_entities_byType[[1]]))
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # FIRST OPTION: if multiple dataTables or otherEntities present (i.e. if `single_entity` == FALSE)
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
  if(isFALSE(is_single_entity)){
    
    for(entity_num in 1:length(all_entities_byType)){
      
      doc <- annotate_attributes(doc,
                                 entity_num,
                                 dataTable_or_otherEntity,
                                 all_entities_byType[[entity_num]], # current_eml_entity
                                 is_single_entity) 
    }
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # SECOND OPTION: if a single, unpacked dataTable or otherEntity present (i.e. if `single_entity` == TRUE)
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
  } else if(is_single_entity){
    
    doc <- annotate_attributes(doc,
                               0,
                               dataTable_or_otherEntity,
                               all_entities_byType, # current_eml_entity
                               is_single_entity) 
  }
  
  return(doc)
}
