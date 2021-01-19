# title: identify child datapackages ROUND 2 (MANUAL ROUND 1) 
# author: "Sam Csik"
# date created: "2021-01-15"
# date edited: "2021-01-15"
# R version: 3.6.3
# input: "data/outputs/annotate_these_attributes_2020-12-17_webscraped.csv" 
# output: "data/outputs/annotate_these_attributes_2020-12-17_webscraped.csv"

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

source(here::here("code", "10a_automate_semAnnotations_functions.R"))

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
                             stringsAsFactors = FALSE)

for(i in 1:length(unique_datapackage_ids)){
  all_results_df <- process_results(results_hash[[as.character(i)]], all_results_df)
}

# had to fix col headers bc I messed up order when adding results to df (fixed now though so next time code above is run, it should all be correct...)
all_results_df_reordered <- all_results_df %>% 
  rename(child_rm = parent_metadata_pid,
         parent_rm = child_rm,
         parent_metadata_pid = parent_rm) %>% 
  select(child_rm, parent_rm, parent_metadata_pid)

##############################
# use child resource maps to download corresponding child packages; extract metadata pids for each child package (these can also be used to full_join with 'attributes' df)
##############################

# get child rm from df above
unique_child_rm <- all_results_df_reordered$child_rm

# create empty df to store child metadata pids in, along with their resource maps
child_pkg_df <- data.frame(child_rm = as.character(), 
                           child_metadata_pid = as.character(),
                           stringsAsFactors = FALSE)

# use resource maps in `children` to download packages and extract metadata pics
for(i in 1:length(unique_child_rm)){

  message("downloading child package ", i, " and extracting metadata pid...")

  # download package
  pkg <- get_package(d1c_prod@mn,
                     unique_child_rm[i],
                     file_names = TRUE)

  # extract metadata pid from child pkg and also save rm to join back with 'all_results_df'
  # child_metadata_pids[i] <-  pkg$metadata
  child_metadata_pid <- pkg$metadata
  child_rm <- unique_child_rm[i]
  stuff <- c(child_rm, as.character(child_metadata_pid))
  print(stuff)
  
  # add to empty 'child_pkg_df'
  row <- nrow(child_pkg_df) + 1
  child_pkg_df[row, ] <- stuff

}

##############################
# join child_pkg_df and all_results_df_reordered; rename 'child_metadata_pid' to identifier so that it can be joined with 'attributes' df
##############################

df <- full_join(all_results_df_reordered, child_pkg_df) %>% 
  mutate(package_type = rep("child")) %>% 
  rename(identifier = child_metadata_pid)

##############################
# join child pkg information with original 'attributes' df; NOTE there are some child packages that aren't going to be annotated -- make sure to identify and remove these
##############################

# join
attributes_new <- full_join(attributes, df)

# find child pkgs that don't have any attributes to annotate
difference <- anti_join(attributes_new, attributes)

# remove those child pkgs from the joined attributes/df data frame
attributes_child_pkgs <- anti_join(attributes_new, difference)

# write.csv(attributes_child_pkgs, here::here("data", "outputs", "attributes_child_pkgs_identified_2020-01-13.csv"))

