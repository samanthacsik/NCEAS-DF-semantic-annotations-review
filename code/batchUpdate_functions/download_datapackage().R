##############################
# download datapackage
  # dp_num: index
  # unique_datapackage_ids: vector of metadata pids
  # attributes: df of attributes to annotate (includes: metadata pid, entityName, attributeName, assigned_valueURI, prefName)
##############################

download_datapackage <- function(dp_num, unique_datapackage_ids, attributes){
  
  # subset 'attributes' df for current datapackage; NOTE: current_datapackage_id should == current_metadata_pid generated in 'get_datapackage_metadata()'
  identifier <- unique_datapackage_ids[dp_num] 
  current_datapackage_subset <- attributes %>% 
    dplyr::filter(identifier == identifier) 
  message("Subsetted semantic annotation df for datapackage: ", identifier) 
  
  # get metadata 
  step1_list <- get_datapackage_metadata(identifier) 
  
  # parse outputs
  current_pkg <- step1_list[[1]]
  current_metadata_pid <- step1_list[[2]]
  doc <- step1_list[[3]]
  
  # generate list of items to return (really need to simplify this function so that it's not doing as much...)
  outputs <- list(doc, current_pkg, current_datapackage_subset, current_metadata_pid) 
  
  return(outputs)
  
}

