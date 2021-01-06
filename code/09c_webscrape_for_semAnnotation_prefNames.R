# title: Webscraping for semantic annotation prefNames
# author: "Sam Csik"
# date created: "2021-01-05"
# date edited: "2021-01-05"
# R version: 3.6.3
# input: "data/output/annotate_these_attributes_2020-12-17.csv"
# output: "data/output/annotate_these_attributes_2020-12-17_webscraped.csv"

##########################################################################################
# Summary
##########################################################################################

# I realized when writing script to automate annotations that adding a valueURI to the metadata also requires the semantic annotation LABEL. Here, I take my df of all 27,777 attributes that I've manually assigned semantic annotations to, and webscrape for their corresponding labels

##########################################################################################
# General setup
##########################################################################################

# Load packages & custom functions
source(here::here("code", "00_libraries.R"))
source(here::here("code", "00_functions.R"))

# Load data
attributes_to_annotate <- read_csv(here::here("data", "outputs", "annotate_these_attributes_2020-12-17.csv"))

##########################################################################################
# Do it
##########################################################################################

# get only unique 'assigned_valueURIs' to expedite the process
unique_valueURIs <- attributes_to_annotate %>% 
  distinct(assigned_valueURI)

# add cols for prefLabel and ontoName
unique_valueURIs$prefName <- "NA" 
unique_valueURIs$ontoName <- "NA" 

# webscrape
for(row in 1:nrow(unique_valueURIs)){
  
  # define valueURI
  valueURI <- unique_valueURIs[[row,1]]
  
  tryCatch({
    
    # first try
    message(paste("Trying valueURI:", valueURI))
    unique_valueURIs <- ECSO_webscraping_prefNames(df = unique_valueURIs, valueURI = valueURI, row = row)
  },
  
  # if warning, print NA
  warning = function(w){
    message(paste("valueURI caused a warning:", valueURI))
    ECSO_webscraping_prefNames(df = unique_valueURIs, valueURI = valueURI, row = row)
    return(NA)
  },
  
  # if error, print NA
  error = function(e){
    message(paste("There was an error for valueURI:", valueURI))
    message(paste("The error was:", e))
    return(NA)
  }
  
  )
  
  # progress meter
  progress(row, max.value = length(unique_valueURIs$valueURI))
}

# combine prefLabels with original dataframe
attributes_to_annotate_webscraped <- full_join(attributes_to_annotate, unique_valueURIs)

# save df
write_csv(attributes_to_annotate_webscraped, here::here("data", "outputs", "annotate_these_attributes_2020-12-17_webscraped.csv"))
