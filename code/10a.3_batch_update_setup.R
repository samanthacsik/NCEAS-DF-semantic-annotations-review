# title: Data organization and setup for batch update of datapackages with semantic annotations
# author: "Sam Csik"
# date created: "2021-01-27"
# date edited: "2021-03-15"
# R version: 3.6.3
# input: data/outputs/attributes_to_annotate/script10a2_attributes_to_annotate/attributes_to_annotate_2021Mar12.csv"
# output: subsetted attributes df for use in script 10b_batch_update_childORunnested.R

##########################################################################################
# Summary
##########################################################################################

# load necessary packages, get token, set mn, etc.
# wrangle/filter attribute data to batch update subsets at a time
# does NOT include any ACADIS or LTER datapackages; all datapackages are PUBLIC
# packages are sorted by type (e.g. standalone, child, parent, etc), identifier type (DOI vs. UUID) and size (small <= 20 datasets; medium 21 - 100 datasets; large 101 - 300 datasets; xl > 300 datasets) for batch-update groupings 

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

# configure tryCatchLog 
flog.appender(appender.file("error.log")) # choose files to log errors to
flog.threshold(ERROR) # set level of error logging (options: TRACE, DEBUG, INFO, WARM, ERROR, FATAL)

# create hash to store all auto-generated attribute ids (to ensure uniqueness; see `verify_attribute_id_isUnique()`) 
validate_attributeID_hash <- new.env(hash = TRUE)

# create empty vector to store duplicate attribute ids
duplicate_ids <- c()

##############################
# import data 
##############################

attributes <- read_csv(here::here("data", "outputs", "attributes_to_annotate", "script10a2_attributes_to_annotate", "attributes_to_annotate_2021Mar12.csv"),
                       col_types = cols(.default = col_character())) %>% 
  mutate(num_datasets = as.numeric(num_datasets))


##############################
# filter here for subset of data to update (e.g. update subset of 'standalone' pkgs) -- FILTERING FOR DATASETS TO TEST
##############################

#-------------------------
### tested and works ###
#-------------------------
# attributes <- attributes %>% filter(identifier == "doi:10.18739/A2TM7216N") # has otherEntity to annotate 
# attributes <- attributes %>% filter(identifier == "doi:10.18739/A29882N5H") # has just dataTables (FAILS INITIAL VALIDATION)
# attributes <- attributes %>% filter(identifier == "doi:10.18739/A2M61BQ8M") # has dT to annotate + 1 unpacked oE (no attributes)
# attributes <- attributes %>% filter(identifier %in% c("doi:10.18739/A2M61BQ8M", "doi:10.18739/A29882N5H", "doi:10.18739/A2TM7216N"))

attributes <- attributes %>%
  filter(package_type == "standalone",
         identifier %in% c("doi:10.18739/A2M32NB0W", "doi:10.18739/A2DB7VQ74",
                           "doi:10.18739/A2251FK3B", "doi:10.18739/A22B8VC2H",
                           "urn:uuid:4a48d82c-5484-442f-85a7-8893a3231ae2"))


# attributes <- attributes %>%
#   filter(package_type == "standalone",
#          identifier %in% c("doi:10.18739/A2NC5SD2M", "doi:10.18739/A26D5PB4R", 
#                            "doi:10.18739/A28911Q99","doi:10.18739/A2RX93D9P"))

# attributes <- attributes %>%
#   filter(package_type == "standalone",
#          identifier %in% c("doi:10.18739/A2MS3K24P", "doi:10.18739/A2DF71", 
#                            "doi:10.18739/A2VD6P488", "doi:10.18739/A2CF9J675"))


#-------------------------
## child package subset ##
#-------------------------

# attributes <- attributes %>% 
#   filter(package_type == "child") %>% 
#   filter(parent_rm == "resource_map_doi:10.18739/A2WH2DF8T") # very large

# attributes <- attributes %>% 
#   filter(package_type == "child",
#          parent_rm == "resource_map_doi:10.18739/A2CR5ND3R")

#-------------------------
# super large...
#-------------------------

# attributes <- attributes %>% filter(identifier == "doi:10.18739/A26W9688B") # netCDF TAKES SOOO LONG










