# title: testing take 2
# author: "Sam Csik"
# date created: "2021-01-04"
# date edited: "2021-01-11"
# R version: 3.6.3
# input: "data/outputs/annotate_these_attributes_2020-12-17_webscraped.csv" NEED TO UPDATE THIS
# output: no output, but publishes updates to arcticdata.io 

##########################################################################################
# Summary
##########################################################################################

# NOTES FROM TESTING SO FAR:
  # 1) pre-existing annotations will be preserved upon datapackage update (when using datapack at least)
  # 2) relationships between child and parent datapackages are NOT preserved upon update
  # 3) prov is supposedly preserved upon update when using datapack (but haven't tested this yet; need to find example to test on still)

# CONSIDERATIONS:
  # 1) update subsets of datapackages at a time; how/when to do this in the most non-intrusive way possible to minimize indexing delays
  # 2) child/parent relationships
  # 3) can we update LTER data (still need to test this; Jasmine mentioned we might not have access to update LTER datapackages? 364 total)
  # 4) does a package's doi (or uuid) always match that of it's resource map?
  # ---- add to solr query isPublic and filter out any that are not

# arcticdatautils::get_package() will return child packages 
  # get_package() on everything in list and saved child datasets in df
  # use that list to determine which are children and which are parents
  # need different workflows for parent and child packages
    # child first (need to add an extra step which is updating the parent resource map), then parents (current workflow won't work for parent packages)
  # bryce, chris

# find standalones and update those (easy)

# split out making changes vs updates
# determine number of data files within a dp and then update those with less than X number of files
# run this in small subsets based on number of datatables
# run update loop in tryCatchLog()

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

# get (test) token reminder
# options(dataone_test_token = "...")

# set nodes (will need to change to `dataone::D1Client("PROD", "urn:node:ARCTIC")`) 
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

# import data (removing lter data for now, only 364 datapackages)
attributes <- read_csv(here::here("data", "outputs", "annotate_these_attributes_2020-12-17_webscraped.csv")) %>% 
  filter(!str_detect(identifier, "(?i)https://pasta.lternet.edu"))
  
##########################################################################################
# add semantic annotations for ONE datapackage (PRACTICE)
##########################################################################################

##############################
# FOR TESTING PURPOSES ONLY
##############################

# available on test.arctic.io for practice
  # doi:10.18739/A2D21RH94 --> resource_map_urn:uuid:258799f9-a37b-4e8a-a7f1-ff365b691d1d (not yet tested; LARGE PACKAGE)

