##############################
# get entities (dataTables & otherEntities) from doc -- PROVIDES MESSAGING ONLY
# dp_num: index
# unique_datapackage_ids: vector of metadata pids
# attributes: df of attributes to annotate (includes: metadata pid, entityName, attributeName, assigned_valueURI, prefName)
##############################

get_entities <- function(doc){
  
  # get dataTables and/or otherEntities from eml file; deal with unpacking issue (STILL NEED TO FIX)
  dataTables_from_metadata <- doc$dataset$dataTable
  if(is.list(dataTables_from_metadata[[1]])){
    message("****This datapackage has ", length(dataTables_from_metadata), " dataTable(s)****")
  } else if(is.character(dataTables_from_metadata[[1]])){
    message("****This datapackage has 1 dataTable(s)****")
  }
  
  otherEntities_from_metadata <- doc$dataset$otherEntity
  if(is.list(otherEntities_from_metadata[[1]])){
    message("****This datapackage has ", length(otherEntities_from_metadata), " otherEntity(ies)****")
  } else if(is.character(otherEntities_from_metadata[[1]])){
    message("****This datapackage has 1 otherEntity(ies)****")
  }
  
  message("*****************************************************")
  
  # combine extracted dataTables and/or otherEntities into a single list
  # if(isTRUE(length(dataTables_from_metadata) > 0 && length(otherEntities_from_metadata) > 0)){
  #   all_entities <- list("dataTables" = dataTables_from_metadata, "otherEntities" = otherEntities_from_metadata)
  #   message("This package has both dataTables & otherEntities")
  # } else if(isTRUE(length(dataTables_from_metadata) > 0)){
  #   all_entities <- list("dataTables" = dataTables_from_metadata)
  #   message("This package has just dataTables")
  # } else if(isTRUE(length(otherEntities_from_metadata) > 0)){
  #   all_entities <- list("otherEntities" = otherEntities_from_metadata)
  #   message("This package has just otherEntities")
  # }
  
}



