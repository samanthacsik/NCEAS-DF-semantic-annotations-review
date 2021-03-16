# title: Determine size of datapackages for batch update planning
# author: "Sam Csik"
# date created: "2021-03-11"
# date edited: "2021-03-12"
# R version: 3.6.3
# input: "data/outputs/attributes_to_annotate"/all_attributes_to_annotate_sorted_by_pkgType_2020-01-19.csv" 
# output: "data/pkg_sizes/all_pkg_sizes.csv"

##########################################################################################
# Summary
##########################################################################################

# Extract number of datasets associated with each datapackage so that we can divide up batch update runs appropriately (e.g. really large datapackges can be run individually while small datapackages can be processed in the same run)
# package_types: standalone, child, parent, WEIRD, MULTINESTING, too long to load

# Packages have been grouped according to the following (see .csv files in data/pkg_sizes/*): standaloneDOI, standaloneUUID, childDOI, childUUID, parentDOI, WEIRDDOI, WEIRDUUID, 

##########################################################################################
# General setup
##########################################################################################

##############################
# load packages
##############################

library(tidyverse)

##############################
# get token, set nodes
##############################

d1c_prod <- dataone::D1Client("PROD", "urn:node:ARCTIC")

##############################
# read in data
##############################

attributes <- read_csv(here::here("data", "outputs", "attributes_to_annotate", "all_attributes_to_annotate_sorted_by_pkgType_2020-01-19.csv"),
                       col_types = cols(.default = col_character()))

##############################
# subset -- CHANGE THIS DEPENDING ON WHICH SUBSET YOU WANT PACKAGE SIZES FOR
##############################

attributes <- attributes %>% 
  filter(package_type == "CHANGE THIS HERE",        
         str_detect(identifier, "(?i)doi"))

length(unique(attributes$identifier))

##############################
# get vector of unique IDs and initialize empty df to populate with metadataPIDs & number of associated datasets
##############################

# vector of unique metadata pids
unique_ids <- unique(attributes$identifier)

# initialize empty df for storing metadata pids and corresponding number of datasets
pkg_sizes <- data.frame(metadataPID = as.character(),
                        num_datasets = as.numeric())

##########################################################################################
# get number of datasets in each pkg
##########################################################################################

for(i in 1:length(unique_ids)){
  
  # get metadataPID
  id <- unique_ids[[i]]
  message("-----------------------")
  message("Starting package ", i, ": ", id)
  
  # get package
  pkg <- get_package(d1c_prod@mn, 
                     id, 
                     file_names = TRUE)
  
  # get the number of datasets in that package & the metadata pid
  num_datasets <- length(pkg$data)
  extracted_metadataPID <- pkg$metadata
  message("Package ", extracted_metadataPID, " has ", num_datasets, " datasets.")
  
  # add to df
  temp <- data.frame(metadataPID = extracted_metadataPID,
                     num_datasets = num_datasets)
  
  pkg_sizes <- rbind(pkg_sizes, temp)
  message("Added infomation to the df. Moving to next package...")
  
}

##############################
# clean up df
##############################

pkg_sizes_clean <- pkg_sizes %>% 
  rownames_to_column("xml_name") %>% 
  select(metadataPID, num_datasets)

##############################
# save as .csv to 'data/pkg_sizes/*'
##############################

# write_csv(pkg_sizes_clean, here::here("data", "pkg_sizes", "tooLongToLoadDOI_pkg_sizes.csv"))

##########################################################################################
# combine individual subsets and save as .csv
##########################################################################################

standaloneDOI <- read_csv(here::here("data", "pkg_sizes", "standaloneDOI_pkg_sizes.csv")) %>% mutate(update_cat = rep("standaloneDOI"))
standaloneUUID <- read_csv(here::here("data", "pkg_sizes", "standaloneUUID_pkg_sizes.csv")) %>% mutate(update_cat = rep("standaloneUUID"))
childDOI <- read_csv(here::here("data", "pkg_sizes", "childDOI_pkg_sizes.csv")) %>% mutate(update_cat = rep("childDOI"))
childUUID <- read_csv(here::here("data", "pkg_sizes", "childUUID_pkg_sizes.csv")) %>% mutate(update_cat = rep("childUUID"))
parentDOI <- read_csv(here::here("data", "pkg_sizes", "parentDOI_pkg_sizes.csv")) %>% mutate(update_cat = rep("parentDOI"))
WEIRDDOI <- read_csv(here::here("data", "pkg_sizes", "WEIRDDOI_pkg_sizes.csv")) %>% mutate(update_cat = rep("WEIRDDOI"))
WEIRDUUID <- read_csv(here::here("data", "pkg_sizes", "WEIRDUUID_pkg_sizes.csv")) %>% mutate(update_cat = rep("WEIRDUUID"))
MULTINESTINGDOI <- read_csv(here::here("data", "pkg_sizes", "MULTINESTINGDOI_pkg_sizes.csv")) %>% mutate(update_cat = rep("MULTINESTINGDOI"))
tooLongToLoadDOI <- read_csv(here::here("data", "pkg_sizes", "tooLongToLoadDOI_pkg_sizes.csv")) %>% mutate(update_cat = rep("tooLongToLoadDOI"))

all_pkg_sizes <- rbind(standaloneDOI, standaloneUUID, childDOI, childUUID, parentDOI, WEIRDDOI, WEIRDUUID, MULTINESTINGDOI, tooLongToLoadDOI)

# write_csv(all_pkg_sizes, here::here("data", "pkg_sizes", "all_pkg_sizes.csv"))
