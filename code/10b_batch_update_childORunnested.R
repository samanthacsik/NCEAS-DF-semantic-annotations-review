# title: workflow for child or unnested data packages
# author: "Sam Csik"
# date created: "2021-01-04"
# date edited: "2021-01-26"
# R version: 3.6.3
# input: "data/outputs/annotate_these_attributes_2020-12-17_webscraped.csv" NEED TO UPDATE THIS WITH DATA SUBSETS WHEN RUNNING FOR REAL
# output: no output, but publishes updates to arcticdata.io 

##########################################################################################
# Summary
##########################################################################################

# CONSIDERATIONS:
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

# get (test) token reminder
# options(dataone_test_token = "...")

# set nodes (will need to change to `dataone::D1Client("PROD", "urn:node:ARCTIC")`) 
d1c_test <- dataone::D1Client("STAGING", "urn:node:mnTestARCTIC") 

##############################
# configure tryCatchLog and create new hash/vector for verying id uniqueness
##############################

# configure tryCatchLog -- NEED TO LEARN MORE ABOUT THIS
flog.appender(appender.file("error.log")) # choose files to log errors to
flog.threshold(ERROR) # set level of error logging (options: TRACE, DEBUG, INFO, WARM, ERROR, FATAL)

# create hash table to store attribute ids (keys) in (to determine uniqueness)
my_hash <- new.env(hash = TRUE)

# create empty vector to store duplicate attribute ids
duplicate_ids <- c()

##############################
# import custom functions
##############################

source(here::here("code", "10a_automate_semAnnotations_functions.R"))

##############################
# import data (no lter data, https://pasta.lternet.edu = 364 pkgs) 
##############################

attributes <- read_csv(here::here("data", "outputs", "attributes_to_annotate", "all_attributes_to_annotate_sorted_by_pkgType_2020-01-19.csv"),
                       col_types = cols(.default = col_character()))
length(unique(attributes$identifier))

##############################
# add 'status' to attributes df (idk where/how it got removed but nice to have for reference)
##############################

status <- read_csv(here::here("data", "outputs", "annotate_these_attributes_2020-12-17_webscraped.csv")) %>%
  filter(!str_detect(identifier, "(?i)https://pasta.lternet.edu")) %>%
  select(identifier, status) %>% 
  distinct(identifier, status)

attributes <- left_join(attributes, status)
length(unique(attributes$identifier))

##############################
# join 'isPublic' column from solr query on 2021-01-25 with 'attributes' df (we decided it's best to filter out any datapackages that aren't yet public so that we don't interfere with ongoing curation)
##############################

isPublic <- read_csv(here::here("data", "queries", "query2021-01-25_isPublic", "fullQuery_semAnnotations_isPublic2021-01-25.csv")) %>% 
  select(identifier, isPublic) %>% 
  replace_na(list(identifier = "FALSE", isPublic = "FALSE")) %>% 
  distinct(identifier, isPublic)

attributes <- left_join(attributes, isPublic) %>% # 14 (NA), 17 (FALSE), 1061 (TRUE)
  filter(isPublic == "TRUE")
length(unique(attributes$identifier))

rm(isPublic, status)

##########################################################################################
# add semantic annotations for ONE datapackage (PRACTICE)
##########################################################################################

##############################
# FOR TESTING PURPOSES ONLY -- using pkgs cloned to test.arctic.io
##############################

# available on test.arctic.io for practice
  # parent: urn:uuid:994490f4-3fb1-4b74-938b-090500fde2af (original: doi:10.18739/A2RJ48V9W)
  # child 1: urn:uuid:d1583d76-dc5d-4846-b3cb-69c122cbddc7 (original: doi:10.18739/A24B2X46G)

# test package data
attributes <- attributes %>%
  filter(identifier %in% c("doi:10.18739/A2RJ48V9W", "doi:10.18739/A24B2X46G")) %>%
  mutate(
    practice_identifier = case_when(
      identifier == "doi:10.18739/A2RJ48V9W" ~ "urn:uuid:994490f4-3fb1-4b74-938b-090500fde2af",
      identifier == "doi:10.18739/A24B2X46G" ~ "urn:uuid:d1583d76-dc5d-4846-b3cb-69c122cbddc7"
    )
  ) %>%
  select(-identifier) %>%
  rename(identifier = practice_identifier) %>%
  mutate(query_datetime_utc = as.character(query_datetime_utc))

##############################
# get vector of all unique datapackages
##############################

unique_datapackage_ids <- unique(attributes$identifier)

##############################
# annotate datapackages -- CURRENTLY WRAPPING WHOLE LOOP IN TRYLOG() BUT NOT SURE IF THIS IS THE WAY TO GO JUST YET
##############################

# ----------------------- 1) get metadata/info for a particular datapackage -----------------------