# test package data
attributes <- attributes %>%
  filter(identifier %in% c("doi:10.18739/A2D21RH94")) %>%
  mutate(
    practice_identifier = case_when(
      identifier == "doi:10.18739/A2D21RH94" ~ "urn:uuid:73279597-6b32-4f7b-a345-2bc928541800"
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
# annotate datapackages
##############################

# ----------------------- 1) get metadata/info for a particular datapackage -----------------------

for(dp_num in 1:length(unique_datapackage_ids)){
  
  # 1.1) subset 'attributes' df for current datapackage
  current_datapackage_id <- unique_datapackage_ids[dp_num]
  current_datapackage_subset <- attributes %>% 
    dplyr::filter(identifier == current_datapackage_id) 
  message("Subsetted semantic annotation df for datapackage: ", current_datapackage_id)
  
  # 1.2) get metadata 
  step1_list <- tryLog(get_datapackage_metadata(current_datapackage_id), 
         write.error.dump.file = TRUE, write.error.dump.folder = "dump_files",
         include.full.call.stack = FALSE)
  
  # 1.3) parse outputs
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
    num_attributes_in_eml_dataTable <- length(dataTables_from_metadata[[dt_num]]$attributeList$attribute)
    
    # 2.2) subset 'current_datapackage_subset' accordingly
    current_dataTable_subset <- tryLog(current_datapackage_subset %>%
      filter(entityName == current_dataTable_name_from_eml))
    message("*****************************************************")
    message("Working on dataTable ", dt_num, " (", current_dataTable_name_from_eml, "), which contains ", num_attributes_in_eml_dataTable, " attributes")
    message("There are ", length(current_dataTable_subset$attributeName), " attributes to be annotated for this dataTable")
    message("*****************************************************")
    
    # ----------------------- 3) annotate attributes in current dataTable -----------------------

    for(att_num in 1:num_attributes_in_eml_dataTable){
      
      # 3.1) get attribute from dataTable in eml ****IF ELSE TO INCLUDE OTHERENTITIES*** - check with `eatocsv` pkg to see how/where it's extracting attribute information
      current_attribute_name_from_eml <- doc$dataset$dataTable[[dt_num]]$attributeList$attribute[[att_num]]$attributeName
      message("--> Found attribute #", att_num, " : '", current_attribute_name_from_eml, "'")
      
      # 3.2) subset df using current_attribute_name_from_eml 
      current_attribute_subset <- current_dataTable_subset %>% 
        filter(attributeName == current_attribute_name_from_eml)
      
      # 3.3) if eml attribute exists in df, continue, if not move to next attribute in eml
      if(length(current_attribute_subset$attributeName > 0)){ 
        
        message("The corresponding attribute to #", att_num, " in the df is: '", current_attribute_subset$attributeName, "'")
        
        # 3.4) create attribute id 
        current_attribute_id <- build_attributeID(dataTable_number = dt_num, attribute_number = att_num)
        
        # 3.5) verify that the attribute id is unique across datapackage
        verify_attributeID_isUnique(current_attribute_id = current_attribute_id)
        
        # 3.6) add attribute id to metadata
        doc$dataset$dataTable[[dt_num]]$attributeList$attribute[[att_num]]$id <- current_attribute_id
        message("Added attributeID, '", current_attribute_id, "' to metadata")
        
        # 3.7) create/add property URI to metadata (same for all attributes)
        doc$dataset$dataTable[[dt_num]]$attributeList$attribute[[att_num]]$annotation$propertyURI <- list(label = "contains meausurements of",
                                                                                                          propertyURI = "http://ecoinformatics.org/oboe/oboe.1.2/oboe-core.owl#containsMeasurementsOfType")
        
        # 3.8) add value URI to metadata
        current_valueURI <- current_attribute_subset$assigned_valueURI
        current_label <- current_attribute_subset$prefName
        doc$dataset$dataTable[[dt_num]]$attributeList$attribute[[att_num]]$annotation$valueURI <- list(label = current_label,
                                                                                                       valueURI = current_valueURI)
        message("Added semantic annotation URI, '", current_valueURI, "' to metadata for attribute, '", current_attribute_name_from_eml, "'")
        
      } else {
        
        message("No match was found in the df for the attribute: '", current_attribute_name_from_eml, "'")

        next
      }
      
    }
    
  }
  
  # ----------------------- 4) validate doc -----------------------
  
  # 4.1) validate doc ****NOT SURE IF THIS TRYLOG IS APPROPRIATE HERE YET?****
  message("validating eml.....")
  tryLog(eml_validate(doc), 
         write.error.dump.file = TRUE, write.error.dump.folder = "dump_files",
         include.full.call.stack = FALSE) 
  
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
  eml_path <- paste("/Users/samanthacsik/Repositories/NCEAS-DF-semantic-annotations-review/eml/datapackage", dp_num, ".xml", sep = "") 
  
  # 4.4) write eml
  write_eml(doc, eml_path) # save your metadata

  # ----------------------- 5) publish update -----------------------

  # 5.1) replace original metadata pid with new pid
  dp <- replaceMember(current_pkg, current_metadata_pid, replacement = eml_path, newId = new_id)

  # 5.2)  datapackage
  newPackageId <- uploadDataPackage(d1c_test, dp, public = FALSE, quiet = FALSE)
  message("--------------Datapackage ", dp_num, " complete!--------------")
  
}



