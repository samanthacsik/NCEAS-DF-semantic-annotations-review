# title: Custom Functions for Data Wrangling & Plotting
# author: "Sam Csik"
# date created: "2020-10-05"
# date edited: "2020-10-05"
# R version: 3.6.3
# input: NA
# output: NA

source(here::here("code", "00_libraries.R"))

#-----------------------------
# used in script "02_webscraping.R"
# function to scrape the "preferred name" and "ontology name" for a given valueURI
  # takes arguments:
    # df: dataframe consisting of 3 columns: valueURI (valueURIs as character strings), prefName (containing "NA"s as character strings), ontoName (containing "NA"s as character strings)
    # valueURI: valueURIs as character strings; extracted using eatocsv::extract_ea() (currently from forked version at samanthacsik:eatocsv)
    # row: row specified in for loop
#-----------------------------

ECSO_webscraping_prefNames <- function(df, valueURI, row){

  # read html, extract prefName and ontoName
  webpage <- read_html(valueURI)
  prefName <- html_text(html_nodes(html_nodes(webpage, '.cls-info-container'), '.prefLabel'))
  ontoName <- html_text(html_nodes(html_nodes(webpage, '.ont-info-bar'), 'a')[1])

  # add those to the df containing valueURIs
  df[row, 2] = prefName
  df[row, 3] = ontoName
  return(df)
}

#-----------------------------
# used in script "-"
# function to unnest individual tokens and separates ngrams into multiple columns
  # takes arguments:
    # my_data: a df of solr query results
    # my_input: input column to get split (e.g. title), as string or symbol
    # split: number of words to split each input into (e.g. for trigrams, split = 3)
#-----------------------------

tidyTerms_unnest <- function(my_data, my_input, split) {
  my_data %>%
    select(identifier, author, my_input) %>% # author
    unnest_tokens(output = ngram, input = !!my_input, token = "ngrams", n = split) %>% 
    separate(ngram, into = c("word1", "word2", "word3"), sep = " ")
}

#-----------------------------
# used in script "04_unnest_nonannotated_terms.R"
# function that applies the tidyTokens_unnest() to all specified items within a df, and saves as data objects
# takes arguments:
  # df: a df of solr query results
  # item: which column(s) (i.e. metadata fields) you'd like to process (e.g. title, keywords, abstract)
#-----------------------------

process_df <- function(df, item) {

  print(item)

  # unnest tokens
  word_table <- tidyTerms_unnest(df, item, 1)
  bigram_table <- tidyTerms_unnest(df, item, 2)
  trigram_table <- tidyTerms_unnest(df, item, 3)

  # create object names
  word_table_name <- paste("unnested_", item, "IndivTokens", Sys.Date(), sep = "")
  bigram_table_name <- paste("unnested_", item, "BigramTokens", Sys.Date(), sep = "")
  trigram_table_name <- paste("unnested_", item, "TrigramTokens", Sys.Date(), sep = "")

  # print as dfs
  assign(word_table_name, word_table, envir = .GlobalEnv)
  assign(bigram_table_name, bigram_table, envir = .GlobalEnv)
  assign(trigram_table_name, trigram_table, envir = .GlobalEnv)
}

#-----------------------------
# used in script: "05_filterStopWords_count_nonannotated_terms.R"
# functions filter out tidytext::data(stop_words), count unnested tokens, and count number of unique identifiers and unique authors for each unique token (separate functions for individual tokens, bigrams, trigrams)
  # takes arguments:
    # file_name: name of .csv file saved to "data/text_mining/unnested_tokens/*"
#-----------------------------

