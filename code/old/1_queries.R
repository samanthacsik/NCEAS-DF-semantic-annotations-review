# title: Solr query for annotated datasets
# author: "Sam Csik"
# date created: "2020-09-21"
# date edited: "2020-09-21"
# packages updated: __
# R version: __
# input: "NA"
# output: "data/queries/*"

##########################################################################################
# Summary
##########################################################################################

##########################################################################################
# General Setup
##########################################################################################

##############################
# Load packages
##############################

source(here::here("code", "0_libraries.R"))

##############################
# set nodes & get token
##############################

# token reminder
options(dataone_test_token = "...")

# nodes
cn <- CNode("PROD")
adc_mn <- getMNode(cn, 'urn:node:ARCTIC')

##########################################################################################
# query all ADC holdings (only the most recent published version) for identifiers, titles, keywords, abstracts, and attribute info
##########################################################################################

# 1) title, keywords, abstracts
semAnnotations_query <- query(adc_mn, 
                              list(q = "documents:* AND obsolete:(*:* NOT obsoletedBy:*)",
                                   fl = "identifier, title, keywords, abstract, attribute, sem_annotates, sem_annotation, sem_annotated_by, sem_comment",
                                   rows = "7000"),
                                   as = "data.frame")

# write.csv(semAnnotations_query, file = here::here("data", "queries", paste("fullQuery_semAnnotations", Sys.Date(),".csv", sep = "")), row.names = FALSE) 

##########################################################################################
# filter out any data packages that do not have semantic annotations 
##########################################################################################

clean_query <- semAnnotations_query %>% 
  filter(sem_annotation != "NA")

