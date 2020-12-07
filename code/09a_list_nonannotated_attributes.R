# title: Identifying attributes to be annotated -- extract nonannotatd attributes (from both previously partially-annotated datapackages as well as non-ACADIS datapackages that have not yet been annotated)
# author: "Sam Csik"
# date created: "2020-11-13"
# date edited: "2020-11-20"
# R version: 3.6.3
# input: "data/queries/query2020-10-12/fullQuery_semAnnotations2020-10-12_attributes.csv" & "data/queries/query2020-10-12_attributes_from_nonannotated_datapackages/attributes_from_nonannotated_datapackages_tidied.csv"
# output: "data/output/annotate_these_attributes_2020-11-17.csv"

##########################################################################################
# Summary
##########################################################################################


##############################
# Load packages
##############################

source(here::here("code", "00_libraries.R"))

##############################
# Import data
##############################

# from datapackages that already have at least one annotation; remove annotated attributes
extracted_attributes_from_annotated_datapackages <- read_csv(here::here("data", "queries", "query2020-10-12", "fullQuery_semAnnotations2020-10-12_attributes.csv")) %>% 
  filter(is.na(valueURI)) %>% 
  mutate(status = rep("dp has at least one annotation"))

# from datapackages that do not yet have any annotations (does NOT include ACADIS data)
extracted_attributes_from_nonAnnotated_datapackages <- read_csv(here::here("data", "queries", "query2020-10-12_attributes_from_nonannotated_datapackages", "attributes_from_nonannotated_datapackages_tidied.csv")) %>% 
  mutate(status = rep("dp was never annotated"))

##########################################################################################
# 1) combine all nonannotated attributes into a single df
##########################################################################################

# combine
nonannotated_attributes <- rbind(extracted_attributes_from_annotated_datapackages, extracted_attributes_from_nonAnnotated_datapackages)
# write_csv(nonannotated_attributes, here::here("data", "outputs", "nonannotated_attributes_2020-10-12.csv"))

# clean up environment
rm(extracted_attributes_from_annotated_datapackages, extracted_attributes_from_nonAnnotated_datapackages)

# inspect attributeNames
unique_nonAnnotated_attNames <- nonannotated_attributes %>% 
  count(attributeName) %>% 
  arrange(attributeName)
