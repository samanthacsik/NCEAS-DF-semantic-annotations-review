# title: Custom Functions for Data Wrangling & Plotting
# author: "Sam Csik"
# date created: "2020-10-05"
# date edited: "2020-10-05"
# packages updated: __
# R version: __
# input: NA
# output: NA

source(here::here("code", "0_libraries.R"))

#-----------------------------
# used in script "2_initial_exploration.R"
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
# used in script "2_unnest_tokens.R"
# function to unnest individual tokens and separates ngrams into multiple columns
  # takes arguments:
    # my_data: a df of solr query results
    # my_input: input column to get split (e.g. title), as string or symbol
    # split: number of words to split each input into (e.g. for trigrams, split = 3)
#-----------------------------

tidyTerms_unnest <- function(my_data, my_input, split) {
  my_data %>%
    select(identifier, my_input) %>% # author
    unnest_tokens(output = ngram, input = !!my_input, token = "ngrams", n = split) %>% 
    separate(ngram, into = c("word1", "word2", "word3"), sep = " ")
}

#-----------------------------
# used in script "2_unnest_tokens.R"
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
# used in script: "3_filterStopWords_count_terms.R"
# functions filter out tidytext::data(stop_words), count unnested tokens, and count number of unique identifiers and unique authors for each unique token (separate functions for individual tokens, bigrams, trigrams)
  # takes arguments:
    # file_name: name of .csv file saved to "data/text_mining/unnested_tokens/*"
#-----------------------------

###### individual tokens ###### 
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
  
  # # unique ID counts for each token
  # uniqueAuthor_counts <- read_csv(here::here(file_path, file_name)) %>% 
  #   rename(token = word1) %>% 
  #   select(author, token) %>% 
  #   filter(!token %in% stop_words$word, token != "NA") %>% 
  #   group_by(token) %>% 
  #   summarise(unique_authors = n_distinct(author)) %>% 
  #   arrange(-unique_authors)
  
  # full_join dfs by token -- first token_counts and uniqueID_counts
  my_file <- full_join(token_counts, uniqueID_counts)
  # # then uniqueAuthor_counts
  # my_file <- full_join(my_file, uniqueAuthor_counts)
  
  # save as object_name
  assign(object_name, my_file, envir = .GlobalEnv)
}

######  bigrams ###### 
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
  
  # # unique ID counts for each token
  # uniqueAuthor_counts <- read_csv(here::here(file_path, file_name)) %>% 
  #   select(author, word1, word2) %>% 
  #   filter(!word1 %in% stop_words$word, !word2 %in% stop_words$word) %>% 
  #   filter(word1 != "NA", word2 != "NA") %>% 
  #   unite(col = "token", word1, word2, sep = " ") %>% 
  #   group_by(token) %>% 
  #   summarise(unique_authors = n_distinct(author)) %>% 
  #   arrange(-unique_authors)
  
  # full_join dfs by token -- first token_counts and uniqueID_counts
  my_file <- full_join(token_counts, uniqueID_counts) %>% 
    separate(token, into = c("word1", "word2"), sep = " ")
  # # then uniqueAuthor_counts
  # my_file <- full_join(my_file, uniqueAuthor_counts) %>% 
  #   separate(token, into = c("word1", "word2"), sep = " ")

  # save as object_name
  assign(object_name, my_file, envir = .GlobalEnv)
}

######trigrams ###### 
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
  
  # # unique ID counts for each token
  # uniqueAuthor_counts <- read_csv(here::here(file_path, file_name)) %>% 
  #   select(author, word1, word2, word3) %>% 
  #   filter(!word1 %in% stop_words$word, !word2 %in% stop_words$word, !word3 %in% stop_words$word) %>% 
  #   filter(word1 != "NA", word2 != "NA", word3 != "NA") %>% 
  #   unite(col = "token", word1, word2, word3, sep = " ") %>% 
  #   group_by(token) %>% 
  #   summarise(unique_authors = n_distinct(author)) %>% 
  #   arrange(-unique_authors)

  # full_join dfs by token -- first token_counts and uniqueID_counts
  my_file <- full_join(token_counts, uniqueID_counts) %>% 
    separate(token, into = c("word1", "word2", "word3"), sep = " ")
  # # then uniqueAuthor_counts
  # my_file <- full_join(my_file, uniqueAuthor_counts) %>% 
  #   separate(token, into = c("word1", "word2", "word3"), sep = " ")
  
  # save as object_name
  assign(object_name, my_file, envir = .GlobalEnv)
}

