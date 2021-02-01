##############################
# process & annotate (works for pkgs containing BOTH dataTables and otherEntities)
##############################

process_dT_and_oE_and_annotate <- function(all_entities){
  
  # process dataTables
  for(d in 1:length(all_entities$dataTables)){
    message("processing and annotating dataTables")
  }
  
  # process otherEntities
  for(e in 1:length(all_entities$otherEntities)){
    message("processing and annotating otherEntities")
  }
  
  
  
  

}  




  
#   # FIRST OPTION: if muliple entities present
#   if(isTRUE(is.list(all_entities_path[[1]]))){
#   
#   # SECOND OPTION: if a single, unpacked entity present 
#   } else if(isTRUE(is.character(all_entities_path[[1]]))){
#   
# }
#   
# }
