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

# I found a single datapackage with multiple entities, with a variety of attributes to be semantically annotated. 
# I've cloned this datapackage to the test node to practice adding annotations to in preparation for a mass annotation effort.

# this one already has annotations and is not a parent/child package: https://search.dataone.org/view/doi:10.18739/A2VM42Z20

# parent to current cloned package: doi:10.18739/A2RJ48V9W

##########################################################################################
# General Setup
##########################################################################################

# load packages
library(dataone)
library(arcticdatautils)
library(EML)
library(tidyverse)

# import data
attributes <- read_csv(here::here("data", "outputs", "annotate_these_attributes_2020-12-17.csv"))

##########################################################################################
# Replicate dataset for practice
##########################################################################################

##############################
# clone 1 (is a child package), cloned to test.arcticdata.io on 2020-12-21
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
