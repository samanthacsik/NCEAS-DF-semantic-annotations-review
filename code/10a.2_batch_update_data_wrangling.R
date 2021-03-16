# title: 
# author: "Sam Csik"
# date created: "2021-03-12"
# date edited: "2021-03-12"
# R version: 3.6.3
# input: "data/outputs/attributes_to_annotate"/all_attributes_to_annotate_sorted_by_pkgType_2020-01-19.csv", 
       # "data/outputs/annotate_these_attributes_2020-12-17_webscraped.csv", 
       # "data/queries/query2021-01-25_isPublic/fullQuery_semAnnotations_isPublic2021-01-25.csv", 
       # "data/pkg_sizes/all_pkg_sizes.csv" 
# output: 

##########################################################################################
# Summary
##########################################################################################

# wrangle attribute data in preparation for batch update

##########################################################################################
# General setup
##########################################################################################

##############################
# load packages
##############################

library(tidyverse)

##############################
# import attributes data (lter datapackages have been removed, i.e. identifier == https://pasta.lternet.edu..., 364 pkgs total) 
##############################

attributes <- read_csv(here::here("data", "outputs", "attributes_to_annotate", "all_attributes_to_annotate_sorted_by_pkgType_2020-01-19.csv"),
                       col_types = cols(.default = col_character()))
length(unique(attributes$identifier)) # 1092 datapackages total

##############################
# add 'status' back into attributes df (idk where/how it got removed but nice to have for reference, though not necessary)
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
# join package sizes with attributes df
##############################

pkg_sizes <- read_csv(here::here("data", "pkg_sizes", "all_pkg_sizes.csv")) %>% 
  rename(identifier = metadataPID)
length(unique(pkg_sizes$identifier)) # 1092 datapackages

attributes <- left_join(attributes, pkg_sizes)
length(unique(attributes$identifier)) # check that there are still 1061 datapackages

##############################
# write as .csv for use in batch update setup (script 10a.3)
##############################

# write_csv(attributes, here::here("data", "outputs", "attributes_to_annotate", "script10a2_attributes_to_annotate", "attributes_to_annotate_2021Mar12.csv"))
