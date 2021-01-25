# title: clone practice pkg for testing
# author: "Sam Csik"
# date created: "2020-12-21"
# date edited: "2021-01-05"
# R version: 3.6.3
# input: "data/outputs/annotate_these_attributes_2020-12-17.csv"
# output: 

##########################################################################################
# Summary
##########################################################################################

# COME BACK TO THESE (GOOD TO TEST BUT TAKING FOREVER TO CLONE; MAYBE CLONE OVERNIGHT...)
  # netCDF: doi:10.18739/A26W9688B, doi:10.18739/A26W9688B, doi:10.18739/A2BN9X32Q
  # .nc: doi:10.18739/A27659G5Q


# Why do some datapackages have a resource map that doesn't match their DOI? (e.g. https://search.dataone.org/view/doi:10.18739/A2KS6J47F)

##########################################################################################
# General Setup
##########################################################################################

# load packages
library(dataone)
library(arcticdatautils)
library(EML)
library(tidyverse)

# import data
attributes <- read_csv(here::here("data", "outputs", "annotate_these_attributes_2020-12-17_webscraped.csv"))

##########################################################################################
# Replicate dataset for practice
##########################################################################################

#
#
#
#
#
#
#
#
#
#
#
#
#
#
#

##############################
# clone 1 (is a child package), cloned to test.arcticdata.io on 2020-12-21; eml 2.1.1
##############################

# find datapackage to replicate/practice on (this one has a variety of semantic annotations across multiple entiites)
practice_pkg <- attributes %>% 
  filter(identifier == "doi:10.18739/A24B2X46G")

# define to and from for copy and pasting
from <- dataone::D1Client("PROD", "urn:node:ARCTIC")
to <- dataone::D1Client("STAGING", "urn:node:mnTestARCTIC")

# clone package
pkg_clone <- datamgmt::clone_package("resource_map_doi:10.18739/A24B2X46G",
                                     from = from, to = to, 
                                     add_access_to = arcticdatautils:::get_token_subject(),
                                     change_auth_node = TRUE, new_pid = TRUE)

# metadata PID: 
  # urn:uuid:206cc135-5f0b-4fd5-b162-b7d2243e533e
# data PID: 
  # urn:uuid:8faa3e67-c493-448b-a6c0-129854a9f1b2
  # urn:uuid:26b37309-bf62-402f-93d7-b36ba7c8055f
  # urn:uuid:c572addb-7a8b-43b6-b27a-cf95e0a9f4f7
  # urn:uuid:44cf5e73-b3f9-429f-97dc-bb6e93444039
  # urn:uuid:d74fbdc4-e02b-4a42-82f5-05c210ee92b8
  # urn:uuid:1c4d6c4e-4eb8-41ab-ba32-ba249284d8e4
  # urn:uuid:a5319ac6-8619-4173-a658-a8f55758229e
# resource map:
  # resource_map_urn:uuid:c84fec1f-33c6-4042-8605-33ab76e20a0f

#
#
#
#
#
#
#
#
#
#
#
#
#
#
#

##############################
# clone 2 (parent + child packages), cloned to test.arcticdata.io on 2021-01-07; eml 2.1.1
  # parent: resource_map_doi:10.18739/A2RJ48V9W (https://search.dataone.org/view/doi%3A10.18739%2FA2RJ48V9W)
  # child1: resource_map_doi:10.18739/A24B2X46G (https://search.dataone.org/view/doi:10.18739/A24B2X46G)
  # child2: resource_map_doi:10.18739/A2028PC7G (https://search.dataone.org/view/doi:10.18739/A2028PC7G)
##############################

# define to and from for copy and pasting
from <- dataone::D1Client("PROD", "urn:node:ARCTIC")
to <- dataone::D1Client("STAGING", "urn:node:mnTestARCTIC")

#---------------------
# clone packages to test node
#---------------------

child1_pkg_clone <- datamgmt::clone_package("resource_map_doi:10.18739/A24B2X46G",
                                            from = from, to = to, 
                                            add_access_to = arcticdatautils:::get_token_subject(),
                                            change_auth_node = TRUE, new_pid = TRUE)
# resource_map_urn:uuid:ef211791-b0f7-4a27-8dc6-dcdc67c278df

child2_pkg_clone <- datamgmt::clone_package("resource_map_doi:10.18739/A2028PC7G",
                                            from = from, to = to, 
                                            add_access_to = arcticdatautils:::get_token_subject(),
                                            change_auth_node = TRUE, new_pid = TRUE)
# resource_map_urn:uuid:8ff9aa01-45d9-4cb7-b90e-215862146a94

parent_pkg_clone <- datamgmt::clone_package("resource_map_doi:10.18739/A2RJ48V9W",
                                            from = from, to = to, 
                                            add_access_to = arcticdatautils:::get_token_subject(),
                                            change_auth_node = TRUE, new_pid = TRUE)
# resource_map_urn:uuid:5177de9d-cea7-4b7f-ada3-58407bc53dc2

#---------------------
# set nodes
#---------------------

cn_staging <- CNode('STAGING')
adc_test <- getMNode(cn_staging,'urn:node:mnTestARCTIC')

#---------------------
# get resource maps
#---------------------

resource_map_child1_new <- "resource_map_urn:uuid:ef211791-b0f7-4a27-8dc6-dcdc67c278df"
resource_map_child2_new <- "resource_map_urn:uuid:8ff9aa01-45d9-4cb7-b90e-215862146a94"
pkg_parent <- get_package(adc_test, 'resource_map_urn:uuid:5177de9d-cea7-4b7f-ada3-58407bc53dc2')

