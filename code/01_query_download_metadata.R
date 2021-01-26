# title: Extract identifiers using solr query + tidy attributes using `eatocsv` package
# author: "Sam Csik, adapted from Steven Chong"
# date created: "2020-10-02"
# date edited: "2020-10-12"
# R version: 3.6.3
# input: NA
# output: "data/queries/*", "data/queries/*"

##########################################################################################
# Summary
##########################################################################################

# 1) Use solr query to extract package identifiers for all ADC holdings
    # a) 2020-10-01 = first attempt
    # b) 2020-10-12 = second attempt, also queried for dates
# 2) Use identifiers to extract/download associated .xml files 
# 3) Extract attribute-level metadata from downloaded .xml files and save as .csv

##############################
# Load packages
##############################

source(here::here("code", "00_libraries.R"))

##############################
# set nodes & get token
##############################

# token reminder
options(dataone_test_token = "...")

# nodes
cn <- CNode("PROD")
adc_mn <- getMNode(cn, 'urn:node:ARCTIC')

##########################################################################################
# 1) query all ADC holdings (only the most recent published version) for identifiers, titles, keywords, abstracts, and attribute info
##########################################################################################

# solr query (most recent versions)
semAnnotations_query <- query(adc_mn, 
                              list(q = "documents:* AND obsolete:(*:* NOT obsoletedBy:*)",
                                   fl = "identifier, dateUploaded, datePublished, pubDate, author, title, keywords, abstract, attribute, sem_annotates, sem_annotation, sem_annotated_by, sem_comment",
                                   rows = "7000"),
                              as = "data.frame")

# write.csv(semAnnotations_query, file = here::here("data", "queries", "query2020-10-12", paste("fullQuery_semAnnotations", Sys.Date(),".csv", sep = "")), row.names = FALSE)

##########################################################################################
# 2) download metadata from the Arctic Data Center using package identifiers from solr query above
##########################################################################################

# read in the .csv file containing the package identifiers
identifiers_file <- list.files(path = here::here("data", "queries", "query2020-10-12"), full.names = TRUE, pattern = "*.csv")
identifiers_df <- read.csv(here::here("data", "queries", "query2020-10-12", "fullQuery_semAnnotations2020-10-12_solr.csv"), stringsAsFactors = FALSE)

# filter out any data packages that don't have semantic annotations
clean_identifiers_df <- identifiers_df %>% 
  filter(sem_annotation != "NA")

# download .xml files for each data package 
for (index in 1:length(clean_identifiers_df$identifier)) {
  identifier <- clean_identifiers_df$identifier[[index]]
  cn <- CNode("PROD")
  download_objects(node = cn,
                   pids = identifier,
                   path = here::here("data", "queries", "query2020-10-12", "xml")) 
  progress(index, max.value = length(clean_identifiers_df$identifier))
}

##########################################################################################
# 3) extract entity and attribute information, including property and valueURIs associated with any attributes
##########################################################################################

# extract attribute-level metadata from all downloaded .xml files in the working directory
document_paths <- list.files(setwd(here::here("data", "queries", "query2020-10-12", "xml")), full.names = TRUE, pattern = "*.xml")
attributes <- extract_ea(document_paths)

# make the output CSV file prefix based on the input CSV file name
file_prefix <- basename(identifiers_file)
file_prefix <- gsub(".csv","", file_prefix)

# create the CSV file containing the entity-attribute metadata
write.csv(attributes, file = here::here("data", "queries", "query2020-10-12", paste0(file_prefix, "_attributes.csv")), row.names = FALSE)
print(paste0(file_prefix, "_attributes.csv created"))

# import data to view
extracted_attributes <- read_csv(here::here("data", "queries", "query2020-10-12", "fullQuery_semAnnotations2020-10-12_attributes.csv"))


##########################################################################################
##########################################################################################
##########################################################################################
##########################################################################################

##########################################################################################
# UPDATE: want to confirm which datapackages are public for batch update in script 10b; re-query all ADC holdings (only the most recent published version) for "isPublic" field to join with existing dataframes containing attributes and semantic annotations
##########################################################################################

# solr query (most recent versions)
semAnnotations_query <- query(adc_mn, 
                              list(q = "documents:* AND obsolete:(*:* NOT obsoletedBy:*)",
                                   fl = "identifier, dateUploaded, datePublished, pubDate, isPublic, author, title, keywords, abstract, attribute, sem_annotates, sem_annotation, sem_annotated_by, sem_comment",
                                   rows = "7500"),
                              as = "data.frame")

write_csv(semAnnotations_query, here::here("data", "queries", "query2021-01-25_isPublic", paste("fullQuery_semAnnotations_isPublic", Sys.Date(),".csv", sep = "")))

