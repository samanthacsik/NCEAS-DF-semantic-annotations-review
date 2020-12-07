# title: Identifying attributes to be annotated -- precipitation
# author: "Sam Csik"
# date created: "2020-12-03"
# date edited: "2020-12-03"
# R version: 3.6.3
# input: "data/queries/query2020-10-12/fullQuery_semAnnotations2020-10-12_attributes.csv" & "data/queries/query2020-10-12_attributes_from_nonannotated_datapackages/attributes_from_nonannotated_datapackages_tidied.csv"
# output: "data/output/annotate_these_attributes_2020-11-17.csv"

##########################################################################################
# Summary
##########################################################################################

# Identify any soil moisture-related attributes; assign appropriate annotation URIs

##############################
# Load packages
##############################

source(here::here("code", "00_libraries.R"))

##############################
# Import data
##############################

source(here::here("code", "09a_list_nonannotated_attributes.R"))

##########################################################################################################################
#-------------------------------------------------precipitation----------------------------------------------------------#
##########################################################################################################################

##########################################################################################
# 1) precipitation attributeNames 
  # a) identify attributeName variants of 'precipitation'
  # b) assign appropriate valueURIs -- manually inspected attributeNames, attributeLabels, attributeDefinitions, and downloaded those that needed further investigation
  # c) combine into single df
##########################################################################################

##############################
# a) identify datapackages that use variants of 'precipitation'  
##############################

precipitation_terms <- nonannotated_attributes %>% 
  filter(str_detect(attributeDefinition, "(?i)precipitation") |
         str_detect(attributeName, "(?i)precipitation") |
         str_detect(attributeLabel, "(?i)precipitation")) 

###############################
# b) determine appropriate valueURIs 
##############################

#--------------------Precipitation Rate: "http://purl.dataone.org/odo/ECSO_00001162"--------------------

rate <- precipitation_terms %>% 
  filter(str_detect(attributeDefinition, "(?i)rate") |
         attributeUnit %in% c("millimeterPerMonth", "millimeterPerDay", "millimeterWaterEquivalentPerDay", "millimetersWaterEquivalentPerDay")) %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00001162"))

#--------------------Precipitation Volume: "http://purl.dataone.org/odo/ECSO_00001237"--------------------

volume <- precipitation_terms %>% 
  filter(attributeUnit %in% c("kilometerCubed")) %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00001237"))

#--------------------Precipitation Volume: "http://purl.dataone.org/odo/ECSO_00001223"--------------------

height <- precipitation_terms %>% 
  filter(attributeUnit %in% c("millimeter", "milliliter") |
         attributeName %in% c("rain_mm")) %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00001223"))

# accounted_for <- rbind(rate, volume, height)
# remaining <- precipitation_terms %>%
#   anti_join(accounted_for)

##############################
# c) combine soil temp dfs -- STILL NEED TO ADD IN mean_soil_temp ATTRIBUTES WITH APPROPRIATE URI
##############################

precipitation_annotations <- rbind(rate, volume, height)

# check for duplicates
double_check <- precipitation_annotations %>% 
  select(-assigned_valueURI)
double_check2 <- get_dupes(double_check)

# get distinct rows
precipitation_annotations <- distinct(precipitation_annotations)
