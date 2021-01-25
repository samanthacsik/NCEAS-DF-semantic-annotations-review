# title: identify remainder datapackage types (semi-automated)
# author: "Sam Csik"
# date created: "2021-01-15"
# date edited: "2021-01-19"
# R version: 3.6.3
# input: "data/outputs/attributes_parents_child_labeled_2020-01-17_script10c.csv"
# output: "data/outputs/CURRENTLY_UNSORTED_PKGS_2020-01-17_script10c.csv" & "data/outputs/attributes_parents_child_labeled_2020-01-17_script10c.csv"


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

# import data
attributes <- read_csv(here::here("data", "outputs", "attributes_parents_child_labeled_2020-01-13.csv")) 
length(unique(attributes$identifier)) # 1092 (these do not include lter 'pasta') 

# get token reminder
# options(dataone_test_token = "...")

# set nodes
d1c_prod <- dataone::D1Client("PROD", "urn:node:ARCTIC") 

# load custom functions
source(here::here("code", "10a_automate_semAnnotations_functions.R"))

##############################
# filter out pkgs that have already been assessed; MANUALLY assessed the landing pages remaining datapackages (first 85) using the 'viewURL' 
# NOTE: there are A LOT (784) left; looked for parent packages that have MANY nested children of that I came across frequently within the first 85 datapackage ids; save those parent metadata pids to run through same pipeline as in script '10c_identify_child_pkgs.R'; label children accordingly in the main df ('attributes)
##############################

# filter out packages that we've already labeled
remainder_pkgs <- attributes %>% 
  filter(is.na(package_type)) %>% 
  select(identifier, viewURL) %>% 
  distinct(identifier, viewURL)

# verify number remaining
length(unique(remainder_pkgs$identifier)) # 784 (these are either child or standalone packages)
# unique_remainder_pkgs <- unique(remainder_pkgs$identifier)

# write to csv for manually analysis
# write_csv(remainder_pkgs, here::here("data", "outputs", "unique_remainders.csv")) 

##############################
# manually searched for the first 85 packages; got a couple parent packages with many nested child packages; going to run those thorugh the pipeline from script "...", which extracts child pids 
##############################

# parent packages to extract child pids from: 
unique_datapackage_ids <- c("doi:10.18739/A2MK65900", "doi:10.18739/A2RJ48V9W", "doi:10.18739/A2F76677W", "doi:10.18739/A2319S373", "doi:10.18739/A2JS9H846", "doi:10.18739/A2TM7221P", "doi:10.18739/A2BV79W4V", "doi:10.18739/A2W950P44", "doi:10.18739/A2C824F7Z", "doi:10.18739/A2MK65900", "doi:10.18739/A2N29P731")

# create empty hash to store results in -- do not rerun unless you want to start process over
results_hash <- new.env(hash = TRUE)

# get child rms from the 11 unique_datapackage_ids (also saves the parent datapackge info)
for(i in 1:length(unique_datapackage_ids)){
  process_package(i, unique_datapackage_ids)
}

##############################
# extract child pids from hash and add all results to 'all_results_df'
##############################

all_results_df <- data.frame(child_rm = as.character(),
                             parent_rm = as.character(),
                             parent_metadata_pid = as.character(),
                             stringsAsFactors = FALSE)

for(i in 1:length(unique_datapackage_ids)){
  all_results_df <- process_results(results_hash[[as.character(i)]], all_results_df)
}

# fix col headers (not sure why this keeps happening)
all_results_df_reordered <- all_results_df %>% 
  rename(child_rm = parent_metadata_pid,
         parent_rm = child_rm,
         parent_metadata_pid = parent_rm) %>% 
  select(child_rm, parent_rm, parent_metadata_pid)

