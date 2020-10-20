# title: Remove stop words and calculate term frequncies for NONANNOTATED attributes
# author: "Sam Csik"
# date created: "2020-10-02"
# date edited: "2020-10-15"
# R version: 3.6.3
# input: "data/unnested_terms/nonannotated_attributes2020-10-12/*"
# output: "data/filtered_term_counts/nonannotated_attributes2020-10-12/*"

##########################################################################################
# Summary
##########################################################################################

# This script uses the tidytext package to filter out "stop_words" from unnested token files, count number of occurrences for each term (token), and count the number of unique identifiers & unique authors associated with each unique term
# These data frames are saved then as .csv files 

##############################
# Load packages & custom functions
##############################

source(here::here("code", "00_libraries.R"))
source(here::here("code", "00_functions.R"))

##########################################################################################
# Filter/count INDIVIDUAL TERMS
##########################################################################################

# isolate individual token files 
nonannotated_unnested_indiv_files <- list.files(path = here::here("data", "unnested_terms", "nonannotated_attributes2020-10-12"), pattern = glob2rx("unnested_*Indiv*"))

# remove excess columns, filter out stop_words, remove NAs, calculate counts
for(i in 1:length(nonannotated_unnested_indiv_files)){
  file_name <- nonannotated_unnested_indiv_files[i]
  file_path <- "data/unnested_terms/nonannotated_attributes2020-10-12"
  print(file_name)
  filterCount_indivTerms(file_path, file_name)
}

##########################################################################################
# Filter/count BIGRAMS
##########################################################################################

# isolate individual token files #####(do not include attributes -- they are in a different format)
nonannotated_unnested_bigram_files <- list.files(path = here::here("data", "unnested_terms", "nonannotated_attributes2020-10-12"), pattern = glob2rx("unnested_*Bigram*"))

# remove excess columns, filter out stop_words, remove NAs, calculate counts
for(i in 1:length(nonannotated_unnested_bigram_files)){
  file_name <- nonannotated_unnested_bigram_files[i]
  file_path <- "data/unnested_terms/nonannotated_attributes2020-10-12"
  print(file_name)
  filterCount_bigramTerms(file_path, file_name)
}

##########################################################################################
# Filter/count TRIGRAMS
##########################################################################################

# isolate individual token files #####(do not include attributes -- they are in a different format)
nonannotated_unnested_trigram_files <- list.files(path = here::here("data", "unnested_terms", "nonannotated_attributes2020-10-12"), pattern = glob2rx("unnested_*Trigram*"))

# remove excess columns, filter out stop_words, remove NAs, calculate counts
for(i in 1:length(nonannotated_unnested_trigram_files)){
  file_name <- nonannotated_unnested_trigram_files[i]
  file_path <- "data/unnested_terms/nonannotated_attributes2020-10-12"
  print(file_name)
  filterCount_trigramTerms(file_path, file_name)
}

##########################################################################################
# save as .csv files
##########################################################################################

# get list of new dfs
df_list <- mget(ls(pattern = "filteredCounts_"))

# save .csv files
for (i in 1:length(df_list)){
  data <- df_list[[i]]
  names <- names(df_list)[i]
  file_path <- "data/filtered_term_counts/nonannotated_attributes2020-10-12"
  output_csv(data, names, file_path)
}