###### individual terms ###### 
filterCount_indivTerms <- function(file_path, file_name) {
  
  # create object name
  object_name <- basename(file_name)
  object_name <- gsub(".csv", "", object_name)
  object_name <- gsub("unnested_", "filteredCounts_", object_name)
  print(object_name)
  
  # total token counts
  token_counts <- read_csv(here::here(file_path, file_name)) %>% 
    rename(token = word1) %>% 
    select(identifier, token) %>% 
    filter(!token %in% stop_words$word, token != "NA") %>% 
    count(token, sort = TRUE)
  
  # unique ID counts for each token
  uniqueID_counts <- read_csv(here::here(file_path, file_name)) %>% 
    rename(token = word1) %>% 
    select(identifier, token) %>% 
    filter(!token %in% stop_words$word, token != "NA") %>% 
    group_by(token) %>% 
    summarise(unique_ids = n_distinct(identifier)) %>% 
    arrange(-unique_ids)
  
  # unique ID counts for each token
  uniqueAuthor_counts <- read_csv(here::here(file_path, file_name)) %>%
    rename(token = word1) %>%
    select(author, token) %>%
    filter(!token %in% stop_words$word, token != "NA") %>%
    group_by(token) %>%
    summarise(unique_authors = n_distinct(author)) %>%
    arrange(-unique_authors)
  
  # full_join dfs by token -- first token_counts and uniqueID_counts
  my_file <- full_join(token_counts, uniqueID_counts)
  # then uniqueAuthor_counts
  my_file <- full_join(my_file, uniqueAuthor_counts)
  
  # save as object_name
  assign(object_name, my_file, envir = .GlobalEnv)
}

###### bigrams ###### 
filterCount_bigramTerms <- function(file_path, file_name) {
  
  # create object name
  object_name <- basename(file_name)
  object_name <- gsub(".csv", "", object_name)
  object_name <- gsub("unnested_", "filteredCounts_", object_name)
  print(object_name)
  
  # wrangle data
  token_counts <- read_csv(here::here(file_path, file_name)) %>% 
    select(identifier, word1, word2) %>% 
    filter(!word1 %in% stop_words$word, !word2 %in% stop_words$word) %>% 
    filter(word1 != "NA", word2 != "NA") %>% 
    count(word1, word2, sort = TRUE) %>% 
    unite(col = "token", word1, word2, sep = " ")
  
  # unique ID counts for each token
  uniqueID_counts <- read_csv(here::here(file_path, file_name)) %>% 
    select(identifier, word1, word2) %>% 
    filter(!word1 %in% stop_words$word, !word2 %in% stop_words$word) %>% 
    filter(word1 != "NA", word2 != "NA") %>% 
    unite(col = "token", word1, word2, sep = " ") %>% 
    group_by(token) %>% 
    summarise(unique_ids = n_distinct(identifier)) %>% 
    arrange(-unique_ids)
  
  # unique ID counts for each token
  uniqueAuthor_counts <- read_csv(here::here(file_path, file_name)) %>%
    select(author, word1, word2) %>%
    filter(!word1 %in% stop_words$word, !word2 %in% stop_words$word) %>%
    filter(word1 != "NA", word2 != "NA") %>%
    unite(col = "token", word1, word2, sep = " ") %>%
    group_by(token) %>%
    summarise(unique_authors = n_distinct(author)) %>%
    arrange(-unique_authors)
  
  # full_join dfs by token -- first token_counts and uniqueID_counts
  my_file <- full_join(token_counts, uniqueID_counts) 
  # then uniqueAuthor_counts
  my_file <- full_join(my_file, uniqueAuthor_counts) %>%
    separate(token, into = c("word1", "word2"), sep = " ")

  # save as object_name
  assign(object_name, my_file, envir = .GlobalEnv)
}

###### trigrams ###### 
filterCount_trigramTerms <- function(file_path, file_name) {
  
  # create object name
  object_name <- basename(file_name)
  object_name <- gsub(".csv", "", object_name)
  object_name <- gsub("unnested_", "filteredCounts_", object_name)
  print(object_name)
  
  # wrangle data
  token_counts <- read_csv(here::here(file_path, file_name)) %>% 
    select(identifier, word1, word2, word3) %>% 
    filter(!word1 %in% stop_words$word, !word2 %in% stop_words$word, !word3 %in% stop_words$word) %>% 
    filter(word1 != "NA", word2 != "NA", word3 != "NA") %>% 
    count(word1, word2, word3, sort = TRUE) %>% 
    unite(col = "token", word1, word2, word3, sep = " ")
 
  # unique ID counts for each token
  uniqueID_counts <- read_csv(here::here(file_path, file_name)) %>% 
    select(identifier, word1, word2, word3) %>% 
    filter(!word1 %in% stop_words$word, !word2 %in% stop_words$word, !word3 %in% stop_words$word) %>% 
    filter(word1 != "NA", word2 != "NA", word3 != "NA") %>% 
    unite(col = "token", word1, word2, word3, sep = " ") %>% 
    group_by(token) %>% 
    summarise(unique_ids = n_distinct(identifier)) %>% 
    arrange(-unique_ids)

  # unique ID counts for each token
  uniqueAuthor_counts <- read_csv(here::here(file_path, file_name)) %>%
    select(author, word1, word2, word3) %>%
    filter(!word1 %in% stop_words$word, !word2 %in% stop_words$word, !word3 %in% stop_words$word) %>%
    filter(word1 != "NA", word2 != "NA", word3 != "NA") %>%
    unite(col = "token", word1, word2, word3, sep = " ") %>%
    group_by(token) %>%
    summarise(unique_authors = n_distinct(author)) %>%
    arrange(-unique_authors)

  # full_join dfs by token -- first token_counts and uniqueID_counts
  my_file <- full_join(token_counts, uniqueID_counts)
  # then uniqueAuthor_counts
  my_file <- full_join(my_file, uniqueAuthor_counts) %>%
    separate(token, into = c("word1", "word2", "word3"), sep = " ")

  # save as object_name
  assign(object_name, my_file, envir = .GlobalEnv)
}