#---------------------
# nest child packages under parent
#---------------------

publish_update(adc_test,
               resource_map_pid = pkg_parent$resource_map,
               metadata_pid = pkg_parent$metadata,
               data_pids = pkg_parent$data_pids,  
               child_pids = c(pkg_parent$child_packages, 
                              resource_map_child1_new,
                              resource_map_child2_new))
#---------------------
# finalized resource maps
#---------------------

# https://test.arcticdata.io/view/urn%3Auuid%3A44d931d0-19cb-4edf-bb27-63ac6d5823b5

# parent: resource_map_urn:uuid:44d931d0-19cb-4edf-bb27-63ac6d5823b5 (original: resource_map_doi:10.18739/A2RJ48V9W)
# child 1: resource_map_urn:uuid:8ff9aa01-45d9-4cb7-b90e-215862146a94 (original: resource_map_doi:10.18739/A2028PC7G)
# child 2: resource_map_urn:uuid:ef211791-b0f7-4a27-8dc6-dcdc67c278df (original: resource_map_doi:10.18739/A24B2X46G)

#
#
#
#
#
#
#
#
#
#
#
#
#
#
#

##############################
# clone 3 (has pre-existing annotations) cloned to test.arcticdata.io on 2020-12-21; eml 2.2.0
##############################

# find datapackage to replicate/practice on 
practice_pkg <- attributes %>% 
  filter(identifier == "doi:10.18739/A2VM42Z20")

# define to and from for copy and pasting
from <- dataone::D1Client("PROD", "urn:node:ARCTIC")
to <- dataone::D1Client("STAGING", "urn:node:mnTestARCTIC")

# clone package
pkg_clone <- datamgmt::clone_package("resource_map_doi:10.18739/A2VM42Z20",
                                     from = from, to = to, 
                                     add_access_to = arcticdatautils:::get_token_subject(),
                                     change_auth_node = TRUE, new_pid = TRUE)
# resource_map_urn:uuid:3caf44b7-ffd4-4c4b-b1f2-e9de23d00d13

#
#
#
#
#
#
#
#
#
#
#
#
#
#
#

##############################
# clone 4 (same pkg as clone 1; retesting), cloned to test.arcticdata.io on 2021-01-07; eml 2.1.1
##############################

# find datapackage to replicate/practice on (this one has a variety of semantic annotations across multiple entiites)
practice_pkg <- attributes %>% 
  filter(identifier == "doi:10.18739/A24B2X46G")

# define to and from for copy and pasting
from <- dataone::D1Client("PROD", "urn:node:ARCTIC")
to <- dataone::D1Client("STAGING", "urn:node:mnTestARCTIC")

# clone package
pkg_clone <- datamgmt::clone_package("resource_map_doi:10.18739/A24B2X46G",
                                     from = from, to = to, 
                                     add_access_to = arcticdatautils:::get_token_subject(),
                                     change_auth_node = TRUE, new_pid = TRUE)
# resource_map_urn:uuid:4fd91ae7-2e03-4fde-b7b7-1bb8e27c7640

#
#
#
#
#
#
#
#
#
#
#
#
#
#
#

##############################
# clone 5 (same as clone 3) cloned to test.arcticdata.io on 2021-01-08; eml 2.2.0
##############################

# find datapackage to replicate/practice on 
practice_pkg <- attributes %>% 
  filter(identifier == "doi:10.18739/A2VM42Z20")

# define to and from for copy and pasting
from <- dataone::D1Client("PROD", "urn:node:ARCTIC")
to <- dataone::D1Client("STAGING", "urn:node:mnTestARCTIC")

# clone package
pkg_clone <- datamgmt::clone_package("resource_map_doi:10.18739/A2VM42Z20",
                                     from = from, to = to, 
                                     add_access_to = arcticdatautils:::get_token_subject(),
                                     change_auth_node = TRUE, new_pid = TRUE)
# resource_map_urn:uuid:3caf44b7-ffd4-4c4b-b1f2-e9de23d00d13

#
#
#
#
#
#
#
#
#
#
#
#
#
#
#

##############################
# clone 6
##############################

# define to and from for copy and pasting
from <- dataone::D1Client("PROD", "urn:node:ARCTIC")
to <- dataone::D1Client("STAGING", "urn:node:mnTestARCTIC")

# filter for any too large to clone at the moment
# clone_these <- attributes %>% 
#   filter(identifier %in% c("doi:10.18739/A2D21RH94", "doi:10.18739/A2VM42Z20", "doi:10.18739/A24B2X46G")) # x, 2.2.0, 2.1.0

# clone
# for(i in 1:length(clone_these$identifier)){
# 
#   # get resource map
#   rm <- paste("resource_map_", clone_these$identifier[i], sep = "")
#   
#   pkg_clone <- datamgmt::clone_package(rm,
#                                        from = from, to = to, 
#                                        add_access_to = arcticdatautils:::get_token_subject(),
#                                        change_auth_node = TRUE, new_pid = TRUE)
# }

pkg_clone <- datamgmt::clone_package("resource_map_doi:10.18739/A2D21RH94",
                                     from = from, to = to, 
                                     add_access_to = arcticdatautils:::get_token_subject(),
                                     change_auth_node = TRUE, new_pid = TRUE)


# doi:10.18739/A2D21RH94, 

