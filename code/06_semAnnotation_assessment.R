# title: Most commonly used semantic annotations in the ADC
# author: "Sam Csik"
# date created: "2020-10-07"
# date edited: "2020-10-23"
# R version: 3.6.3
# input: "data/queries/query2020-10-01/fullQuery_semAnnotations2020-10-01_webscraping.csv" & "fullQuery_semAnnotations2020-10-01_solr.csv"
# output: 

##########################################################################################
# Summary
##########################################################################################

# This script explores current semantic annotation frequencies in the ADC corpus
  # 1) plot most commonly used annotations for ALL ADC
  # 2) plot most commonly used annotations, grouped by time period (pre vs post-Aug 2020)
  # 3) create table for RMarkdown report with annotation counts (total, preAug, postAug) + unique IDs + unique authors

##########################################################################################
# General setup
##########################################################################################

##############################
# Load packages
##############################

source(here::here("code", "00_libraries.R"))
source(here::here("code", "00_functions.R"))

##############################
# Import data
##############################

solr_query <- read_csv(here::here("data", "queries", "query2020-10-12", "fullQuery_semAnnotations2020-10-12_solr.csv"))
annotations <- read_csv(here::here("data", "queries", "query2020-10-12", "fullQuery_semAnnotations2020-10-12_webscraping_allAttributes.csv"))

##############################
# Add `dateUploaded`, and 'author' fields from `solr_query` to `annotations` df
##############################

dateUploaded_author <- solr_query %>% select(identifier, dateUploaded, author) 
annotations <- inner_join(annotations, dateUploaded_author)
# write.csv(annotations, here::here("data", "outputs", "extracted_annotations.csv"))

##########################################################################################
# 1) plot most used semantic annotations for ALL annotated ADC packages
##########################################################################################

# calculate frequencies
annotation_counts <- annotations %>% 
  mutate(prefName = stringr::str_to_lower(prefName)) %>% 
  count(prefName, valueURI, sort = TRUE)

# write.csv(annotation_counts, here::here("data", "outputs", paste("all_semAnnotation_counts", Sys.Date(), ".csv", sep = "_")))

# plot 
semAnnotation_freq_plot <- annotation_counts %>%
  filter(n > 20) %>% 
  #head(100) %>%
  mutate(prefName = reorder(prefName, n)) %>%
  rename(Counts = n) %>%
  ggplot(aes(prefName, Counts)) +
  geom_col() +
  labs(title = "Semantic Annotations Used >20 Times Across ADC Corpus",
       #subtitle = "As of 2020-10-12, 185 unique ADC identifiers have (at least one) semantically-annotated attributes",
       caption = "`NA`s represent annotations from non-ECSO ontologies",
       x = "Semantic Annotation (preferred name)") +
  scale_y_continuous(expand = c(0,0)) +
  coord_flip() +
  theme_linedraw() +
  theme(
    axis.title = element_text(face = "bold", size = 17),
    axis.text = element_text(size = 10),
    plot.title = element_text(face = "bold", size = 20),
    #plot.subtitle = element_text(size = 17),
    plot.caption = element_text(size = 17, hjust = 1, color = "darkgray", face = "italic"))

# ggsave(filename = here::here("figures", "semAnnotation_frequencies.png"), plot = semAnnotation_freq_plot, height = 15, width = 15)

semAnnotation_freq_plot <- semAnnotation_freq_plot +
  plot_annotation(tag_levels = "1", tag_prefix = "Fig.")

##########################################################################################
# 2) plot most used semantic annotations pre-2020 and post-Aug2020
##########################################################################################

##############################
# separate datasets pre- and post-August 1, 2020
##############################

# before August 1, 2020
preAug2020 <- annotations %>% 
  separate(dateUploaded, into = c("date", "time"), sep = " ") %>% 
  filter(date < "2020-08-01") %>% 
  unite(col = dateUploaded, date, time, sep = " ") %>% 
  mutate(prefName = stringr::str_to_lower(prefName)) %>% 
  count(prefName, valueURI, sort = TRUE)

# for RMarkdown
tot_num_annotations_preAug2020 <- sum(preAug2020$n)

# write.csv(annotation_counts, here::here("data", "outputs", paste("preAug2020_semAnnotation_counts", Sys.Date(), ".csv", sep = "_")))

# before August 1, 2020
postAug2020 <- annotations %>% 
  separate(dateUploaded, into = c("date", "time"), sep = " ") %>% 
  filter(date >= "2020-08-01") %>% 
  unite(col = dateUploaded, date, time, sep = " ") %>% 
  mutate(prefName = stringr::str_to_lower(prefName)) %>% 
  count(prefName, valueURI, sort = TRUE)

