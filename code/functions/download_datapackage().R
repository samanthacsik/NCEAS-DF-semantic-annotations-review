##############################
# download datapackage
  # dp_num: index
  # unique_datapackage_ids: vector of metadata pids
  # attributes: df of attributes to annotate (includes: metadata pid, entityName, attributeName, assigned_valueURI, prefName)
##############################

download_datapackage <- function(dp_num, unique_datapackage_ids, attributes){
  
  # subset 'attributes' df for current datapackage
  current_datapackage_id <- unique_datapackage_ids[dp_num]
  current_datapackage_subset <- attributes %>% 
    dplyr::filter(identifier == current_datapackage_id) 
  message("Subsetted semantic annotation df for datapackage: ", current_datapackage_id)
  
  # get metadata 
  step1_list <- get_datapackage_metadata(current_datapackage_id)
  
  # parse outputs
  current_pkg <- step1_list[[1]]
  current_metadata_pid <- step1_list[[2]]
  doc <- step1_list[[3]]
  
  # add current_pkg to list for storage
  list_of_pkgs_to_publish_update[[dp_num]] <- current_pkg
  names(list_of_pkgs_to_publish_update)[[dp_num]] <- current_metadata_pid

  message("--------------DataPackage ", dp_num, " (", current_datapackage_id, ") has been added to the list--------------")
  
  outputs <- list(doc, current_datapackage_subset, current_datapackage_id)
  
  return(outputs)
  
}

