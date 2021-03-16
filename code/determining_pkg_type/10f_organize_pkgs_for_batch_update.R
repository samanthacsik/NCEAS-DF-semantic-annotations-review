# title: organize all sorted & unsorted packages for batch update
# author: "Sam Csik"
# date created: "2021-01-19"
# date edited: "2021-01-19"
# R version: 3.6.3
# input: "data/outputs/CURRENTLY_UNSORTED_PKGS_2020-01-17_script10c.csv" & "data/outputs/attributes_parents_child_labeled_2020-01-17_script10c.csv" (from script 10e)
# output: 

##############################
# General Setup
##############################

# load packages 
library(tidyverse)

# import data
auto_sorted_pkgs <- read_csv(here::here("data", "outputs", "attributes_parents_child_labeled_2020-01-17_script10c.csv"))
length(unique(auto_sorted_pkgs$identifier)) # 1092 (total)

manually_sorted_pkgs <- read_csv(here::here("data", "outputs", "MANUALLY_SORTED_PKGS_2020-01-17_script10c.csv")) %>% 
  select(-X8)
length(unique(manually_sorted_pkgs$identifier)) # 603

##############################
# separate out unsorted pkgs from `auto_sorted_pkgs` and join them with sorting info from `manually_sorted_pkgs`
##############################

# separate from 'auto_sorted_pkgs'
unsorted <- auto_sorted_pkgs %>% 
  filter(package_type == "unsorted") %>% 
  select(-c(child_rm, parent_rm, parent_metadata_pid, package_type))
length(unique(unsorted$identifier)) # 603 (matches the number in 'manually_sorted_pkgs' which is good!)

# add in sorting info from 'manually_sorted_pkgs'
manually_sorted_combined <- full_join(unsorted, manually_sorted_pkgs)
length(unique(manually_sorted_combined$identifier)) # 603

# fix "MULTINESTING" vs. "MUlTINESTING" typo in 'package_type' column
manually_sorted_combined <- manually_sorted_combined %>% 
  mutate_if(is.character,
            str_replace_all, pattern = "MUlTINESTING", replacement = "MULTINESTING") %>% 
  select(identifier, entityName, attributeName, attributeLabel, attributeDefinition, attributeUnit, viewURL, query_datetime_utc, assigned_valueURI, prefName, ontoName, package_type, child_rm, parent_rm, parent_metadata_pid)

##############################
# add 'manually_sorted_combined' back to all the auto sorted pkgs
##############################

# previously auto-sorted pkgs
auto_sorted_parents_children <- auto_sorted_pkgs %>% 
  filter(package_type %in% c("child", "parent")) %>% 
  select(identifier, entityName, attributeName, attributeLabel, attributeDefinition, attributeUnit, viewURL, query_datetime_utc, assigned_valueURI, prefName, ontoName, package_type, child_rm, parent_rm, parent_metadata_pid)
length(unique(auto_sorted_parents_children$identifier)) # 489 good!

# combine all pkgs
all_sorted_pkgs <- rbind(auto_sorted_parents_children, manually_sorted_combined) 
length(unique(all_sorted_pkgs$identifier)) # 1092 good!
unique(all_sorted_pkgs$package_type) # one package_type got skipped by accident ('NA')

# fix that by assigning package_type == "too long to load"
fix_skipped_pkg_NA <- all_sorted_pkgs %>% filter(is.na(package_type)) %>% 
  mutate(package_type = rep("too long to load"))

##############################
# subset out package_types for updating
##############################

# standalone packages should get updated first
standalone_pkgs_to_update <- all_sorted_pkgs %>% filter(package_type == "standalone") %>% mutate(child_rm = na_if(child_rm, "EC"))
length(unique(standalone_pkgs_to_update$identifier)) # 249
# write_csv(standalone_pkgs_to_update, here::here("data", "outputs", "attributes_to_annotate", "standalone_pkgs_to_update.csv"))

# child packages should get updated second
child_pkgs_to_update <- all_sorted_pkgs %>% filter(package_type == "child")
length(unique(child_pkgs_to_update$identifier)) # 652
# write_csv(child_pkgs_to_update, here::here("data", "outputs", "attributes_to_annotate", "child_pkgs_to_update.csv"))

# parent packages should get updated third (NEED TO WRITE A NEW WORKFLOW FOR THESE)
parent_pkgs_to_update <- all_sorted_pkgs %>% filter(package_type == "parent")
length(unique(parent_pkgs_to_update$identifier)) # 5
# write_csv(parent_pkgs_to_update, here::here("data", "outputs", "attributes_to_annotate", "parent_pkgs_to_update.csv"))

# WEIRD packages need input from others first
WEIRD_pkgs_to_assess <- all_sorted_pkgs %>% filter(package_type == "WEIRD")
length(unique(WEIRD_pkgs_to_assess$identifier)) # 31
# write_csv(WEIRD_pkgs_to_assess, here::here("data", "outputs", "attributes_to_annotate", "WEIRD_pkgs_to_assess.csv"))

# MULTINESTING packages need input from others first (and a different workflow)
MULTINESTING_pkgs_to_assess <- all_sorted_pkgs %>% filter(package_type == "MULTINESTING")
length(unique(MULTINESTING_pkgs_to_assess$identifier)) # 80
# write_csv(MULTINESTING_pkgs_to_assess, here::here("data", "outputs", "attributes_to_annotate", "MULTINESTING_pkgs_to_assess.csv"))

# 'too long to load' packages need to be revisited
too_long_to_load <- all_sorted_pkgs %>% filter(package_type == "too long to load")
too_long_to_load_to_revisit <- rbind(too_long_to_load, fix_skipped_pkg_NA)
length(unique(too_long_to_load_to_revisit$identifier)) # 75
# write_csv(too_long_to_load_to_revisit, here::here("data", "outputs", "attributes_to_annotate", "too_long_to_load_pkgs_to_revisit.csv"))

# recombine into finalized df (easier for sending to people if necessary)
attributes_to_semantically_annotate <- rbind(standalone_pkgs_to_update, child_pkgs_to_update, 
                                             parent_pkgs_to_update, WEIRD_pkgs_to_assess, 
                                             MULTINESTING_pkgs_to_assess, too_long_to_load_to_revisit)
length(unique(attributes_to_semantically_annotate$identifier)) # double check one last time

# write_csv(attributes_to_semantically_annotate, here::here("data", "outputs", "attributes_to_annotate", "all_attributes_to_annotate_sorted_by_pkgType_2020-01-19.csv"))
