# title: testing take 2
# author: "Sam Csik"
# date created: "2021-01-04"
# date edited: "2021-01-04"
# R version: 3.6.3
# input: "data/outputs/annotate_these_attributes_2020-12-17_webscraped.csv"
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
# datapack: https://cran.r-project.org/web/packages/datapack/vignettes/datapack-overview.html 

# PROBLEMS: 
# 1) if the metadata already has some semantic annotations, they will be removed upon publishing update. Need to figure out how to extract these, save them, and readd them along with the new semantic annotations
# 2) publishing an update will remove association between parent and child datapackages
# 3) publishing an update will remove provenance (datapack package might help with this but not sure how)
# 4) lter data can't be annotated (or at least most of them? tryCatchLog for these)
# 5) deal with dataTables that already have sem annotations that may get removed during update of new annotations

##########################################################################################
# General Setup
##########################################################################################

# load packages
library(dataone)
library(datapack)
library(arcticdatautils) # to install: `remotes::install_github("nceas/arcticdatautils")` BUT CAN'T USE THIS
library(EML)
library(uuid)
library(tryCatchLog)
library(futile.logger) 
library(tidyverse)

# get (test) token reminder
# options(dataone_test_token = "...")

# set nodes 
# cn_staging <- CNode('STAGING')
# adc_test <- getMNode(cn_staging,'urn:node:mnTestARCTIC')
d1c_test <- dataone::D1Client("STAGING", "urn:node:mnTestARCTIC")

# configure tryCatchLog
flog.appender(appender.file("error.log")) # choose files to log errors to
flog.threshold(ERROR) # set level of error logging (options: TRACE, DEBUG, INFO, WARM, ERROR, FATAL)

# create hash table to store attribute ids (keys) in (to determine uniqueness)
my_hash <- new.env(hash = TRUE)

# create empty vector to store duplicate attribute ids
duplicate_ids <- c()

# import custom functions
source(here::here("code", "10a_automate_semAnnotations_functions.R"))

# import data
attributes <- read_csv(here::here("data", "outputs", "annotate_these_attributes_2020-12-17_webscraped.csv"))

##########################################################################################
# add semantic annotations for ONE datapackage (PRACTICE)
##########################################################################################

##############################
# FOR TESTING PURPOSES ONLY
##############################

# test package data
attributes_filtered <- attributes %>%
  filter(identifier == "doi:10.18739/A24B2X46G") %>%
  mutate(
    practice_identifier = case_when(
      identifier == "doi:10.18739/A24B2X46G" ~ "urn:uuid:c84fec1f-33c6-4042-8605-33ab76e20a0f"
    )
  ) %>%
  select(-identifier) %>%
  rename(identifier = practice_identifier) %>%
  mutate(query_datetime_utc = as.character(query_datetime_utc))

# create dummy row
df <- data.frame(entityName  = c("NA"), attributeName = c("NA"), attributeLabel = c("NA"),
                 attributeDefinition = c("NA"), attributeUnit = c("NA"), propertyURI = c("NA"),
                 valueURI = c("NA"), viewURL = c("NA"), query_datetime_utc = c("NA"),
                 status = c("NA"), assigned_valueURI = c("NA"), prefName = c("NA"), ontoName = c("NA"),
                 identifier = c("test_id"))

# combine test package data with dummy data
attributes <- rbind(attributes_filtered, df) %>%
  filter(identifier != "test_id")

##############################
# get vector of all unique datapackages
##############################

unique_datapackage_ids <- unique(attributes$identifier)

##############################
# annotate datapackages
##############################

# ----------------------- 1) get metadata/info for a particular datapackage -----------------------

