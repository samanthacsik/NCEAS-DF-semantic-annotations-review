# title: 
# author: "Sam Csik"
# date created: "2020-10-02"
# date edited: "2020-10-02"
# R version: 3.6.3
# input: 
# output: 

##########################################################################################
# Summary
##########################################################################################



##############################
# Load packages
##############################

source(here::here("code", "0_libraries.R"))

##############################
# Load packages
##############################

source(here::here("code", "0_functions.R"))

##############################
# Import data
##############################

extracted_attributes <- read_csv(here::here("data", "queries", "query2020-10-01", "fullQuery_semAnnotations2020-10-01_attributes.csv"))

##########################################################################################
# General exploration
##########################################################################################

##############################
# how many data packages have annotations?
##############################

# 184 data packages with annotations
length(unique(extracted_attributes$identifier))

##############################
# across those annotated packages, how many attributes are annotated vs. not annotated?
##############################

# 12307/14710 attributes are annotated
annotated_attributes <- extracted_attributes %>% 
  filter(valueURI != "NA")

# 2 unique propertyURIs: `containsMeasurementsOfType`, `VolumetricRate`
length(unique(annotated_attributes$propertyURI))

# 978 unique valueURIs (i.e. semantic terms)
length(unique(annotated_attributes$valueURI))

# 2403/14710 are not annotated
nonannotated_attributes <- extracted_attributes %>%
  anti_join(annotated_attributes)

##########################################################################################
# determine which valueURIs come from dataone/ECSO and which don't -- this matters for web scraping (below) since the ECSO_webscraping_prefNames() won't locate prefLable and ontoLabel in other ontologies!
##########################################################################################

# valueURIs from ECSO 
ECSO_unique_valueURIs <- annotated_attributes %>% 
  distinct(valueURI) %>% 
  filter(str_detect(valueURI,"^http://purl.dataone.org/odo/ECSO_"))

# valueURIs from other ontologies 
others_unique_valueURIs <- annotated_attributes %>% 
  distinct(valueURI) %>% 
  anti_join(ECSO_unique_valueURIs)

##########################################################################################
# Web scraping for Preferred Names and Ontology Names
##########################################################################################

##############################
# add columns for prefName & ontoName
##############################

ECSO_unique_valueURIs$prefName <- "NA" 
ECSO_unique_valueURIs$ontoName <- "NA" 

##############################
# tryCatch to webscrape for prefNames and ontoNames; will return NA if a warning or error is thrown (most common error: HTTP 404)
##############################

for(row in 1:nrow(ECSO_unique_valueURIs)){
  
  # define valueURI
  valueURI <- ECSO_unique_valueURIs[[row,1]]
  
  tryCatch({
    
    # first try
    message(paste("Trying valueURI:", valueURI))
    ECSO_unique_valueURIs <- ECSO_webscraping_prefNames(df = ECSO_unique_valueURIs, valueURI = valueURI, row = row)
  },
  
  # if warning, print NA
  warning = function(w){
    
    message(paste("valueURI caused a warning:", valueURI))
    ECSO_webscraping_prefNames(df = ECSO_unique_valueURIs, valueURI = valueURI, row = row)
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
  progress(row, max.value = length(ECSO_unique_valueURIs$valueURI))
}

##############################
# join prefNames and ontoNames with original `annotated_attributes` df; save as .csv
##############################

annotated_attributes <- full_join(annotated_attributes, ECSO_unique_valueURIs)

# write_csv(annotated_attributes, here::here("data", "queries", "query2020-10-01", "fullQuery_semAnnotations2020-10-01_webscraping.csv"))