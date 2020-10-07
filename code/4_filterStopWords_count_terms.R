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

# nonannotated attributes

##############################
# Load packages
##############################

source(here::here("code", "0_libraries.R"))

##############################
# Load custom functions
##############################

source(here::here("code", "0_functions.R"))

##########################################################################################
# Filter/count INDIVIDUAL TERMS
##########################################################################################

# isolate individual token files #####(do not include attributes -- they are in a different format)
nonannotated_unnested_indiv_files <- list.files(path = here::here("data", "unnested_tokens", "nonannotated_attributes"), pattern = glob2rx("unnested_*Indiv*"))

# remove excess columns, filter out stop_words, remove NAs, calculate counts
for(i in 1:length(nonannotated_unnested_indiv_files)){
  file_name <- nonannotated_unnested_indiv_files[i]
  file_path <- "data/unnested_tokens/nonannotated_attributes"
  print(file_name)
  filterCount_indivTerms(file_path, file_name)
}

##########################################################################################
# Filter/count BIGRAMS
##########################################################################################

# isolate individual token files #####(do not include attributes -- they are in a different format)
nonannotated_unnested_bigram_files <- list.files(path = here::here("data", "unnested_tokens", "nonannotated_attributes"), pattern = glob2rx("unnested_*Bigram*"))

# remove excess columns, filter out stop_words, remove NAs, calculate counts
for(i in 1:length(nonannotated_unnested_bigram_files)){
  file_name <- nonannotated_unnested_bigram_files[i]
  file_path <- "data/unnested_tokens/nonannotated_attributes"
  print(file_name)
  filterCount_bigramTerms(file_path, file_name)
}

##########################################################################################
# Filter/count TRIGRAMS
##########################################################################################

# isolate individual token files #####(do not include attributes -- they are in a different format)
nonannotated_unnested_trigram_files <- list.files(path = here::here("data", "unnested_tokens", "nonannotated_attributes"), pattern = glob2rx("unnested_*Trigram*"))

# remove excess columns, filter out stop_words, remove NAs, calculate counts
for(i in 1:length(nonannotated_unnested_trigram_files)){
  file_name <- nonannotated_unnested_trigram_files[i]
  file_path <- "data/unnested_tokens/nonannotated_attributes"
  print(file_name)
  filterCount_trigramTerms(file_path, file_name)
}

##########################################################################################
# save as .csv files
##########################################################################################

# get list of new dfs
df_list <- mget(ls(pattern = "filteredCounts_"))

# function to write as .csv files to appropriate subdirectory
output_csv <- function(data, names){
  write_csv(data, here::here("data", "filtered_term_counts", "nonannotated_attributes", paste0(names, ".csv")))
}

# write each df as .csv file
list(data = df_list, names = names(df_list)) %>%
  purrr::pmap(output_csv) 