#-----------------------------
# used in script: "_____________"
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
# used in script: "_________________________"
# function to import filtered token count dfs generated in script 3 
  # takes arguments:
    # file_name: name of .csv file located at "data/text_mining/filtered_token_counts/*"
#-----------------------------

# import_filteredTermCounts <- function(file_name) {
#   
#   # create object name
#   object_name <- tools::file_path_sans_ext(all_files[i])
#   print(object_name)
#   object_name <- gsub("2020.*", "", object_name) 
#   print(object_name)
#   # object_name <- gsub("2020-09-21.csv", "", object_name)
#   # object_name <- gsub("2020-09-13.csv", "", object_name) # for attributeNames & Definitions (have different date than rest)
#   object_name <- gsub("filteredCounts_", "", object_name)
#   print(object_name)
#   
#   # read in data
#   my_file <- read_csv(here::here("data", "text_mining", "filtered_token_counts", file_name)) 
#   
#   # save as object_name
#   assign(object_name, my_file, envir = .GlobalEnv)
# }

#-----------------------------
# used in script: "___________________________"
# function to combine separate term columns for bigram or trigram dfs into single "token" column
  # takes arguments:
    # object: *BigramTokens or *TrigramTokens object in global environment, as class `data.frame`
    # object_name: *BigramTokens or *TrigramTokens object name from global environment, as class `character`
#-----------------------------

######  bigrams ###### 
# combine_bigrams <- function(object, object_name){
#   
#   # unite separate token cols
#   new_table <- object %>%
#     unite(col = token, word1, word2, sep = " ")
#   
#   # updated existing objects
#   assign(object_name, new_table, envir = .GlobalEnv) 
# }

###### trigrams ###### 
# combine_trigrams <- function(object, object_name){
#   
#   # unite separate token cols
#   new_table <- object %>%
#     unite(col = token, word1, word2, word3, sep = " ")
#   
#   # updated existing objects
#   assign(object_name, new_table, envir = .GlobalEnv) 
# }

#-----------------------------
# used in script: "______________________"
# function to create frequency plots, where terms are arranged by Counts
  # takes arguments:
    # tokens_df: *Tokens object in global environment which has had ngrams combined into a single column, as class `data.frame`
    # df_name: *Tokens object name in global environment which has had ngrams combined into a single column, as class `character`
#-----------------------------

# create_frequencyByCount_plot <- function(tokens_df, df_name) {
# 
#   # generate plot object name
#   plotObjectName <- gsub("Tokens", "_plot", df_name)
#   print(plotObjectName)
# 
#   # create plot that displays 50 most frequent terms
#   freq_plot <- tokens_df %>%
#     head(50) %>%
#     mutate(token = reorder(token, n)) %>%
#     rename(Counts = n) %>%
#     ggplot(aes(token, Counts)) +
#     geom_col() +
#     ggtitle(df_name) +
#     xlab(NULL) +
#     scale_y_continuous(expand = c(0,0)) +
#     coord_flip() +
#     theme_linedraw()
# 
#   plot(freq_plot)
# 
#   # assign to object name in global environment
#   assign(plotObjectName, freq_plot, envir = .GlobalEnv)
# }

#-----------------------------
# used in script: "_____________________"
# function to create frequency plots, where terms are arranged alphabetically
  # takes arguments:
    # tokens_df: *Tokens object in global environment which has had ngrams combined into a single column, as class `data.frame`
    # letter_lowercase: lowercase letter of the alphabet, as class `character`
    # df_name: *Tokens object name in global environment which has had ngrams combined into a single column, as class `character`
#-----------------------------

# create_frequencyByLetter_plot <- function(tokens_df, letter_lowercase, df_name){ 
#   
#   # generate plot title & object name
#   plotObjectName <- gsub("Tokens", "Alphabet_plot", df_name)
#   print(plotObjectName)
#   
#   # create plot that displays 50 most frequent terms
#   freqByLetter_plot <- tokens_df %>% 
#     arrange(token) %>% 
#     rename(Counts = n) %>% 
#     filter(str_detect(token, paste("^", letter_lowercase, sep = ""))) %>% 
#     ggplot(aes(token, Counts)) +
#     geom_col() + 
#     ggtitle(df_name) + 
#     xlab(NULL) +
#     scale_y_continuous(expand = c(0,0)) +
#     coord_flip() +
#     theme_linedraw()
#   
#   plot(freqByLetter_plot)
# }

