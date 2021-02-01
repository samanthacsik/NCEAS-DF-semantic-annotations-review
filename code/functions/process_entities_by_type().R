##############################
# process & annotate dataTables
  # doc: eml metadata
  # dataTable_or_otherEntity: character string, "dataTable" or "otherEntity"
  # all_named_entities: a path to the appropriate entity location in the doc (doc$dataset$dataTable, or doc$dataset$otherEntity)
##############################

process_entities_by_type <- function(doc, dataTable_or_otherEntity, all_named_entities){
  
  # FIRST OPTION: if muliple dataTables or otherEntities present
  if(isTRUE(is.list(all_named_entities[[1]]))){
    
    for(entity_num in 1:length(all_named_entities)){
      
      doc <- annotate_attributes(doc,
                                 entity_num,
                                 dataTable_or_otherEntity,
                                 all_named_entities[[entity_num]]) 
    }
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    # SECOND OPTION: if a single, unpacked dataTable or otherEntity present 
  } else if(isTRUE(is.character(all_named_entities[[1]]))){
    
    doc <- annotate_attributes_unpacked(doc,
                                        dataTable_or_otherEntity,
                                        all_named_entities) 
  }
  
  return(doc)
}