# trying to organize pkgs into smaller subsets for batch update, below. can ignore for now, but any suggestions you might have for breaking out smaller groups of pkgs for updates is welcomed














# ##########################################################################################
# # Data Subsets (these are all PUBLIC datasets, no LTER data, no ACADIS data, 1061 total)
# ##########################################################################################
# 
# # ----------------------
# # ----------------------
# # standalone DOIs (235)
# # ----------------------
# # ----------------------
# 
# attributes_standaloneDOI <- attributes %>%
#   filter(update_cat == "standaloneDOI")
# 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# 
# standaloneDOI_small <- attributes_standaloneDOI %>% filter(num_datasets <= 20) # 196 (20 per run)
# unique_standaloneDOI_small <- unique(standaloneDOI_small$identifier)
# run1_standaloneDOI_small <- standaloneDOI_small %>% filter(identifier %in% unique_standaloneDOI_small[1:20]) 
# run2_standaloneDOI_small <- standaloneDOI_small %>% filter(identifier %in% unique_standaloneDOI_small[21:40]) 
# run3_standaloneDOI_small <- standaloneDOI_small %>% filter(identifier %in% unique_standaloneDOI_small[41:60]) 
# run4_standaloneDOI_small <- standaloneDOI_small %>% filter(identifier %in% unique_standaloneDOI_small[61:80])
# run5_standaloneDOI_small <- standaloneDOI_small %>% filter(identifier %in% unique_standaloneDOI_small[81:100])
# run6_standaloneDOI_small <- standaloneDOI_small %>% filter(identifier %in% unique_standaloneDOI_small[101:120])
# run7_standaloneDOI_small <- standaloneDOI_small %>% filter(identifier %in% unique_standaloneDOI_small[121:140])
# run8_standaloneDOI_small <- standaloneDOI_small %>% filter(identifier %in% unique_standaloneDOI_small[141:160])
# run9_standaloneDOI_small <- standaloneDOI_small %>% filter(identifier %in% unique_standaloneDOI_small[161:180])
# run10_standaloneDOI_small <- standaloneDOI_small %>% filter(identifier %in% unique_standaloneDOI_small[181:196])
# 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#   
# standaloneDOI_medium <- attributes_standaloneDOI %>% filter(num_datasets > 20 & num_datasets <= 100) # 31 (5 per run)
# unique_standaloneDOI_medium <- unique(standaloneDOI_medium$identifier)
# run1_standaloneDOI_medium <- standaloneDOI_medium %>% filter(identifier %in% unique_standaloneDOI_medium[1:5])
# run2_standaloneDOI_medium <- standaloneDOI_medium %>% filter(identifier %in% unique_standaloneDOI_medium[6:10])
# run3_standaloneDOI_medium <- standaloneDOI_medium %>% filter(identifier %in% unique_standaloneDOI_medium[11:15])
# run4_standaloneDOI_medium <- standaloneDOI_medium %>% filter(identifier %in% unique_standaloneDOI_medium[16:20])
# run5_standaloneDOI_medium <- standaloneDOI_medium %>% filter(identifier %in% unique_standaloneDOI_medium[21:25])
# run6_standaloneDOI_medium <- standaloneDOI_medium %>% filter(identifier %in% unique_standaloneDOI_medium[26:31])
# 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# 
# standaloneDOI_large <- attributes_standaloneDOI %>% filter(num_datasets > 100 & num_datasets <= 300) # 6 (2 per run)
# unique_standaloneDOI_large <- unique(standaloneDOI_large$identifier)
# run1_standaloneDOI_large <- standaloneDOI_large %>% filter(identifier %in% unique_standaloneDOI_large[1:2])
# run2_standaloneDOI_large <- standaloneDOI_large %>% filter(identifier %in% unique_standaloneDOI_large[3:4])
# run3_standaloneDOI_large <- standaloneDOI_large %>% filter(identifier %in% unique_standaloneDOI_large[5:6])
# 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# 
# standaloneDOI_xl <- attributes_standaloneDOI %>% filter(num_datasets > 300) # 2 (1 per run)
# unique_standaloneDOI_xl <- unique(standaloneDOI_xl$identifier)
# run1_standaloneDOI_large <- standaloneDOI_large %>% filter(identifier %in% unique_standaloneDOI_xl[1])
# run2_standaloneDOI_large <- standaloneDOI_large %>% filter(identifier %in% unique_standaloneDOI_large[2])
# 
# # ----------------------
# # ----------------------
# # standalone UUIDs (3)
# # ----------------------
# # ----------------------
# 
# attributes_standaloneUUID <- attributes %>%
#   filter(update_cat == "standaloneUUID")
# 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# 
# standaloneUUID_small <- attributes_standaloneUUID %>% filter(num_datasets <= 20) # 3
# 
# # ----------------------
# # ----------------------
# # child DOIs (646)
# # ----------------------
# # ----------------------
# 
# attributes_childDOI <- attributes %>%
#   filter(update_cat == "childDOI")
# 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# 
# small <- attributes_childDOI %>% filter(num_datasets <= 20) # 321
# 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# 
# medium <- attributes_childDOI %>% filter(num_datasets > 20 & num_datasets <= 100) # 59
# 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# 
# large <- attributes_childDOI %>% filter(num_datasets > 100 & num_datasets <= 300) # 228
# 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# 
# xl <- attributes_childDOI %>% filter(num_datasets > 300) # 38
# 
# # ----------------------
# # ----------------------
# # child UUIDs (1)
# # ----------------------
# # ----------------------
# 
# attributes_childUUID <- attributes %>%
#   filter(update_cat == "childUUID")
# 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# 
# small <- attributes_childUUID %>% filter(num_datasets <= 20) # 1
# 
# # ----------------------
# # ----------------------
# # parent DOIs (4)
# # ----------------------
# # ----------------------
# 
# attributes_parentDOI <- attributes %>%
#   filter(update_cat == "parentDOI")
# 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# 
# small <- attributes_parentDOI %>% filter(num_datasets <= 20) # 4
# 
# # ----------------------
# # ----------------------
# # WEIRD DOIs (17)
# # ----------------------
# # ----------------------
# 
# attributes_WEIRDDOI <- attributes %>%
#   filter(update_cat == "WEIRDDOI")
# 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# 
# small <- attributes_WEIRDDOI %>% filter(num_datasets <= 20) # 8
# 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# 
# medium <- attributes_WEIRDDOI %>% filter(num_datasets > 20 & num_datasets <= 100) # 6
# 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# 
# large <- attributes_WEIRDDOI %>% filter(num_datasets > 100 & num_datasets <= 300) # 3
# 
# # ----------------------
# # ----------------------
# # too long to load DOIs (75)
# # ----------------------
# # ----------------------
# 
# attributes_tooLongToLoadDOI <- attributes %>%
#   filter(update_cat == "tooLongToLoadDOI")
# 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# 
# medium <- attributes_tooLongToLoadDOI %>% filter(num_datasets > 20 & num_datasets <= 100) # 2
# 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# 
# large <- attributes_tooLongToLoadDOI %>% filter(num_datasets > 100 & num_datasets <= 300) # 9
# 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# 
# xl <- attributes_tooLongToLoadDOI %>% filter(num_datasets > 300) # 64
# 
# # ----------------------
# # ----------------------
# # MULTINESTING (80)
# # ----------------------
# # ----------------------
# 
# attributes_MULITNESTINGDOI <- attributes %>%
#   filter(update_cat == "MULTINESTINGDOI")
# 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# 
# small <- attributes_MULITNESTINGDOI %>% filter(num_datasets >= 20) 
# 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# 
# medium <- attributes_MULITNESTINGDOI %>% filter(num_datasets > 20 & num_datasets <= 100)
# 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# 
# large <- attributes_MULITNESTINGDOI %>% filter(num_datasets > 100 & num_datasets <= 300) 
# 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# 
# xl <- attributes_MULITNESTINGDOI %>% filter(num_datasets > 300) 
# 
# ##########################################################################################
# # all updated/remaining packages
# ##########################################################################################
# 
# 
# # run1_standaloneDOIs <- read_csv(here::here("data", "updated_pkgs", "run1_standaloneDOI_2021Mar11.csv"))
# # 
# # updated_packages <- rbind()
# # 
# # remaining_packages <- anti_join(attributes, updated_packages)

