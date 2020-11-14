# title: Tidying attributes for nonannotated datapackages using eatocsv
# author: "Sam Csik"
# date created: "2020-11-12"
# date edited: "2020-11-13"
# R version: 3.6.3
# input: "data/queries/query2020-10-12/fullQuery_semAnnoatations2020-10-12_attributes.csv" & "data/queries/query2020-10-12/fullQuery_semAnnotations2020-10-12_labeledACADIS.csv"
# output: "data/queries/query2020-10-12_nonannoated_attributes/*"

##########################################################################################
# Summary
##########################################################################################

# We want to rapidly increase the number of datapackages that have at least one annotated attribute (preferrably more, but it's a start)
# To do so, we are first tackling the low-hanging fruit -- attributes that occur in many datapackages e.g. latitude, longitude, datetime, etc.
# We do not need to worry about ACADIS datasets -- these can be removed
# We already have tidied attributes for those datapackages that DO have at least one annotated attribute (though there are still some that are missing annotations). We can remove these as well to improv processing time
# Here, we use the `eatocsv` package to tidy the remaining 2352 datapackages that don't yet have any annotated attributes
  # NOTE: only 1323/2352 datapackages ended up having attributes listed in their metadata (see `line 100`)

##############################
# Load packages
##############################

source(here::here("code", "00_libraries.R"))

##############################
# Get token
##############################

# reminder
options(dataone_test_token = "...")

##############################
# Import data
##############################

# all of ACD corpus, but attributes are not tidy
# solr_query <- read_csv(here::here("data", "queries", "query2020-10-12", "fullQuery_semAnnotations2020-10-12_solr.csv"))

# tidy attributes, but only from 185 datapackages that have at least 1 annotated attribute
extracted_attributes <- read_csv(here::here("data", "queries", "query2020-10-12", "fullQuery_semAnnotations2020-10-12_attributes.csv"))

# solr query with ACADIS datasets identified in 'dataSubset' column
solr_query_ACADIS <- read_csv(here::here("data", "queries", "query2020-10-12", "fullQuery_semAnnotations2020-10-12_labeledACADIS.csv"))

##########################################################################################
# get tidied attributes for datapackages that have NO annotations
  # a) remove ACADIS datapackages
  # b) remove datapackages that already have at least one annotation (to save processing time)
  # c) feed remaining identifiers through the `eatocsv` pipeline to tidy attributes
##########################################################################################

##############################
# a) remove ACADIS datapackages from solr query since we're not going to be annotating any ACADIS datapackages, at least for now
##############################

solr_minus_ACADIS <- solr_query_ACADIS %>% 
  filter(is.na(dataSubset))

##############################
# b) remove datapackages that we already have tidied attributes for (this will save processing time when using eatocsv)
##############################

distinctIDs_extracted_attributes <- extracted_attributes %>% 
  distinct(identifier)

attributes_to_be_tidied <- solr_minus_ACADIS %>% 
  anti_join(distinctIDs_extracted_attributes)

# write_csv(attributes_to_be_tidied, here::here("data", "queries", "query2020-10-12_nonannotated_attributes", "attributes_to_be_tidied.csv"))

##############################
# c) tidy attributes using eatocsv package 
##############################

# read in the .csv file containing the package identifiers
identifiers_file <- list.files(path = here::here("data", "queries", "query2020-10-12_attributes_from_nonannotated_datapackages"), full.names = TRUE, pattern = "*.csv")
identifiers_df <- read.csv(here::here("data", "queries", "query2020-10-12_attributes_from_nonannotated_datapackages", "attributes_to_be_tidied.csv"), stringsAsFactors = FALSE)

# download .xml files for each data package 
for (index in 1:length(identifiers_df$identifier)) {
  identifier <- identifiers_df$identifier[[index]]
  cn <- CNode("PROD")
  download_objects(node = cn,
                   pids = identifier,
                   path = here::here("data", "queries", "query2020-10-12_attributes_from_nonannotated_datapackages", "xml")) 
  progress(index, max.value = length(identifiers_df$identifier))
}

# extract attribute-level metadata from all downloaded .xml files in the working directory
document_paths <- list.files(setwd(here::here("data", "queries", "query2020-10-12_attributes_from_nonannotated_datapackages", "xml")), full.names = TRUE, pattern = "*.xml")
attributes <- extract_ea(document_paths)

# create the CSV file containing the entity-attribute metadata
write.csv(attributes, file = here::here("data", "queries", "query2020-10-12_attributes_from_nonannotated_datapackages", "attributes_from_nonannotated_datapackages_tidied.csv"), row.names = FALSE)

# import data to view
extracted_attributes <- read_csv(here::here("data", "queries", "query2020-10-12_attributes_from_nonannotated_datapackages", "attributes_from_nonannotated_datapackages_tidied.csv"))

length(unique(extracted_attributes$identifier))
