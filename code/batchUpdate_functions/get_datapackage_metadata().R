# ALL GOOD
##############################
#  load metadata as 'doc'
##############################

get_datapackage_metadata <- function(pkg_identifier){ 
  
  # Use arcticdatautils `get_package()` to get rm pid to use with datapack::getDataPackage
  pkg <- get_package(d1c_prod@mn, 
                     pkg_identifier, # this is actually the metadata pid from solr (will throw a warning but that's okay)
                     file_names = TRUE)
  
  # extract resource map
  resource_pid <-  pkg$resource_map
  
  # get pkg using resource map 
  current_pkg <- getDataPackage(d1c_prod, identifier = resource_pid, lazyLoad = TRUE, quiet = FALSE)
  
  # get eml version for use in 'selectMember()'
  format_id_version <- get_eml_version(pkg = current_pkg) 
  
  # get metadata pid from pkg (this is redundant but leaving in anyways)
  if(isTRUE(str_detect(format_id_version, "2.1.1"))) {
    current_metadata_pid  <- selectMember(current_pkg, name = "sysmeta@formatId", value = "eml://ecoinformatics.org/eml-2.1.1")
    message("eml version 2.1.1")
  } else if(isTRUE(str_detect(format_id_version, "2.2.0"))) {
    current_metadata_pid  <- selectMember(current_pkg, name = "sysmeta@formatId", value = "https://eml.ecoinformatics.org/eml-2.2.0")
    message("eml version 2.2.0")
  } else {
    warning("The eml version of this metadata file is not recognized.")
    print("NOTE FOR SAM: need to figure out how to actually deal with this if it ever comes up")
  }
  
  # read in eml metadata using pid 
  doc <- read_eml(getObject(d1c_prod@mn, current_metadata_pid)) 
  message("Imported eml medatadata for datapackage: ", current_metadata_pid) 
  
  # create list to return
  step1_list <- list(current_pkg, current_metadata_pid, doc)
  
  return(step1_list)
}
