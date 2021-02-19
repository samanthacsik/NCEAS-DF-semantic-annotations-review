#############################
#  Extracts eml version (e.g. 2.1.1, 2.2.0) from data objects
##############################

get_eml_version <- function(pkg){
  
  # get data objects from current_pkg
  obj <- pkg@objects
  
  # get names of objects
  keys <- names(obj)
  
  # format_id_version <- NULL
  
  for(i in 1:length(keys)){
    
    # get info for each data object
    data <- obj[[keys[i]]]
    
    # extract formatId of data object 
    formatId <- getFormatId(data)
    
    # if the formatId of the data object matches this string, then split and grab the part containing the version number
    if (str_detect(formatId, "ecoinformatics.org")) {
      format_id_version <- str_split(formatId, "-")[[1]][2]
    }
    
  }
  
  return(format_id_version)
}