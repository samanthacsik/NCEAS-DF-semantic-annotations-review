# title: Initial exploration and Webscraping for Annotation Information
# author: "Sam Csik"
# date created: "2020-10-19"
# date edited: "2020-10-21"
# R version: 3.6.3
# input: "data/queries/query2020-10-12/fullQuery_semAnnotations2020-10-12_attributes.csv"
# output: "data/queries/query2020-10-12/fullQuery_semAnnotations2020-10-12_webscraping.csv"

##########################################################################################
# Summary
##########################################################################################

# 1) do some initial exploration to get an idea of how many data packages have annotations, how many annotations exist across those packages, etc.
# 2) create objects for inline text values to be used in RMarkdown report

##########################################################################################
# General setup
##########################################################################################

##############################
# Load packages & custom functions
##############################

source(here::here("code", "00_libraries.R"))
source(here::here("code", "00_functions.R"))

##############################
# Import data
##############################

solr_query <- read_csv(here::here("data",  "queries", "query2020-10-12", "fullQuery_semAnnotations2020-10-12_solr.csv"))
extracted_attributes <- read_csv(here::here("data", "queries", "query2020-10-12", "fullQuery_semAnnotations2020-10-12_attributes.csv"))

##########################################################################################
# 1) General exploration
##########################################################################################

##############################
# how many data packages have annotations?
##############################

# 6142 total data packages in the ADC
num_total_datapackages <- length(unique(solr_query$identifier))

# for RMarkdown -- total data packages containing attributes
attributes_only <- solr_query %>% 
  filter(attribute != "NA") 

# for RMarkdown
num_datapackages_with_attributes <- length(attributes_only$attribute)

# for RMarkdown - 185 data packages with annotations
num_datapackages_with_annotations <- length(unique(extracted_attributes$identifier))

# double check that I'm not crazy -- 185 datasets with semantic annotations
datasets_with_annotations <- attributes_only %>% 
  filter(!is.na(sem_annotation))

##############################
# across those annotated packages, how many attributes are annotated vs. not annotated?
##############################

# for RMarkdown
tot_num_attributes <- length(extracted_attributes$attributeName)

# 12312/14718 attributes are annotated
annotated_attributes <- extracted_attributes %>% 
  filter(valueURI != "NA")

# 2406 nonannotated attributes 
test <- extracted_attributes %>% 
  anti_join(annotated_attributes)

# for RMarkdown
tot_num_annotated_attributes <- length(annotated_attributes$attributeName)

# 2 unique propertyURIs: `containsMeasurementsOfType`, `VolumetricRate`
uniquePropURI <- length(unique(annotated_attributes$propertyURI))

# 979 unique valueURIs (i.e. semantic terms)
uniqueValueURI <- length(unique(annotated_attributes$valueURI))

# 2406/14710 are not annotated
nonannotated_attributes <- extracted_attributes %>%
  anti_join(annotated_attributes)

# for RMarkdown
tot_num_nonannotated_attributes <- length(nonannotated_attributes$attributeName)

##############################
# determine which valueURIs come from dataone/ECSO and which don't -- this matters for web scraping (below) since the ECSO_webscraping_prefNames() won't locate prefLable and ontoLabel in other ontologies!
##############################

# valueURIs from ECSO 
ECSO_unique_valueURIs <- annotated_attributes %>% 
  distinct(valueURI) %>% 
  filter(str_detect(valueURI,"^http://purl.dataone.org/odo/ECSO_"))

# valueURIs from other ontologies 
others_unique_valueURIs <- annotated_attributes %>% 
  distinct(valueURI) %>% 
  anti_join(ECSO_unique_valueURIs)

##########################################################################################
# 2) for RMarkdown report
##########################################################################################

# ----------- annotations by group -----------

# For RMarkdown - get all ECSO annotations (12155)
all_ECSO_annotations <- annotated_attributes %>% 
  filter(str_detect(valueURI,"^http://purl.dataone.org/odo/ECSO_"))

# for RMarkdown -- get all nonECSO annotations (total 156)
nonECSO_annotations <- annotated_attributes %>% 
  anti_join(all_ECSO_annotations) %>% 
  select(identifier, valueURI, attributeName, attributeDefinition)

tot_ECSO_annotations <- length(all_ECSO_annotations$attributeName)
perc_ECSO <- round(((tot_ECSO_annotations/tot_num_annotated_attributes) * 100), 1)

# for RMarkdown -- get all CHEBI annotations (24)
CHEBI_annotations <- nonECSO_annotations %>% 
  filter(str_detect(valueURI,"^http://purl.obolibrary.org/obo/CHEBI_"))

tot_CHEBI <- length(CHEBI_annotations$valueURI)

# for RMarkdown - get all ENVO annotations (7)
ENVO_annotations <- nonECSO_annotations %>% 
  filter(str_detect(valueURI,"^http://purl.obolibrary.org/obo/ENVO_"))

tot_ENVO <- length(ENVO_annotations$valueURI)

# for RMarkdown - get all WIKI annotations (16)
WIKI_annotations <- nonECSO_annotations %>% 
  filter(str_detect(valueURI,"^http://en.wikipedia.org/wiki/"))

tot_WIKI <- length(WIKI_annotations$valueURI)

# suspected non-resolving annotations (110)
nonResolve_annotations <- nonECSO_annotations %>% 
  filter(str_detect(valueURI,"^http://www.purl.dataone.org/odo/ECSO_"))
# write.csv(nonResolve_annotations, here::here("data", "outputs", "nonResolvable_annotations.csv"))

tot_nonResolve <- length(nonResolve_annotations$valueURI)

# ----------- unique valueURIs -----------

# for RMarkdown - actual unique ECSO
total_ECSO_unique_valueURIs <- length(ECSO_unique_valueURIs$valueURI)

# for RMarkdown - actual unique nonResolvers
unique_CHEBI_annotations <- CHEBI_annotations %>% 
  distinct(valueURI)

length_CHEBI <- length(unique_CHEBI_annotations$valueURI)

# for RMarkdown - actual unique nonResolvers
unique_ENVO_annotations <- ENVO_annotations %>% 
  distinct(valueURI)

length_ENVO <- length(unique_ENVO_annotations$valueURI)

# for RMarkdown - actual unique nonResolvers
unique_WIKI_annotations <- WIKI_annotations %>% 
  distinct(valueURI)

length_WIKI <- length(unique_WIKI_annotations$valueURI)

# for RMarkdown - actual unique nonResolvers
unique_nonResolve_annotations <- nonResolve_annotations %>% 
  distinct(valueURI)

length_nonResolve <- length(unique_nonResolve_annotations$valueURI)

tot_unique_annotations <- sum(length_ENVO, length_CHEBI, length_WIKI, length_nonResolve, total_ECSO_unique_valueURIs)


# ----------- make table for RMarkdown -----------

Table1_annotations_counts <- data.frame("ontology/origin" = c("ECSO", "CHEBI", "ENVO", "WIKI", "non-resolvable", "TOTAL"), 
                   "total_num_annotations" = c(tot_ECSO_annotations, tot_CHEBI, tot_ENVO, tot_WIKI, tot_nonResolve, tot_num_annotated_attributes),
                   "num_unique_valueURIs" = c(total_ECSO_unique_valueURIs, length_CHEBI, length_ENVO, length_WIKI, length_nonResolve, tot_unique_annotations))

