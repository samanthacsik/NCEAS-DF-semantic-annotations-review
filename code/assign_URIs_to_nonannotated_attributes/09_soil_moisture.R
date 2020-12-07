# title: Identifying attributes to be annotated -- soil moisture
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
#-------------------------------------------------soil moisture----------------------------------------------------------#
##########################################################################################################################

##########################################################################################
# 1) soil moisture attributeNames 
  # a) identify attributeName variants of 'soil moisture'
  # b) assign appropriate valueURIs -- manually inspected attributeNames, attributeLabels, attributeDefinitions, and downloaded those that needed further investigation
  # c) combine into single df
##########################################################################################

##############################
# a) identify datapackages that use variants of 'soil moisture'  
##############################

soil_moisture_terms <- nonannotated_attributes %>% 
  filter(str_detect(attributeDefinition, "(?i)soil moisture") |
         str_detect(attributeName, "(?i)soil moisture") |
         str_detect(attributeLabel, "(?i)soil moisture")) %>% 
         #attributeName %in% c("VOLUMETRIC", "VOLUMETRIC (PERCENT)", "vwc")) %>% 
  filter(!attributeName %in% c("Soil Moisture (from Komarkova 1983)", "Type"))

###############################
# b) determine appropriate valueURIs 
##############################

#--------------------Soil Moisture Percentage: "http://purl.dataone.org/odo/ECSO_00000517"--------------------

smp <- soil_moisture_terms %>% 
  filter(str_detect(attributeDefinition, "(?i)percent") |
         attributeName %in% c("AvSoilMoisture")) %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00000517"))

#--------------------Gravimetric Soil Moisture Percentage: "http://purl.dataone.org/odo/ECSO_00001583"--------------------

gsm <- soil_moisture_terms %>% 
  filter(str_detect(attributeDefinition, "(?i)gravimetric")) %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00001583"))

#--------------------soil moisture - ratio: "http://purl.dataone.org/odo/ECSO_00002804"--------------------

smr <- soil_moisture_terms %>% 
  filter(str_detect(attributeDefinition, "(?i)volumetric") |
         attributeName %in% c("SMOIS", "SMCREL") |
         attributeUnit == "cubicCentimetersPerCubicCentimeter") %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00002804"))

# accounted_for <- rbind(smp, gsm, smr)
# remaining <- soil_moisture_terms %>%
#   anti_join(accounted_for)

##############################
# c) combine soil temp dfs -- STILL NEED TO ADD IN mean_soil_temp ATTRIBUTES WITH APPROPRIATE URI
##############################

soil_moisture_annotations <- rbind(smp, gsm, smr)

# check for duplicates
double_check <- soil_moisture_annotations %>% 
  select(-assigned_valueURI)
double_check2 <- get_dupes(double_check)

# get distinct rows
soil_moisture_annotations <- distinct(soil_moisture_annotations)
