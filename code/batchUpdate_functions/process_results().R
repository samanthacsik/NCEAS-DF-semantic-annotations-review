##############################
# combine all results into single 'all_results_df' 
##############################

process_results <- function(result, all_results_df) {
  
  # if value in hash is a type list, it means there is child pkg info that needs to be combined in the 'all_results_df'
  should_process <- (typeof(result) == "list")
  message("**** Should Process: ", should_process, " ****")
  
  if (should_process) {
    all_results_df <- rbind(all_results_df, result)
  }
  
  return(all_results_df)
  
}