for(dp_num in 1:length(unique_datapackage_ids)){
  
  # 1.1) subset 'attributes' df for current datapackage
  current_datapackage_id <- unique_datapackage_ids[dp_num]
  current_datapackage_subset <- attributes %>% 
    dplyr::filter(identifier == current_datapackage_id) 
  message("Subsetted semantic annotation df for datapackage: ", current_datapackage_id)
  
  # 1.2) build resource map for that datapackage
  current_resource_map <- paste("resource_map_", current_datapackage_id, sep = "")
  message("Generated resource map: ", current_resource_map)
  
  # 1.3) get metadata !!!!!!!!!!!!!!!!!(might need if else here...if error record and go to next id, else continue to #2)!!!!!!!!!!!!!!!!! 
  step1_list <- tryLog(get_datapackage_metadata(current_resource_map),
         write.error.dump.file = TRUE, write.error.dump.folder = "dump_files",
         include.full.call.stack = FALSE)
  
  # 1.4) parse outputs
  current_pkg <- step1_list[[1]]
  current_metadata_pid <- step1_list[[2]]
  doc <- step1_list[[3]]
  
  # 1.5) get dataTables from eml file 
  dataTables_from_metadata <- doc$dataset$dataTable
  message("****This datapackage has ", length(dataTables_from_metadata), " dataTables****")
  
  # ----------------------- 2) get a dataTable (entityName) from metadata; find match in df -----------------------
  
  for(dt_num in 1:length(dataTables_from_metadata)){

    # 2.1) get current dataTable name from metadata 
    current_dataTable_name_from_eml <- dataTables_from_metadata[[dt_num]]$entityName
    
    # 2.2) subset 'current_datapackage_subset' accordingly
    current_dataTable_subset <- tryLog(current_datapackage_subset %>%
      filter(entityName == current_dataTable_name_from_eml))
    message("*****************************************************")
    message("Working on dataTable ", dt_num, ": ", current_dataTable_name_from_eml)
    message("*****************************************************")
    
    # ----------------------- 3) annotate attributes in current dataTable -----------------------

    for(att_num in 1:length(current_dataTable_subset$attributeName)){
      
      # 3.1) get attribute from dataTable in eml
      current_attribute_name_from_eml <- doc$dataset$dataTable[[dt_num]]$attributeList$attribute[[att_num]]$attributeName
      message("--> Found attribute #", att_num, " : '", current_attribute_name_from_eml, "'")
      
      # 3.2) match attribute from eml with the appropriate row in current_dataTable_subset
      current_attribute_subset <- current_dataTable_subset %>% 
        filter(attributeName == current_attribute_name_from_eml)
      message("The corresponding attribute to #", att_num, " in the df is: '", current_attribute_subset$attributeName, "'")
      
      # 3.3) create attribute id
      current_attribute_id <- build_attributeID(dataTable_number = dt_num, attribute_number = att_num)
      
      # 3.4) verify that the attribute id is unique across datapackage
      verify_attributeID_isUnique(current_attribute_id = current_attribute_id)
      
      # 3.5) add attribute id to metadata
      doc$dataset$dataTable[[dt_num]]$attributeList$attribute[[att_num]]$id <- current_attribute_id
      message("Added attributeID, '", current_attribute_id, "' to metadata")
      
      # 3.6) create/add property URI to metadata (same for all attributes)
      doc$dataset$dataTable[[dt_num]]$attributeList$attribute[[att_num]]$annotation$propertyURI <- list(label = "contains meausurements of",
                                                                                                        propertyURI = "http://ecoinformatics.org/oboe/oboe.1.2/oboe-core.owl#containsMeasurementsOfType")
      
      # 3.7) add value URI to metadata
      current_valueURI <- current_attribute_subset$assigned_valueURI
      current_label <- current_attribute_subset$prefName
      doc$dataset$dataTable[[dt_num]]$attributeList$attribute[[att_num]]$annotation$valueURI <- list(label = current_label,
                                                                                                     valueURI = current_valueURI)
      message("Added semantic annotation URI, '", current_valueURI, "' to metadata for attribute, '", current_attribute_name_from_eml, "'")
    }
    
  }
  
  # ----------------------- 4) validate doc -----------------------
  
  # 4.1) validate doc !!!!!!!!!!!!!!!NEED IF ELSE HERE!!!!!!!!!!!!!!!!!!!!
  eml_validate(doc) 
  
  # 4.2) generate new pid for metadata !!!!!!!!!!!!!!!!!!!!!!!NEED TO DEAL WITH UUID VS DOI VS PASTA!!!!!!!!!!!!!!!!!!!!!!!
  doi <- dataone::generateIdentifier(d1c_test@mn, "DOI")
  
  # 4.3) write eml path
  eml_path <- paste("/Users/samanthacsik/Repositories/NCEAS-DF-semantic-annotations-review/eml/datapackage", dp_num, ".xml", sep = "") 
  
  # 4.4) write eml
  write_eml(doc, eml_path) # save your metadata

  # ----------------------- 5) publish update -----------------------

  # 5.1) replace original metadata pid with new pid
  dp <- replaceMember(current_pkg, current_metadata_pid, replacement = eml_path, newId = doi)

  # # 5.2)  datapackage
  newPackageId <- uploadDataPackage(d1c_test, dp, public = FALSE, quiet = FALSE) 
  message("--------------Datapackage ", dp_num, " complete!--------------")
  
}



















