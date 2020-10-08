# title: Most commonly used semantic annotations in the ADC
# author: "Sam Csik"
# date created: "2020-10-07"
# date edited: "2020-10-07"
# R version: 3.6.3
# input: "data/queries/query2020-10-01/fullQuery_semAnnotations2020-10-01_webscraping.csv"
# output: 

##########################################################################################
# Summary
##########################################################################################

# ...

##########################################################################################
# General setup
##########################################################################################

##############################
# Load packages
##############################

source(here::here("code", "0_libraries.R"))

##############################
# Import data
##############################

annotations <- read_csv(here::here("data", "queries", "query2020-10-01", "fullQuery_semAnnotations2020-10-01_webscraping.csv"))

##########################################################################################
# plot annotation frequencies
##########################################################################################

# calculate frequencies
annotation_counts <- annotations %>% 
  mutate(prefName = stringr::str_to_lower(prefName)) %>% 
  count(prefName, sort = TRUE)

# plot 
semAnnotation_freq_plot <- annotation_counts %>%
  filter(n > 20) %>% 
  #head(100) %>%
  mutate(prefName = reorder(prefName, n)) %>%
  rename(Counts = n) %>%
  ggplot(aes(prefName, Counts)) +
  geom_col() +
  labs(title = "Semantic Annotations Used >20 Times Across ADC Holdings",
       subtitle = "As of 2020-10-01, 184 unique ADC identifiers have (at least one) semantically-annotated attributes",
       caption = "`NA`s represent annotations from non-ECSO ontologies",
       x = "Semantic Annotation (preferred name)") +
  scale_y_continuous(expand = c(0,0)) +
  coord_flip() +
  theme_linedraw() +
  theme(
    plot.title = element_text(face = "bold"),
    plot.caption = element_text(size = 12, hjust = 1, color = "darkgray", face = "italic"))

ggsave(filename = here::here("figures", "semAnnotation_frequencies.png"), plot = semAnnotation_freq_plot, height = 15, width = 15)

##########################################################################################
# 
##########################################################################################

# # get unique valueURIs and convert prefNames to all lowercase
# unique_valueURIs <- annotations %>% 
#   distinct(valueURI, prefName) %>% 
#   mutate(prefName = stringr::str_to_lower(prefName))
# 
# # identify topical areas
# compounds <- c("carbon", "nitrogen", "oxygen", "phosphate", "nitrate", "nitrite", "silica")
# water <- c("water")
# temperature <- c("temperature")