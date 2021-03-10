##############################
# process & annotate dataTables
  # doc: eml metadata
  # dataTable_or_otherEntity: character string, "dataTable" or "otherEntity"
  # all_entities_byType: a path to the appropriate entity location in the doc (doc$dataset$dataTable, or doc$dataset$otherEntity); default is doc$dataset$dataTable
##############################

#' Process and annotate all dataTables and/or otherEntities in an eml metadata document
#'
#' @param doc an EML metadata document
#' @param dataTable_or_otherEntity a character string; either "dataTable" or "otherEntity" specifying which entity type to process
#'
#' @return doc
#' @export
#'
#' @examples

process_entities_by_type <- function(doc, dataTable_or_otherEntity = "dataTable"){ 
  
  all_entities_byType <- doc$dataset$dataTable
  
  if(dataTable_or_otherEntity == "otherEntity"){
    all_entities_byType <- doc$dataset$otherEntity
  }
  
  is_single_entity <- isTRUE(is.character(all_entities_byType[[1]]))
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # FIRST OPTION: if multiple dataTables or otherEntities present (i.e. if `single_entity` == FALSE)
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
  if(isFALSE(is_single_entity)){
    
    for(entity_num in 1:length(all_entities_byType)){
      
      doc <- annotate_attributes(doc,
                                 entity_num,
                                 dataTable_or_otherEntity,
                                 all_entities_byType[[entity_num]],
                                 is_single_entity) 
    }
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # SECOND OPTION: if a single, unpacked dataTable or otherEntity present (i.e. if `single_entity` == TRUE)
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
  } else if(is_single_entity){
    
    doc <- annotate_attributes(doc,
                               1,
                               dataTable_or_otherEntity,
                               all_entities_byType, 
                               is_single_entity) 
  }
  
  return(doc)
}
