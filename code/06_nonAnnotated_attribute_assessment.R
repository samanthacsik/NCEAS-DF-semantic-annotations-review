# title: Most common non-annotated attributes
# author: "Sam Csik"
# date created: "2020-10-15"
# date edited: "2020-10-15"
# R version: 3.6.3
# input: "data/filtered_term/counts/nonannotated_attributes2020-10-12/*"
# output: 

##########################################################################################
# Summary
##########################################################################################

# 

##########################################################################################
# General setup
##########################################################################################

##############################
# Load packages & custom functions
##############################

source(here::here("code", "00_libraries.R"))
source(here::here("code", "00_functions.R"))

##########################################################################################
#  Import Data
##########################################################################################

# isolate filtered_token_counts
all_files <- list.files(path = here::here("data", "filtered_term_counts", "nonannotated_attributes2020-10-12"), pattern = glob2rx("filteredCounts_*"))

# remove excess columns, filter out stop_words, remove NAs, calculate counts
for(i in 1:length(all_files)){
  file_name <- all_files[i]
  import_filteredTermCounts(file_name)
}

##########################################################################################
# Get data into appropriate format for plotting
# 1) combine bigrams into single column for plotting
# 2) combine trigrams into single column for plotting
##########################################################################################

##############################
# 1) combine bigrams
##############################

# get lists of bigram dfs
bigram_list <- mget(ls(pattern = "BigramTokens"))

# combine words in bigram dfs
for(i in 1:length(bigram_list)){
  obj <- bigram_list[i]
  object <- obj[[1]]
  name <- names(obj)
  combine_bigrams(object = object, object_name = name)
}

##############################
# 2) combine trigrams
##############################

# get list of trigram dfs
trigram_list <- mget(ls(pattern = "TrigramTokens"))

# combine words in trigram dfs
for(i in 1:length(trigram_list)){
  obj <- trigram_list[i]
  object <- obj[[1]]
  name <- names(obj)
  combine_trigrams(object = object, object_name = name)
}

##########################################################################################
# Create token frequency plots (arranged by Counts)
# 1) create separate plots
# 2) combine plots into single, multi-panel plot using the patchwork package
##########################################################################################

##############################
# create plots & save to global environment
##############################

# get updated list of all dfs
wrangledTokens_list <- mget(ls(pattern = glob2rx("*Tokens")))

# plot
for(i in 1:length(wrangledTokens_list)){
  obj <- wrangledTokens_list[i]
  df <- obj[[1]]
  name <- names(obj)
  print(name)
  create_frequencyByCount_plot(tokens_df = df, df_name = name)
}

##############################
# combine figure panels and save
##############################

# not too much gained from including bigrams & trigrams
attributeName_plots <- attributeNameIndiv_plot + attributeNameBigram_plot + attributeNameTrigram_plot

location_terms <- c("position", "depth", "latitude", "logitude", "top", "bottom", "station", "plot", "location", "site", "height")
time_terms <- c("date", "phase", "5yrs")
unusual <- c("soil", "snow", "ice")
qc_terms <- c("quality", "confidence")
measurement_terms <- c("depth", "intensity", "distance", "height")

attributeNameIndivTokens <- attributeNameIndivTokens %>% 
  filter(n > 15) %>% 
  mutate(
    color = case_when(
      token == "position" ~ "location_terms",
      token == "latitude" ~ "location_terms",
      token == "longitude" ~ "location_terms",
      token == "top" ~ "location_terms",
      token == "bottom" ~ "location_terms",
      token == "station" ~ "location_terms",
      token == "plot" ~ "location_terms",
      token == "location" ~ "location_terms",
      token == "site" ~ "location_terms",
      token == "date" ~ "time_terms",
      token == "phase" ~ "time_terms",
      token == "5yrs" ~ "time_terms",
      token == "soil" ~ "unusual",
      token == "snow" ~ "unusual",
      token == "ice" ~ "unusual",
      token == "quality" ~ "qc_terms",
      token == "confidence" ~ "qc_terms",
      token == "depth" ~ "meaurement_terms",
      token == "intensity" ~ "meaurement_terms",
      token == "distance" ~ "meaurement_terms",
      token == "height" ~ "meaurement_terms"
      ),
    str_replace_na(color, replacement = "NA")
  ) 
  

# specifically focus on attributeName individual tokens
attributeName_pretty <- attributeNameIndivTokens %>%
  mutate(token = reorder(token, n)) %>%
  rename(Counts = n) %>%
  ggplot(aes(token, Counts, fill = color)) +
  geom_col() +
  labs(title = "Non-annotated attributeNames Used >15 Times in ADC Data Packages Containing at Least One Annotated Attribute",
       subtitle = "As of 2020-10-12, 185 unique ADC identifiers have (at least one) semantically-annotated attributes",
       x = "attributeName",
       y = "Counts") +
  scale_y_continuous(expand = c(0,0)) +
  coord_flip() +
  theme_linedraw() +
  theme_bw(base_size=12,base_family="Helvetica") +
  theme(plot.title = element_text(size = 15, face = "bold", margin = margin(10,0,10,0)),
        plot.subtitle = element_text(size = 13, margin = margin(0,0,10,0)),
        axis.title = element_text(size = 11, face = "bold"),
        axis.text = element_text(size = 10),
        legend.position = "none")

ggsave(filename = here::here("figures", "nonAnnotated_attributeName_COLORED_frequencies.png"), plot = attributeName_pretty, height = 15, width = 15)

