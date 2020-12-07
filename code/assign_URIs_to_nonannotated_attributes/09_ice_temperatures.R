# title: Identifying attributes to be annotated -- ice temperatures
# author: "Sam Csik"
# date created: "2020-11-13"
# date edited: "2020-11-20"
# R version: 3.6.3
# input: "data/queries/query2020-10-12/fullQuery_semAnnotations2020-10-12_attributes.csv" & "data/queries/query2020-10-12_attributes_from_nonannotated_datapackages/attributes_from_nonannotated_datapackages_tidied.csv"
# output: "data/output/annotate_these_attributes_2020-11-17.csv"

##########################################################################################
# Summary
##########################################################################################

# Identify ice temperature-related attributes in ADC corpus; assign appropriate annotation URI

##############################
# Load packages
##############################

source(here::here("code", "00_libraries.R"))

##############################
# Import data
##############################

source(here::here("code", "09a_list_nonannotated_attributes.R"))

##########################################################################################################################
#-----------------------------------------------ice temperatures---------------------------------------------------------#
##########################################################################################################################

##########################################################################################
# 1) ice temperature attributeNames -- isolating attributeNames that are integers
  # a) identify attributeName variants of 'ice temperature'
  # b) assign appropriate valueURIs -- manually inspected attributeNames, attributeLabels, attributeDefinitions, and downloaded those that needed further investigation
  # c) combine into single df
##########################################################################################

# coarse filter; narrow down by attributeDefinition
#-------------------------------------------------------
temp_at <- nonannotated_attributes %>% 
  filter(str_detect(attributeDefinition, "^Temperature at*"))

temp_below <- temp_at %>% 
  filter(str_detect(attributeDefinition, "(?i)below")) %>% 
  filter(!str_detect(attributeName, "^Temp_*"))
#-------------------------------------------------------

# refined filter
# (NOTE: definitions only say "...above surface" rather than "...above ice surface" but are from same entities; I've decided these are also 'above ice' temperature measurements)
temp_above <- temp_at %>% 
  filter(str_detect(attributeDefinition, "(?i)above")) %>% 
  filter(!str_detect(attributeName, "^Temp_*"))

temp_original_surface <- temp_at %>% 
  filter(attributeDefinition == "Temperature at the original ice surface")

cryptic_ice_temp <- nonannotated_attributes %>% 
  filter(attributeName %in% c("temppabase", "tempi"))

###############################
# b) determine appropriate valueURIs 
##############################

#--------------------temperature below ice surface: "http://purl.dataone.org/odo/ECSO_00002796"--------------------
temp_below_ice_attNames <- temp_below %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00002796"))

#--------------------temperature above ice surface: "http://purl.dataone.org/odo/ECSO_00002799"--------------------
temp_above_ice_attNames <- temp_above %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00002799"))

#--------------------temperature at original ice surface: "http://purl.dataone.org/odo/ECSO_00002797"--------------------
temp_at_original_ice_surface_attNames <- temp_original_surface %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00002797"))

#--------------------ice temperature: "http://purl.dataone.org/odo/ECSO_00001558"--------------------
ice_temp_attNames <- cryptic_ice_temp %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00001558"))

##############################
# c) combine ice temperature dfs
##############################

ice_temp_annotations <- rbind(temp_below_ice_attNames, temp_above_ice_attNames, temp_at_original_ice_surface_attNames, ice_temp_attNames)

# check for duplicates
double_check <- ice_temp_annotations %>% 
  select(-assigned_valueURI)
double_check2 <- get_dupes(double_check)

# get distinct rows
ice_temp_annotations <- distinct(ice_temp_annotations)
