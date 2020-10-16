# title: Unnest NONANNOTATED attributes into individual words, bigrams, trigrams
# author: "Sam Csik"
# date created: "2020-10-02"
# date edited: "2020-10-12"
# R version: 3.6.3
# input:  "data/queries/query2020-10-12/*"
# output: "data/text_mining/unnested_tokens/*"

##########################################################################################
# Summary
##########################################################################################

# This script uses the tidytext package to unnest (i.e. separate into individual columns) tokens (i.e. words) into various ngrams (where n = 1, 2, or 3)
# Specifically, we unnest titles, keywords, abstracts, attributeNames, attributeLabels, attributeDescriptions
# These unnested tokens are saved as .csv files for use in later scripts

##############################
# Load packages & custom functions
##############################

source(here::here("code", "00_libraries.R"))
source(here::here("code", "00_functions.R"))

##############################
# Import data
##############################

solr_query <- read_csv(here::here("data", "queries", "query2020-10-12", "fullQuery_semAnnotations2020-10-12_solr.csv"))
extracted_attributes <- read_csv(here::here("data", "queries", "query2020-10-12", "fullQuery_semAnnotations2020-10-12_attributes.csv"))

##############################
# Add `author` field from `solr_query` to `attributes` df
##############################

authors_ids <- solr_query %>% select(identifier, author)
extracted_attributes <- inner_join(extracted_attributes, authors_ids)

##########################################################################################
# Unnest tokens
##########################################################################################

##############################
# isolate nonannotated attributes
##############################

# annotated
annotated_attributes <- extracted_attributes %>% 
  filter(valueURI != "NA")

# nonannotated
nonannotated_attributes <- extracted_attributes %>%
  anti_join(annotated_attributes)

##############################
# df of items to unnest (used in for loop)
##############################

unnest_these <- tribble(
  ~my_input,  
  "attributeName",    
  "attributeLabel",     
  "attributeDefinition", 
)

##############################
# unnest into individual words, bigrams, and trigrams
##############################

# nonannotated tokens
for (row in 1:nrow(unnest_these)) {
  item <- as.character(unnest_these[row,][,1][,1])
  print(item)
  process_df(nonannotated_attributes, item)
}

##############################
# save as .csv files
##############################

# get list of new dfs
df_list <- mget(ls(pattern = "unnested_"))

# save .csv files
for (i in 1:length(df_list)){
  data <- df_list[[i]]
  names <- names(df_list)[i]
  file_path <- "data/unnested_terms/nonannotated_attributes2020-10-12"
  output_csv(data, names, file_path)
}
