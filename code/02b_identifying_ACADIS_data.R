# title: Identifying ACADIS datasets
# author: "Sam Csik, adapted from Chris Beltz"
# date created: "2020-11-09"
# date edited: "2020-11-10"
# R version: 3.6.3
# input: "data/queries/query2020-10-12/fullQuery_semAnnotations2020-10-12_solr.csv" , agg_check_scores (see Import data)
# output: "data/queries/query2020-10-12/fullQuery_semAnnotations2020-10-12_labeledACADIS.csv"

##########################################################################################
# Summary
##########################################################################################

# After initial analyses, we found that out of ~6100 datapackages in the ADC, only ~1400 of them have attribute information; MJones and MSchildhauer suggested doing a deeper dive into the remaining ~4700 datasets that have no attribute information. The first step is to identify and remove any ACADIS data, which was ingested upon the inception of the ADC. They said there should be ~3500 ACADIS datasets, leaving ~1000ish remaining to be explored in greater depth. Here, I identify those ACADIS datasets using code adapted from Chris Beltz so that they can be filtered out.

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

# solr query from 2020-10-12
solr_query <- read_csv(here::here("data",  "queries", "query2020-10-12", "fullQuery_semAnnotations2020-10-12_solr.csv"))

# Get updated aggregate check scores via terminal (last downloaded on 2020-11-10)
# curl -v --GET -H "Accept: text/csv" "https://docker-ucsb-4.dataone.org:30443/quality/scores/?id=urn:node:ARCTIC&suite=FAIR-suite-0.3.1" -o "agg_check_scores2020-11-10.csv"

# read back in data (I moved this to a subdirectory after saving using the above commands)
agg_check_scores <- read_csv(here::here("data", "aggregate_scores", "agg_check_scores2020-11-10.csv"))

##########################################################################################
# 1) clean data -- get PIDs with at least 2 sequenceIds (i.e. those that have at leat an initial submission and second/final updated submission)
  # need initial submission to be able to identify those submitted prior to 2016-03-21 (ACADIS datasets) and thier corresponding final PIDs
  # NOTE: a sequenceId is the equivalent of a reserve engineered series_id and uniquely identifies an individual entity across multiple versions/PIDs
##########################################################################################

# count datasets in ADC data using sequenceIds
length(unique(agg_check_scores$sequenceId)) # total = 6141

# check for NA in sequenceId
sum(is.na(agg_check_scores$sequenceId)) # 246

# remove checks and docs that are missing a 'sequenceId'
agg_check_scores_new <- agg_check_scores %>% 
  filter(!is.na(sequenceId))

# CHECKPOINT: datasets remaining using sequenceIds
length(unique(agg_check_scores_new$sequenceId)) #TOTAL = 6140 

# examine sequenceIds that do not have 2 unique PIDs (which means that there are at least 2 verisons of that datapackage i.e. at least an INITIAL and FINAL)
examine_unique_pids <- agg_check_scores_new %>%
  arrange(sequenceId, dateUploaded) %>%
  group_by(sequenceId) %>%
  summarise(unique_pids = length(unique(pid)))

# number of datasets removed for having only 1 unique pid within the sequenceId (which means there aren't multiple versions of that datapackage)
sum(examine_unique_pids$unique_pids[examine_unique_pids$unique_pids==1]) # 221 removed

# create vector for sequenceIds with only 1 unique pid (to be removed)
remove_sequenceId <- examine_unique_pids$sequenceId[examine_unique_pids$unique_pids == 1]

# remove series_id with only 1 unique pid
agg_check_scores_remove1pid <- agg_check_scores_new %>% 
  filter(!sequenceId %in% remove_sequenceId)

# CHECKPOINT: datasets remaining using series_ids
length(unique(agg_check_scores_remove1pid $sequenceId)) # TOTAL = 5919 

# create cleaned dataset
sequenceIDs_cleaned <- agg_check_scores_remove1pid %>% 
  select(pid, formatId, dateUploaded, datasource, obsoletes, obsoletedBy, sequenceId)

# remove unnecessary dfs from global enivronment
rm(agg_check_scores, agg_check_scores_new, agg_check_scores_remove1pid, examine_unique_pids)

##########################################################################################
# 2) identify ACADIS data 
##########################################################################################

# get first and last sequenceIDs
sequenceIDs_firstLast <- sequenceIDs_cleaned %>%
  arrange(sequenceId, dateUploaded) %>%
  group_by(sequenceId) %>%
  slice(c(1, tail(row_number(), 1)))

# identify initial/final update
sequenceID_firstLast_dateSplit <- sequenceIDs_firstLast %>%
  arrange(sequenceId, dateUploaded, pid) %>%
  group_by(sequenceId) %>%
  mutate(dateSplit = case_when(
    dateUploaded < lead(dateUploaded, n = 1) ~ "INITIAL",
    dateUploaded > lag(dateUploaded, n = 1) ~ "FINAL",
    TRUE ~ "TBD")) %>% 
  separate(dateUploaded, into = c('date', 'time'), sep = ' ', remove = FALSE)
  
# filter for sequence IDs that are 'initial' and uploaded prior to 2016-03-21 (the date ACADIS data was ingestd)
ACADIS_data_initial_sequenceIDs <- sequenceID_firstLast_dateSplit %>% 
  filter(dateSplit == "INITIAL",
         date < "2016-03-21") %>% 
  mutate(dataSubset = rep("ACADIS")) %>% 
  select(sequenceId, dataSubset) 

# for RMarkdown 
total_num_ACADIS_datapackages <- length(ACADIS_data_initial_sequenceIDs$sequenceId)

# join dfs to label ACADIS data (for both INITIAL and FINAL sequenceIDs)
ACADIS_data_labeled <- full_join(sequenceID_firstLast_dateSplit, ACADIS_data_initial_sequenceIDs)

##########################################################################################
# 2) select FINAL ACADIS sequenceIds and associated PIDs
##########################################################################################

ACADIS_data_finalPIDs <- ACADIS_data_labeled %>% 
  filter(dateSplit == "FINAL",
         dataSubset == "ACADIS") %>% 
  select(sequenceId, pid, dateSplit, dataSubset) %>% 
  rename(identifier = pid)

##########################################################################################
# 3) label ACADIS data in solr query 
##########################################################################################

solr_query_ACADIS_labeled <- full_join(ACADIS_data_finalPIDs, solr_query) 
# write_csv(solr_query_ACADIS_labeled, here::here("data", "queries", "query2020-10-12", "fullQuery_semAnnotations2020-10-12_labeledACADIS.csv"))

# NOTE: there are 51 extra identifiers that don't appear in the orinal solr_query after full_joining; these all appear to be ACADIS data and will be filtered out anyway
test <- solr_query_ACADIS_labeled %>% 
  anti_join(solr_query)
