##############################
# add results to hash (used in process_package())
##############################

get_result <- function(pkg, parent_rm, parent_metadata_pid) {
  
  results <- NULL
  
  # check to see if there are child packages; if so, save information
  if(length(pkg$child_packages) > 0){
    
    message("**** I have this many child packages: ", length(pkg$child_packages), " ****")
    
    # create empty df to store data in (this df will get stored in a hash for each iteration of the loop)
    results_df <- data.frame(child_rm = as.character(),
                             parent_rm = as.character(),
                             parent_metadata_pid = as.character(),
                             stringsAsFactors=FALSE)
    
    # extract rm for each child package and store in vector along with the associated parent rm
    for(j in 1:length(pkg$child_packages)){
      
      message("extracting rm ", j, " of ", length(pkg$child_packages))
      
      # save child resource map
      child_rm <- pkg$child_packages[[j]]
      
      # put child and parent datapackage rm & pid into vector, then add to empty df, 'results_df'
      stuff <- c(parent_rm, parent_metadata_pid, child_rm) # THIS ORDER IS OFF, should be 'c(child_rm, parent_rm, parent_metadata_pid)'
      # stuff <- c(child_rm, parent_rm, parent_metadata_pid)
      row <- nrow(results_df) + 1
      results_df[row, ] <- stuff
    }
    
    results <- results_df
    
    # if there are not child datapackages associated with the current unique_datapackage_id, add to results_hash as such
  } else {
    message("there are NO child packages")
    results <- "NO CHILD PACKAGES"
  }
  return(results)
}