#-----------------------------
# used in script: "____________________"
# function that applies `create_frequencyByLetter_plot()` to df for all 26 letters of the alphabet
  # takes arguments:  
    # tokens_df: *Tokens object in global environment which has had ngrams combined into a single column, as class `data.frame`
    # df_name: *Tokens object name in global environment which has had ngrams combined into a single column, as class `character`
#-----------------------------

# processAll_frequencyByLetter_plots <- function(tokens_df, df_name){ # `tokens_df` was just `df`
#   
#   print("----------------")
#   print("Starting new PDF")
#   print(df_name)
#   
#   pdf(here::here("figures", "token_frequencies", "alphabetized", paste(df_name, Sys.Date(), "ALPHABETIZED.pdf")), onefile = TRUE, width = 20, height = 35) 
#   for(i in 1:length(letters)){
#     my_letter <- letters[[i]]
#     print(my_letter)
#     create_frequencyByLetter_plot(tokens_df = tokens_df, letter_lowercase = my_letter, df_name = name)
#   }
#   dev.off() 
# }

#-----------------------------
# STILL A WORK IN PROGRESS--FIGURE OUT HOW TO GET RID OF field_name & ngram AS ARGUMENTS
# used in script: "NOT CURRENTLY USED ANYWHERE"
# function to create bubble plots, where x = token counts (n), y = number of unique identifiers, and bubble size = number of unique first authors
  # takes arguments:  
    # df: dataframe from Global Environment to use in plot
    # field_name: Choose the following based on the df -- "Title", "Keywords", "Abstract", "entityName", "attributeName", "attributeLabel", "attributeDescription" -- as character string
    # ngram: Choose the following based on the df -- "Individual", "Bigram", "Trigram" -- as character string
    # AuthorGreaterThanValue: any term that has been used X# of unique first authors gets colored red and labeled with the corresponding term
    # nudgeX: horizontal adjustment to nudge the starting position of each text label
    # nudgeY: vertical adjustment to nudge the starting position of each text label
#-----------------------------

# ALL data
# create_termCounts_byAuthorAndID_plot <- function(df, field_name, ngram, AuthorGreaterThanValue, nudgeX, nudgeY){ 
#   
#   # generate plot object name
#   plotObjectName <- gsub("Tokens", "_BubblePlot", df)
#   print(plotObjectName)
#   
#   # create plot
#   termCounts_byAuthorAndID_plot <- ggplot(df, aes(x = n, y = unique_ids, size = unique_authors, label = token)) +
#     geom_text_repel(data = subset(df, unique_authors > AuthorGreaterThanValue),
#                     nudge_x = nudgeX, nudge_y = nudgeY, segment.size = 0.2, segment.color = "grey50", direction = "x") +
#     geom_point(color = ifelse(df$unique_authors > AuthorGreaterThanValue, "red", "black"), alpha = 0.4, shape = 21) +
#     scale_size(range = c(0.01, 10), name = "# of Unique First Authors") +
#     labs(x = "Term Counts",
#          y = "# of Unique Identifiers",
#          title = paste(field_name, "Terms -", ngram, "Tokens"), 
#          caption = paste("Red points signify terms that are used by more than", AuthorGreaterThanValue, "unique first authors")) +
#     theme_light() +
#     theme(legend.position = "bottom",
#           plot.caption = element_text(size = 10, hjust = 1, color = "darkgray", face = "italic"))
#   
#   
#   plot(termCounts_byAuthorAndID_plot)
# }

#-----------------------------
# used in script: "_____________________"
# function to weight n and unique_ids by number of unique_authors for a single "most important term" score
  # takes arguments:
    # df: dataframe of filtered_tokenCounts, in Global Environment
#-----------------------------

# calculate_weighted_score <- function(df){
#   
#   # calculate weighted scores
#   new_table <- df %>% 
#     mutate(weighted_n = n/unique_authors,
#            weighted_ids = unique_ids/unique_authors,
#            score = weighted_n + weighted_ids) %>% 
#     arrange(score) 
#   
#   # update exisitng objects
#   assign(name, new_table, envir = .GlobalEnv)
# }

