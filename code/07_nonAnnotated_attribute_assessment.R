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

# exploring nonannotated attributes, in particular attributeNames (individual tokens)

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

# print for report
# write.csv(attributeNameIndivTokens, here::here("data", "outputs", "attributeNameIndivTokens.csv"))

# not too much gained from including bigrams & trigrams
# attributeName_plots <- attributeNameIndiv_plot + attributeNameBigram_plot + attributeNameTrigram_plot

attributeNameIndivTokens2 <- attributeNameIndivTokens %>% 
  filter(n > 15) %>% 
  mutate(
    `Term Category` = case_when(
      token == "position" ~ "location",
      token == "latitude" ~ "location",
      token == "longitude" ~ "location",
      token == "top" ~ "location",
      token == "bottom" ~ "location",
      token == "station" ~ "location",
      token == "plot" ~ "location",
      token == "location" ~ "location",
      token == "site" ~ "location",
      token == "date" ~ "temporal",
      token == "phase" ~ "temporal",
      token == "5yrs" ~ "temporal",
      token == "soil" ~ "environmental materials",
      token == "snow" ~ "environmental materials",
      token == "ice" ~ "environmental materials",
      token == "quality" ~ "QC/Confidence",
      token == "confidence" ~ "QC/Confidence",
      token == "depth" ~ "measurement",
      token == "intensity" ~ "measurement",
      token == "distance" ~ "measurement",
      token == "height" ~ "measurement"
      ),
    `Term Category` = str_replace_na(`Term Category`, "other")
  ) %>% 
  mutate(`Term Category` = fct_relevel(`Term Category`, c("location", "temporal", "QC/Confidence", "environmental materials", "measurement", "NA"))) 
  
# specifically focus on attributeName individual tokens
attributeName_pretty <- attributeNameIndivTokens2 %>%
  mutate(token = reorder(token, n)) %>%
  rename(Counts = n) %>%
  ggplot(aes(token, Counts, fill = `Term Category`)) +
  geom_col() +
  labs(x = "attributeName (unnested, individual terms)",
       y = "Counts") +
  scale_y_continuous(expand = c(0,0)) +
  scale_fill_manual(values = c("#009E73", "#CC79A7", "#F0E442", "#56B4E9", "#E69F00", "#999999")) +
  coord_flip() +
  theme_linedraw() +
  theme_bw(base_size=12,base_family="Helvetica") +
  theme(axis.title = element_text(size = 17, face = "bold"),
        axis.text = element_text(size = 16),
        legend.title = element_text(size = 20, face = "bold"),
        legend.text = element_text(size = 16),
        legend.position = "bottom")

# modify with patchwork for consistency with previous scripts
attributeName_pretty  <- attributeName_pretty  +
  plot_annotation(
    title = "Non-annotated attributeNames (individual tokens) Used >15 Times in ADC Data Packages Containing at Least One Annotated Attribute",
    tag_prefix = "Fig. 3", 
    theme = theme(plot.title = element_text(size = 21, face = "bold"))
  )

# ggsave(filename = here::here("figures", "nonAnnotated_attributeName_COLORED_frequencies.png"), plot = attributeName_pretty, height = 15, width = 15)