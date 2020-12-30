# title: testing
# author: "Sam Csik"
# date created: "2020-12-21"
# date edited: "2020-12-21"
# R version: 3.6.3
# input: "data/outputs/annotate_these_attributes_2020-12-17.csv"
# output: 

##########################################################################################
# Summary
##########################################################################################

# cloned one dataset to test.arcticdata.io: https://search.dataone.org/view/doi:10.18739/A24B2X46G 
# this is a child package to parent: https://search.dataone.org/view/doi%3A10.18739%2FA2RJ48V9W

# identifiers in test.arcticdata.io
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

# for later: https://cran.r-project.org/web/packages/tryCatchLog/vignettes/tryCatchLog-intro.html
# hashes: https://riptutorial.com/r/example/18339/environments-as-hash-maps

##########################################################################################
# General Setup
##########################################################################################

# load packages
library(dataone)
library(datapack)
library(arcticdatautils)
library(EML)
library(uuid)
library(tryCatchLog)
library(futile.logger) 
library(tidyverse)

# source in functions 
source(here::here("code", "00_automate_semAnnotations_functions.R"))

# set nodes and GET TEST SITE TOKEN
cn_staging <- CNode('STAGING')
adc_test <- getMNode(cn_staging,'urn:node:mnTestARCTIC')

# import data
attributes <- read_csv(here::here("data", "outputs", "annotate_these_attributes_2020-12-17.csv"))

##########################################################################################
# add semantic annotations for ONE datapackage (PRACTICE)
##########################################################################################

##############################
# get metadata to annotate (metadata record called 'doc')
##############################

# IGNORE FOR NOW: get vector of all unique datapackages
unique_datapackages <- unique(attributes$identifier)

# IGNORE FOR NOW: subset out first datapackage
for(i in 1:length(unique_datapackages)){
   current_datapackage <- unique_datapackages[i]
}
   
# IGNORE FOR NOW: get resource map
current_resource_map <- paste("resource_map_", current_datapackage, sep = "")

# IGNORE FOR NOW: get package using current_resource_map 
current_pkg <- get_package(adc_test, 
                   current_resource_map,
                   file_names = TRUE)

# IGNORE FOR NOW: extract metadata pid
current_metadata_pid <- current_pkg$metadata

# read in metadata using current_metadata_pid BE SURE TO REPLACE STRING WITH 'current_metadata_pid'
doc <- read_eml(getObject(adc_test, "urn:uuid:206cc135-5f0b-4fd5-b162-b7d2243e533e")) 

##############################
# create attribute id and ensure that it's unique 
##############################

# create hash table to store attribute ids (keys) in (to determine uniqueness)
my_hash <- new.env(hash = TRUE)

# create empty vector to store duplicate attribute ids
duplicate_ids <- c()

# get number of dataTables in this datapackage
numberOf_dataTables <- length(doc$dataset$dataTable)

# iterate through all entities in the datapackage
for(i in 1:numberOf_dataTables){
   message("Processing dataTable ", i, " of ", numberOf_dataTables)
   # see all attribute names in current dataTable
   current_attribute_list <- eml_get_simple(doc$dataset$dataTable[[i]]$attributeList, "attributeName")
   # iterate through attributes to build id and verify uniqueness using hash
   for(j in 1:length(current_attribute_list)){
      # construct attribute ID
      current_attribute_id <- build_attributeID(dataTable_number = i, attribute_number = j)
      # ensure that each attribute ID is unique
      verify_attributeID_isUnique(current_attribute_id)
   }
}

# NEED TO DO:
# create/add propertyURI for each annotation (this will be the same for all attributes)
# create/add valueURI for each annotation (this will depend on the attribute--need to get this from df)

# inspect hash map
names(my_hash)
length(my_hash)
















# Station
# doc$dataset$dataTable[[1]]$attributeList$attribute[[1]]$id <- "entity_location_attribute_stationID1"
# doc$dataset$dataTable[[1]]$attributeList$attribute[[1]]$annotation$propertyURI <- list(label = "contains meausurements of",
#                                                                                        propertyURI = "http://ecoinformatics.org/oboe/oboe.1.2/oboe-core.owl#containsMeasurementsOfType")
# doc$dataset$dataTable[[1]]$attributeList$attribute[[1]]$annotation$valueURI <- list(label = "station identifier",
#                                                                                     valueURI = "http://purl.dataone.org/odo/ECSO_00002393")

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CHECK CHANGES:
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# eml_validate(doc)
# eml_path <- "eml/Bonsell_#20625_HydrographicAnd1_2020_08_21.xml" 
# write_eml(doc, eml_path) 

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# PUBLISH CHANGES, SET RIGHTS & ACCESS:
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#update - commented out to prevent accidental changes DO NOT RUN
# update <- publish_update(adc_mn,
#                          metadata_pid = pkg$metadata,
#                          data_pids = pkg$data,
#                          resource_map_pid = pkg$resource_map,
#                          metadata_path = eml_path,
#                          public = F)

