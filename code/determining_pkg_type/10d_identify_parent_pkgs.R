# title: identify parent packages 
# author: "Sam Csik"
# date created: "2021-01-15"
# date edited: "2021-01-15"
# R version: 3.6.3
# input: "data/outputs/attributes_child_pkgs_identified_2020-01-13.csv" (generated in script 10c)
# output: "data/outputs/attributes_parents_child_labeled_2020-01-13.csv"

##############################
# General Setup
##############################

# load packages
library(tidyverse)

# import data
attributes <- read_csv(here::here("data", "outputs", "attributes_child_pkgs_identified_2020-01-13.csv")) %>% 
  select(-X1)

# same as (just with child packages identified): 
# attributes <- read_csv(here::here("data", "outputs", "annotate_these_attributes_2020-12-17_webscraped.csv")) %>% 
#   filter(!str_detect(identifier, "(?i)https://pasta.lternet.edu"))

##############################
# isolate only known child pkgs
##############################

child_pkgs_only <- attributes %>% filter(package_type == "child") 
length(unique(child_pkgs_only$identifier)) # 303

##############################
# identify what's left
##############################

attributes_remainder <- attributes %>% 
  filter(is.na(package_type)) %>% 
  select(-package_type)

length(unique(attributes_remainder$identifier)) #789

##############################
# see if we can find parents pkgs based on matching metadata pids from 'attributes_remainder$identifier' and 'child_pkgs_only$parent_metadata_pid'
##############################

# known parent identifiers
parent_identifiers <- child_pkgs_only %>% 
  select(parent_metadata_pid) %>% 
  mutate(package_type = "parent") %>% 
  rename(identifier = parent_metadata_pid)

# find matches in 'attributes_remainder'
parent_pkgs_only <- full_join(attributes_remainder, parent_identifiers) %>% 
  filter(package_type == "parent") %>% 
  filter(!is.na(assigned_valueURI))

p_unique <- parent_pkgs_only %>% 
  distinct(parent_pkgs_only$identifier) 

length(p_unique) # 5

##############################
# combine known parents and child pkgs to check numbers
##############################

known_parents_and_children <- rbind(child_pkgs_only, parent_pkgs_only) %>% 
  select(identifier, package_type) %>% 
  distinct(identifier, package_type)

length(unique(known_parents_and_children$identifier)) # 308 total

##############################
# label parent pkgs in attributes df
##############################

x <- attributes %>% 
  select(-package_type)

attributes_parents_child_labeled <- full_join(x, known_parents_and_children)

# write_csv(attributes_parents_child_labeled, here::here("data", "outputs", "attributes_parents_child_labeled_2020-01-13.csv"))

##############################
# identify what's left (again)
##############################

attributes_remainder_2 <- attributes_parents_child_labeled %>% 
  filter(is.na(package_type))

remainder <- attributes_remainder_2 %>% 
  distinct(identifier)
  
length(remainder$identifier) # 784