#-----------------------------
# used in script: "04_unnest_nonannotated_terms.R", "05_filterStopWords_count_nonannotated_terms.R"
# function to save a df from the global environment whose name matches your specified pattern as a .csv to your specified directory
  # takes arguments:
    # data: data object
    # name: name of object, as character string
    # file path: where you'd like to save the .csv file(s)
#-----------------------------

# function to write as .csv files to appropriate subdirectory
output_csv <- function(data, names, file_path){
  write_csv(data, here::here(file_path, paste0(names, ".csv")))
}

#-----------------------------
# used in script: "07_nonAnnotated_attribute_assessment.R"
# function to import filtered token count dfs generated in script 3 
  # takes arguments:
    # file_name: name of .csv file located at "data/text_mining/filtered_token_counts/*"
#-----------------------------

import_filteredTermCounts <- function(file_name) {

  # create object name
  object_name <- tools::file_path_sans_ext(all_files[i])
  object_name <- gsub(".csv", "", object_name)
  object_name <- gsub("filteredCounts_", "", object_name)
  object_name <- gsub("2020.*", "", object_name)
  print(object_name)

  # read in data
  my_file <- read_csv(here::here("data", "filtered_term_counts", "nonannotated_attributes2020-10-12", file_name))

  # save as object_name
  assign(object_name, my_file, envir = .GlobalEnv)
}

#-----------------------------
# used in script: "07_nonAnnotated_attribute_assessment.R"
# function to combine separate term columns for bigram or trigram dfs into single "token" column
  # takes arguments:
    # object: *BigramTokens or *TrigramTokens object in global environment, as class `data.frame`
    # object_name: *BigramTokens or *TrigramTokens object name from global environment, as class `character`
#-----------------------------

######  bigrams ###### 
combine_bigrams <- function(object, object_name){

  # unite separate token cols
  new_table <- object %>%
    unite(col = token, word1, word2, sep = " ")

  # updated existing objects
  assign(object_name, new_table, envir = .GlobalEnv)
}

###### trigrams ###### 
combine_trigrams <- function(object, object_name){

  # unite separate token cols
  new_table <- object %>%
    unite(col = token, word1, word2, word3, sep = " ")

  # updated existing objects
  assign(object_name, new_table, envir = .GlobalEnv)
}

#-----------------------------
# used in script: "07_nonAnnotated_attribute_assessment.R"
# function to create frequency plots, where terms are arranged by Counts
  # takes arguments:
    # tokens_df: *Tokens object in global environment which has had ngrams combined into a single column, as class `data.frame`
    # df_name: *Tokens object name in global environment which has had ngrams combined into a single column, as class `character`
#-----------------------------

create_frequencyByCount_plot <- function(tokens_df, df_name) {

  # generate plot object name
  plotObjectName <- gsub("Tokens", "_plot", df_name)
  print(plotObjectName)

  # create plot that displays 50 most frequent terms
  freq_plot <- tokens_df %>%
    #head(50) %>%
    filter(n > 15) %>% 
    mutate(token = reorder(token, n)) %>%
    rename(Counts = n) %>%
    ggplot(aes(token, Counts)) +
    geom_col() +
    # ggtitle(df_name) +
    xlab(NULL) +
    scale_y_continuous(expand = c(0,0)) +
    coord_flip() +
    theme_linedraw()

  #plot(freq_plot)

  # assign to object name in global environment
  assign(plotObjectName, freq_plot, envir = .GlobalEnv)
}