# for RMarkdown
tot_num_annotations_postAug2020 <- sum(postAug2020$n)
# write.csv(annotation_counts, here::here("data", "outputs", paste("postAug2020_semAnnotation_counts", Sys.Date(), ".csv", sep = "_")))

##############################
# plot
##############################

# before August 1, 2020
preAug2020_freq_plot <- preAug2020 %>%
  filter(n > 15) %>% 
  mutate(prefName = reorder(prefName, n)) %>%
  rename(Counts = n) %>%
  ggplot(aes(prefName, Counts)) +
  geom_col() +
  labs(x = "Semantic Annotation (preferred name)") +
  scale_y_continuous(expand = c(0,0)) +
  coord_flip() +
  theme_linedraw() +
  theme(axis.text = element_text(size = 15),
        axis.title = element_text(size = 17, face = "bold"))

# after August 1, 2020
postAug2020_freq_plot <- postAug2020 %>%
  filter(n > 15) %>% 
  mutate(prefName = reorder(prefName, n)) %>%
  rename(Counts = n) %>%
  ggplot(aes(prefName, Counts)) +
  geom_col() +
  labs(x = "Semantic Annotation (preferred name)") +
  scale_y_continuous(expand = c(0,0)) +
  coord_flip() +
  theme_linedraw() +
  theme(axis.text = element_text(size = 14),
        axis.title = element_text(size = 16, face = "bold"))
 
# together
prepostAug2020_freq_plot <- preAug2020_freq_plot + postAug2020_freq_plot +
  plot_annotation(
    title = "Semantic Annotations Used >15 Times in Data Packages Uploaded (a) Prior to 2020-08-01 and (b) On/After 2020-08-01",
    # subtitle  = "185 data packages containing annotations have been uploaded to the ADC, as of 2020-08-12 (139 prior & 46 post August 1, 2020)",
    caption = "`NA`s represent annotations from non-ECSO ontologies",
    tag_levels = "a", tag_prefix = "Fig. 2",
    theme = theme(plot.title = element_text(size = 21, face = "bold"),
                  # plot.subtitle = element_text(size = 15), 
                  plot.caption = element_text(size = 17, face = "italic", color = "darkgray"))
  ) 

# ggsave(filename = here::here("figures", "semAnnotation_prepostAug2020_frequencies.png"), plot = prepostAug2020_freq_plot, height = 15, width = 25)

##########################################################################################
# 3) data for RMarkdown report
##########################################################################################

##############################
# create table 4 - total counts, unique IDs, unique authors data for RMarkdown report
##############################

# total annotation counts -- copied from part 1 above
annotation_counts 

# unique ID counts for each token
uniqueID_counts <- annotations %>% 
  mutate(prefName = stringr::str_to_lower(prefName)) %>% 
  group_by(prefName) %>% 
  summarise(unique_ids = n_distinct(identifier)) %>% 
  arrange(-unique_ids)

# unique ID counts for each token
uniqueAuthor_counts <- annotations %>% 
  mutate(prefName = stringr::str_to_lower(prefName)) %>% 
  group_by(prefName) %>%
  summarise(unique_authors = n_distinct(author)) %>%
  arrange(-unique_authors)

# caluclate pre and postAug annotation counts
pre_new <- preAug2020 %>% 
  rename(preAug_n = n)

post_new <- postAug2020 %>% 
  rename(postAug_n = n)

# full_join dfs by token -- first token_counts and uniqueID_counts
my_file <- full_join(annotation_counts, uniqueID_counts)
# then join uniqueAuthor_counts
my_file <- full_join(my_file, uniqueAuthor_counts)
# then join preAug counts 
my_file <- full_join(my_file, pre_new)
# then postAug counts
Table3_annotation_counts <- full_join(my_file, post_new) %>% 
  select(prefName, valueURI, n, preAug_n, postAug_n, unique_ids, unique_authors) %>% 
  mutate(preAug_n = replace_na(preAug_n, replace = "0")) %>% 
  mutate(postAug_n = replace_na(postAug_n, replace = "0")) %>% 
  mutate(prefName = replace_na(prefName, replace = "NA"))

# write.csv(Table3_annotation_counts, here::here("data", "outputs", "semAnnotation_counts.csv"), row.names = FALSE)

##############################
# Table 5: streamlined version of raw data for embedding in RMarkdown
##############################

streamlined <- annotations %>% 
  select(identifier, attributeName, prefName, valueURI)


