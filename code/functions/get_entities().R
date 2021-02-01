##############################
# get entities (dataTables & otherEntities) from doc
# dp_num: index
# unique_datapackage_ids: vector of metadata pids
# attributes: df of attributes to annotate (includes: metadata pid, entityName, attributeName, assigned_valueURI, prefName)
##############################

get_entities <- function(doc){
  
  # get dataTables and/or otherEntities from eml file; deal with unpacking issue (STILL NEED TO FIX)
  dataTables_from_metadata <- doc$dataset$dataTable
  if(is.list(dataTables_from_metadata[[1]])){
    message("****This datapackage has ", length(dataTables_from_metadata), " dataTables****")
  } else if(is.character(dataTables_from_metadata[[1]])){
    message("****This datapackage has 1 dataTables****")
    # dummy_dataTable <- eml$dataTable(entityName = "dummy",
    #                                  entityDescription = "dummy placeholder")
    # doc$dataset$dataTable <- list(doc$dataset$dataTable, dummy_otherEntity)
    # message("CREATED DUMMY dataTable TO CIRCUMVENT UNPACKING ISSUE")
  }
  
  otherEntities_from_metadata <- doc$dataset$otherEntity
  if(is.list(otherEntities_from_metadata[[1]])){
    message("****This datapackage has ", length(otherEntities_from_metadata), " otherEntities****")
  } else if(is.character(otherEntities_from_metadata[[1]])){
    message("****This datapackage has 1 otherEntities****")
    # -------------- delete this after testing! -------------- #
    dummy_otherEntity <- eml$otherEntity(entityName = "dummy",
                                         entityDescription = "dummy placeholder")
    otherEntities_from_metadata <- list(doc$dataset$otherEntity, dummy_otherEntity)
    message("CREATED DUMMY otherEntity TO CIRCUMVENT UNPACKING ISSUE")
    # -------------- delete this after testing! -------------- #
  }
  
  message("*****************************************************")
  
  # combine extracted dataTables and/or otherEntities into a single list
  if(isTRUE(length(dataTables_from_metadata) > 0 && length(otherEntities_from_metadata) > 0)){
    all_entities <- list("dataTables" = dataTables_from_metadata, "otherEntities" = otherEntities_from_metadata)
    message("This package has both dataTables & otherEntities")
  } else if(isTRUE(length(dataTables_from_metadata) > 0)){
    all_entities <- list("dataTables" = dataTables_from_metadata)
    message("This package has just dataTables")
  } else if(isTRUE(length(otherEntities_from_metadata) > 0)){
    all_entities <- list("otherEntities" = otherEntities_from_metadata)
    message("This package has just otherEntities")
  }
  
  return(all_entities)
  
}