tryLog(for(dp_num in 1:length(unique_datapackage_ids)){
  
  # 1.1) subset 'attributes' df for current datapackage
  current_datapackage_id <- unique_datapackage_ids[dp_num]
  current_datapackage_subset <- attributes %>% 
    dplyr::filter(identifier == current_datapackage_id) 
  message("Subsetted semantic annotation df for datapackage: ", current_datapackage_id)
  
  # 1.2) get metadata 
  step1_list <- get_datapackage_metadata(current_datapackage_id)
  
  # 1.3) parse outputs
  current_pkg <- step1_list[[1]]
  current_metadata_pid <- step1_list[[2]]
  doc <- step1_list[[3]]
  
  # 1.5) get dataTables from eml file 
  dataTables_from_metadata <- doc$dataset$dataTable
  message("****This datapackage has ", length(dataTables_from_metadata), " dataTables****")
  message("*****************************************************")
  
  # ----------------------- 2) get a dataTable (entityName) from metadata; find match in df -----------------------
  
  for(dt_num in 1:length(dataTables_from_metadata)){

    # 2.1) get current dataTable name from metadata 
    current_dataTable_name_from_eml <- dataTables_from_metadata[[dt_num]]$entityName
    num_attributes_in_eml_dataTable <- length(dataTables_from_metadata[[dt_num]]$attributeList$attribute)
    
    # 2.2) subset 'current_datapackage_subset' accordingly
    current_dataTable_subset <- current_datapackage_subset %>% 
      filter(entityName == current_dataTable_name_from_eml)
    
    # intialize annotation counter
    annotation_counter <- 0
    
    # ----------------------- 3) annotate attributes in current dataTable -----------------------

    for(att_num in 1:num_attributes_in_eml_dataTable){
      
      # 3.1) get attribute from dataTable in eml ****IF ELSE TO INCLUDE OTHERENTITIES*** - check with `eatocsv` pkg to see how/where it's extracting attribute information
      current_attribute_name_from_eml <- doc$dataset$dataTable[[dt_num]]$attributeList$attribute[[att_num]]$attributeName
      # message("--> Found attribute #", att_num, " : '", current_attribute_name_from_eml, "'")
      
      # 3.2) subset df using current_attribute_name_from_eml 
      current_attribute_subset <- current_dataTable_subset %>% 
        filter(attributeName == current_attribute_name_from_eml)
      
      # 3.3) if eml attribute exists in df, continue, if not move to next attribute in eml
      if(length(current_attribute_subset$attributeName > 0)){ 
        
        # message("The corresponding attribute to #", att_num, " in the df is: '", current_attribute_subset$attributeName, "'")
        
        # 3.4) create attribute id 
        current_attribute_id <- build_attributeID(dataTable_number = dt_num, attribute_number = att_num)
        
        # 3.5) verify that the attribute id is unique across datapackage
        verify_attributeID_isUnique(current_attribute_id = current_attribute_id)
        
        # 3.6) add attribute id to metadata
        doc$dataset$dataTable[[dt_num]]$attributeList$attribute[[att_num]]$id <- current_attribute_id
        # message("Added attributeID, '", current_attribute_id, "' to metadata")
        
        # 3.7) create/add property URI to metadata (same for all attributes)
        doc$dataset$dataTable[[dt_num]]$attributeList$attribute[[att_num]]$annotation$propertyURI <- list(label = "contains meausurements of",
                                                                                                          propertyURI = "http://ecoinformatics.org/oboe/oboe.1.2/oboe-core.owl#containsMeasurementsOfType")
        
        # 3.8) add value URI to metadata
        current_valueURI <- current_attribute_subset$assigned_valueURI
        current_label <- current_attribute_subset$prefName
        doc$dataset$dataTable[[dt_num]]$attributeList$attribute[[att_num]]$annotation$valueURI <- list(label = current_label,
                                                                                                       valueURI = current_valueURI)
        # message("Added semantic annotation URI, '", current_valueURI, "' to metadata for attribute, '", current_attribute_name_from_eml, "'")
        annotation_counter <- annotation_counter + 1
        
      } else {
        
        # message("No match was found in the df for the attribute: '", current_attribute_name_from_eml, "'")

        next
      }
      
    }
    
    annos_to_annotate <- length(current_dataTable_subset$attributeName)
    message("Processed dataTable: ", dt_num, " | ", current_dataTable_name_from_eml)
    message("Attributes in Metadata -> ", num_attributes_in_eml_dataTable, " | attributes to annotate -> ", annos_to_annotate, " | Added -> ", annotation_counter, " | Complete -> ", (annos_to_annotate == annotation_counter))
    message("*****************************************************")
    
  }
  
  # ----------------------- 4) validate doc -----------------------
  
  # 4.1) validate doc 
  message("validating eml.....")
  eml_validate(doc)
  
  # 4.2) generate new pid (either doi or uuid depending on what the original had) for metadata NEED TO DISCUSS WHAT DATASETS WE SHOULD/SHOULD NOT UPDATE
  if(isTRUE(str_detect(current_metadata_pid, "(?i)doi"))) {
    new_id <- dataone::generateIdentifier(d1c_test@mn, "DOI")
    message("Generating a new metadata DOI: ", new_id)
  } else if(isTRUE(str_detect(current_metadata_pid, "(?i)urn:uuid"))) {
    new_id <- dataone::generateIdentifier(d1c_test@mn, "UUID")
    message("Generating a new metadata uuid: ", new_id)
  } else {
    warning("The original metadata ID format, ", current_metadata_pid, " is not recognized. No new ID has been generated.")
    print("NOTE FOR SAM: need to figure out how to acutally deal with this if it ever comes up")
  }
  
  # 4.3) write eml path
  # eml_path <- paste("/Users/samanthacsik/Repositories/NCEAS-DF-semantic-annotations-review/eml/datapackage", dp_num, ".xml", sep = "") 
  
  # 4.4) write eml
  # write_eml(doc, eml_path) # save your metadata

  # ----------------------- 5) publish update -----------------------

  # 5.1) replace original metadata pid with new pid
  # dp <- replaceMember(current_pkg, current_metadata_pid, replacement = eml_path, newId = new_id)

  # 5.2)  datapackage
  # newPackageId <- uploadDataPackage(d1c_test, dp, public = FALSE, quiet = FALSE)
  message("--------------Datapackage ", dp_num, " complete!--------------")
  
}, write.error.dump.file = TRUE, write.error.dump.folder = "dump_files", include.full.call.stack = FALSE)



