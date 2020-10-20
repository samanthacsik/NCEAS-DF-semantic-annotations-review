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
      token == "position" ~ "location terms",
      token == "latitude" ~ "location terms",
      token == "longitude" ~ "location terms",
      token == "top" ~ "location terms",
      token == "bottom" ~ "location terms",
      token == "station" ~ "location terms",
      token == "plot" ~ "location terms",
      token == "location" ~ "location terms",
      token == "site" ~ "location terms",
      token == "date" ~ "temporal terms",
      token == "phase" ~ "temporal terms",
      token == "5yrs" ~ "temporal terms",
      token == "soil" ~ "environmental materials",
      token == "snow" ~ "environmental materials",
      token == "ice" ~ "environmental materials",
      token == "quality" ~ "QC/confidence terms",
      token == "confidence" ~ "QC/confidence terms",
      token == "depth" ~ "meaurement terms",
      token == "intensity" ~ "meaurement terms",
      token == "distance" ~ "meaurement terms",
      token == "height" ~ "meaurement terms"
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
        axis.text = element_text(size = 10))

# ggsave(filename = here::here("figures", "nonAnnotated_attributeName_COLORED_frequencies.png"), plot = attributeName_pretty, height = 15, width = 15)