##############################
# use child resource maps (found in 'all_results_df') to download corresponding child packages; this is necessary to extract metadata pids for each child package, which then can be matched with the 'identifier' column in the original 'attributes' df ('attributes_parents_child_labeled_2020-01-13.csv')
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
# join child_pkg_df and all_results_df_reordered to preserve parent metadata pids and rms; rename 'child_metadata_pid' to identifier so that it can be joined with 'attributes' df
# NOTE: 'df' below includes ALL child packages of the 11 parent packages; not all of these child packages may exist in the 'attributes' df
##############################

df <- full_join(all_results_df_reordered, child_pkg_df) %>% 
  mutate(package_type = rep("child")) %>% 
  rename(identifier = child_metadata_pid) %>% 
  distinct(child_rm, parent_rm, parent_metadata_pid, identifier, package_type)
length(unique(df$identifier)) # 222

##############################
# join child pkg information with original 'attributes' df; NOTE there are some child packages that aren't going to be annotated -- make sure to identify and remove these
##############################

# packages that have already been sorted
sorted_attributes <- attributes %>% 
  filter(package_type %in% c("child", "parent"))
length(unique(sorted_attributes$identifier)) # 308

# packages that have not yet been sorted (remove cols that can cause conflict when joining)
unsorted_attributes <- attributes %>% 
  filter(is.na(package_type)) %>% 
  select(-package_type, -child_rm, -parent_rm, -parent_metadata_pid)
length(unique(unsorted_attributes$identifier)) # 784

# join (and remove the 41 child packages that don't have matches in my 'attributes' df)
attributes_new <- full_join(unsorted_attributes, df) %>% 
  filter(!is.na(attributeName)) 

newest_sorted_attributes <- attributes_new %>% 
  filter(package_type == "child")
length(unique(newest_sorted_attributes$identifier)) # 181 new child packages identified

# # find child pkgs that don't have any attributes to annotate
# difference <- anti_join(attributes_new, attributes)
# 
# # remove those child pkgs from the joined attributes/df data frame
# attributes_child_pkgs <- anti_join(attributes_new, difference)

##############################
# combine all currently sorted datapackages
##############################

# add together sorted_attributes and newest_sorted_attributes 
CURRENTLY_SORTED_DATAPACKAGES <- rbind(sorted_attributes, newest_sorted_attributes)
length(unique(CURRENTLY_SORTED_DATAPACKAGES$identifier)) # 489

##############################
# isolate remaining unsorted datapackages (should be 603 total) 
# (originally found 308 pkgs in script 10c, then 181 in this script, 10e, for total 489 sorted datapackage)
##############################

ids_sorted <- CURRENTLY_SORTED_DATAPACKAGES %>% 
  select(identifier) %>% 
  distinct(identifier) # 489
ids_sorted_vec <- ids_sorted$identifier

ids_all <- attributes %>% 
  select(identifier) %>% 
  distinct(identifier) # 1092

ids_unsorted <- anti_join(ids_all, ids_sorted) # 603
ids_unsorted_vec <- ids_unsorted$identifier

##############################
# update `attributes`` df
##############################

# label unsorted pkgs 
CURRENTLY_UNSORTED_DATAPACKAGES <- attributes %>% 
  filter(identifier %in% ids_unsorted_vec) %>% 
  select(-package_type) %>% 
  mutate(package_type = rep("unsorted"))
length(unique(CURRENTLY_UNSORTED_DATAPACKAGES$identifier)) # 603

UNIQUE_CURRENTLY_UNSORTED_DATAPACKAGES <- CURRENTLY_UNSORTED_DATAPACKAGES %>% 
  distinct(identifier, viewURL)

# write_csv(UNIQUE_CURRENTLY_UNSORTED_DATAPACKAGES, here::here("data", "outputs", "CURRENTLY_UNSORTED_PKGS_2020-01-17_script10c.csv"))

# recombine unsorted pkgs and sorted pkgs
attributes_updated <- rbind(CURRENTLY_SORTED_DATAPACKAGES, CURRENTLY_UNSORTED_DATAPACKAGES)
length(unique(attributes_updated$identifier))

# write_csv(attributes_updated, here::here("data", "outputs", "attributes_parents_child_labeled_2020-01-17_script10c.csv"))
