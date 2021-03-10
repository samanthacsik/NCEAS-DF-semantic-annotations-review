#' Download datapackage and EML; filter solr query attributes df for corresponding data
#'
#' @param pkg_identifier a character string; package metadata pid, which is called 'identifier' in solr query
#' @param attributes df of attributes to annotate (includes: metadata pid, entityName, attributeName, assigned_valueURI, prefName)
#'
#' @return a list, 'outputs,' containing 4 objects; metadata doc, pkg, datapackage subset, metadata pid
#' @export
#'
#' @examples


download_pkg_filter_data <- function(pkg_identifier, attributes){
  
  # subset 'attributes' df for current datapackage; NOTE: current_datapackage_id should == current_metadata_pid generated in 'get_datapackage_metadata()'
  current_datapackage_subset <- attributes %>% 
    dplyr::filter(identifier == pkg_identifier) 
  message("Subsetted semantic annotation df for datapackage: ", pkg_identifier) 
  
  # get metadata 
  step1_list <- get_datapackage_metadata(pkg_identifier) 
  
  # parse outputs
  current_pkg <- step1_list[[1]]
  current_metadata_pid <- step1_list[[2]]
  doc <- step1_list[[3]]
  
  # generate list of items to return (really need to simplify this function so that it's not doing as much...)
  outputs <- list(doc, current_pkg, current_datapackage_subset, current_metadata_pid) 
  
  return(outputs)
  
}

