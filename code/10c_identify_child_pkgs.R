# determine child datapackages


##############################
# General Setup
##############################

# load packages
library(dataone)
library(datapack)
library(arcticdatautils) 
library(EML)
library(uuid)
library(tryCatchLog)
library(futile.logger) 
library(tidyverse)

# reminder to get token! (arctic.io)

# set nodes 
d1c_prod <- dataone::D1Client("PROD", "urn:node:ARCTIC") 

##############################
# import data (removing lter data, 364 datapackages)
##############################

attributes <- read_csv(here::here("data", "outputs", "annotate_these_attributes_2020-12-17_webscraped.csv")) %>% 
  filter(!str_detect(identifier, "(?i)https://pasta.lternet.edu"))

##############################
# functions
##############################

# download package (using arcticdatautils::get_package()) and add results to hash
process_package <- function(index, unique_datapackage_ids) {
  message("**** Working on datapackage ", index, " of ", length(unique_datapackage_ids), " ****")
  
  has_existing_result <- !is.null(results_hash[[as.character(index)]])
  # should_skip <- index != 786
  message("**** Has Existing Result: ", has_existing_result, " ****")
  # message("**** Should Skip: ", should_skip, " ****")
  
  # if the datapackage at index has already been stored in the hash, don't rerun (allows us to pick back up where we left off if error halts processes)
  if(has_existing_result) { # || should_skip
    message("**** Skipping: ", index, " ****")
    return()
  }
  
  # get package using its metadata pid (i.e. the 'identifier' from the 'attributes' df)
  pkg <- get_package(d1c_prod@mn,
                     unique_datapackage_ids[index],
                     file_names = TRUE)
  
  results_hash[[as.character(index)]] <- get_result(pkg, pkg$resource_map, unique_datapackage_ids[index])
}

# add results to hash (used in process_package() above)
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
      stuff <- c(parent_rm, parent_metadata_pid, child_rm)
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

# combine all results into single 'all_results_df' 
process_results <- function(result, all_results_df) {
  
  # if value in hash is a type list, it means there is child pkg info that needs to be combined in the 'all_results_df'
  should_process <- (typeof(result) == "list")
  message("**** Should Process: ", should_process, " ****")
  
  if (should_process) {
    all_results_df <- rbind(all_results_df, result)
  }
  
  return(all_results_df)
  
}

##############################
# get unique datapackage ids (i.e. metadata pids)
##############################

# get unique packages to be annotated
unique_datapackage_ids <- unique(attributes$identifier)

##############################
# for each unique package identifier (these are metadata pids) that I have, check to see if any have child packages associated with them
# if so, add the resource maps for those child packages (along with the rm and metadata pid of it's associated parent) to a df called 'results_df'
##############################

# create empty hash to store results in -- do not rerun unless you want to start process over
results_hash <- new.env(hash = TRUE)

# get child rms and their associated parent rms
for(i in 1:length(unique_datapackage_ids)){
  process_package(i, unique_datapackage_ids)
}

##############################
# Iterate over all unique_datapackage_ids, grab the result from the result hash, and append to a df if possible
##############################

all_results_df <- data.frame(child_rm = as.character(),
                             parent_rm = as.character(),
                             parent_metadata_pid = as.character(),
                             stringsAsFactors=FALSE)

for(i in 1:length(unique_datapackage_ids)){
  all_results_df <- process_results(results_hash[[as.character(i)]], all_results_df)
}

##############################
# use 'child_rm' to download corresponding child packages; extract metadata pids for each child package (these will be used to full_join with 'attributes' df)
##############################

# # create empty vector to store child metadata pids in
# child_metadata_pids <- c()
# 
# # use resource maps in `children` to download packages and extract metadata pics
# for(i in 1:length(child_rm)){
#   
#   message("downloading child package ", i, " and extracting metadata pid...")
#   
#   # download package
#   pkg <- get_package(d1c_prod@mn, 
#                      child_rm[i], 
#                      file_names = TRUE)
#   
#   # extract metadata pid from child pkg
#   child_metadata_pids[i] <-  pkg$metadata
#   
# }




















####################################### saving just in case ########################################

# # doi:10.18739/A2RJ48V9W (know we have a lot of its child pkgs in 'attributes' df)
# parent_pkg_test <- get_package(d1c_prod@mn,
#                                "doi:10.18739/A2RJ48V9W", # metadata pid
#                                file_names = TRUE)
# 
# # child packages stored here
# children_of_doi.10.18739.A2RJ48V9W <- parent_pkg_test$child_packages
# 
# # create empty vector to store child resource maps in
# child_rm <- c()
# 
# # extract rm for each child package
# for(i in 1:length(children_of_doi.10.18739.A2RJ48V9W)){
#   child_rm[i] <- children_of_doi.10.18739.A2RJ48V9W[[i]]
# }
# 
# # create empty vector to store child metadata pids in
# child_metadata_pids <- c()
# 
# # use resource maps in `children` to download packages and extract metadata pics
# for(i in 1:length(child_rm)){
#   
#   message("downloading child package ", i, "...")
#   
#   # download package
#   pkg <- get_package(d1c_prod@mn, 
#                      child_rm[i], 
#                      file_names = TRUE)
#   
#   # extract metadata pic from child pkg
#   child_metadata_pids[i] <-  pkg$metadata
#   
# }
# 
# # match metadata pids with those in 'attributes' df to label them as child packages
# identifier <- child_metadata_pids
# pkg_type <- rep(c("child"), times = 104)
# parent_pkg_rm <- rep(c("doi:10.18739/A2RJ48V9W"), times = 104)
# 
# MP_children_of_doi.10.18739.A2RJ48V9W <- data.frame(identifier, type, parent_pkg_rm)
# 
# attributes_new <- full_join(attributes, MP_children_of_doi.10.18739.A2RJ48V9W)
