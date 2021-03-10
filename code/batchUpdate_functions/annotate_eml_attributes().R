#' Add multiple semantic annotations to an EML document
#'
#' @param doc a value of type "list", an EML metadata document
#'
#' @return doc
#' @export
#'
#' @examples
#' 
#' 

annotate_eml_attributes <- function(doc){
  
  # determine if there are dataTables and/or otherEntities present in the eml doc
  has_dataTables <- isFALSE(is.null(doc$dataset$dataTable))
  message("Has dataTables: ", has_dataTables)
  has_otherEntities <- isFALSE(is.null(doc$dataset$otherEntity))
  message("Has otherEntities: ", has_otherEntities)
  message("*****************************************************")
 
  # process any dataTables
  if(has_dataTables){
    doc <- process_entities_by_type(doc, dataTable_or_otherEntity = "dataTable") 
  } 
  
  # process any otherEntities
  if(has_otherEntities){
    doc <- process_entities_by_type(doc, dataTable_or_otherEntity = "otherEntity") 
  }
  
  return(doc)
  
}