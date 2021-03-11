# title: Data organization and setup for batch update of datapackages with semantic annotations
# author: "Sam Csik"
# date created: "2021-01-27"
# date edited: "2021-02-18"
# R version: 3.6.3
# input: "data/outputs/attributes_to_annotate"/all_attributes_to_annotate_sorted_by_pkgType_2020-01-19.csv" (see script 10b_batch_update_setup.R)
# output: no output, but publishes updates to arcticdata.io 

##########################################################################################
# Summary
##########################################################################################

# wrangle/filter attribute data to batch update subets at a time

# CONSIDERATIONS (from Jeanette):
  # need different workflows for parent and child packages
  # child first (need to add an extra step which is updating the parent resource map), then parents (current workflow won't work for parent packages)
  # split out making changes vs updates
  # determine number of data files within a dp and then update those with less than X number of files
  # run this in small subsets based on number of datatables

##########################################################################################
# General Setup
##########################################################################################

##############################
# load packages
##############################

library(dataone)
library(datapack)
library(arcticdatautils) 
library(EML)
library(uuid)
library(tryCatchLog)
library(futile.logger) 
library(tidyverse)

##############################
# get token, set nodes
##############################

# get token reminder
# options(dataone_test_token = "...")

# set nodes (if using test site: d1c_test <- dataone::D1Client("STAGING", "urn:node:mnTestARCTIC") )
d1c_prod <- dataone::D1Client("PROD", "urn:node:ARCTIC")

##############################
# configure tryCatchLog and create new hash/vector for verying id uniqueness
##############################

# configure tryCatchLog -- NEED TO LEARN MORE ABOUT THIS
flog.appender(appender.file("error.log")) # choose files to log errors to
flog.threshold(ERROR) # set level of error logging (options: TRACE, DEBUG, INFO, WARM, ERROR, FATAL)

# create hash to store attribute ids (to determine uniqueness; see `verify_attribute_id_isUnique()`) 
validate_attributeID_hash <- new.env(hash = TRUE)

# create empty vector to store duplicate attribute ids
duplicate_ids <- c()

##############################
# import data (lter datapackages have been removed, i.e. identifier == https://pasta.lternet.edu..., 364 pkgs total) 
##############################

attributes <- read_csv(here::here("data", "outputs", "attributes_to_annotate", "all_attributes_to_annotate_sorted_by_pkgType_2020-01-19.csv"),
                       col_types = cols(.default = col_character()))
length(unique(attributes$identifier)) # 1092 datapackages total

##############################
# add 'status' back into attributes df (idk where/how it got removed but nice to have for reference, though not necesssary)
  # status = (a) dp has at least one annotation (b) dp was never annotated
##############################

status <- read_csv(here::here("data", "outputs", "annotate_these_attributes_2020-12-17_webscraped.csv")) %>%
  filter(!str_detect(identifier, "(?i)https://pasta.lternet.edu")) %>%
  select(identifier, status) %>% 
  distinct(identifier, status)

attributes <- left_join(attributes, status)
length(unique(attributes$identifier)) # double check that we still have all 1092 datapackages

##############################
# join 'isPublic' column from solr query on 2021-01-25 with 'attributes' df (Jeanette suggested filtering out any datapackages that aren't yet public so that we don't interfere with ongoing curation); did not query for this originally, so joining information from more recent query 
##############################

isPublic <- read_csv(here::here("data", "queries", "query2021-01-25_isPublic", "fullQuery_semAnnotations_isPublic2021-01-25.csv")) %>% 
  select(identifier, isPublic) %>% 
  replace_na(list(identifier = "FALSE", isPublic = "FALSE")) %>% # listed as either 'TRUE' or 'NA'? replace NAs with 'FALSE'
  distinct(identifier, isPublic)

attributes <- left_join(attributes, isPublic) %>% # 14 (NA), 17 (FALSE), 1061 (TRUE)
  filter(isPublic == "TRUE")

length(unique(attributes$identifier)) # 1061 datapackages where isPublic == TRUE

##############################
# clean up global environment
##############################

rm(isPublic, status)

##############################
# filter here for subset of data to update (e.g. update subset of 'standalone' pkgs) -- FILTERING FOR DATASETS TO TEST
##############################

### need to retest ###
# attributes <- attributes %>% filter(identifier == "doi:10.18739/A26W9688B") # netCDF TAKES SOOO LONG

### tested and works ###
# attributes <- attributes %>% filter(identifier == "doi:10.18739/A2TM7216N") # has otherEntity to annotate 
# attributes <- attributes %>% filter(identifier == "doi:10.18739/A29882N5H") # has just dataTables (FAILS INITIAL VALIDATION)
# attributes <- attributes %>% filter(identifier == "doi:10.18739/A2M61BQ8M") # has dT to annotate + 1 unpacked oE (no attributes)
# attributes <- attributes %>% filter(identifier %in% c("doi:10.18739/A2M61BQ8M", "doi:10.18739/A29882N5H", "doi:10.18739/A2TM7216N"))

### child package subset ##
# attributes <- attributes %>% 
#   filter(package_type == "child") %>% 
#   filter(parent_rm == "resource_map_doi:10.18739/A2WH2DF8T") # very large

# attributes <- attributes %>% 
#   filter(package_type == "child",
#          parent_rm == "resource_map_doi:10.18739/A2CR5ND3R")

### random selection of standalone packages ###

attributes <- attributes %>%
  filter(package_type == "standalone",
         identifier %in% c("doi:10.18739/A2M32NB0W", "doi:10.18739/A2DB7VQ74",
                            "doi:10.18739/A2251FK3B", "doi:10.18739/A22B8VC2H",
                            "urn:uuid:4a48d82c-5484-442f-85a7-8893a3231ae2"))


# Weird ones:
# 1) "doi:10.18739/A2251FK3B" : doc$packageId = doi:10.18739/A2J09W41K?? don't know why this doesn't match it's identifier