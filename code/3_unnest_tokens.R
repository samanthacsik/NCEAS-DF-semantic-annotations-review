# title: Unnest NONANNOTATED attributes into individual words, bigrams, trigrams
# author: "Sam Csik"
# date created: "2020-10-02"
# date edited: "2020-10-02"
# R version: 3.6.3
# input: 
# output: 

##########################################################################################
# Summary
##########################################################################################

# unnest tokens

##############################
# Load packages
##############################

source(here::here("code", "0_libraries.R"))

##############################
# Load custom functions
##############################

source(here::here("code", "0_functions.R"))

##########################################################################################
# Unnest tokens
##########################################################################################

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

# function to write as .csv files
output_csv <- function(data, names){
  write_csv(data, here::here("data", "unnested_tokens", "nonannotated_attributes", paste0(names, ".csv")))
}

# write each df as .csv file
list(data = df_list, names = names(df_list)) %>%
  purrr::pmap(output_csv)
