# title: Identifying attributes to be annotated -- snow water equivalent
# author: "Sam Csik"
# date created: "2020-11-23"
# date edited: "2020-11-23"
# R version: 3.6.3
# input: "data/queries/query2020-10-12/fullQuery_semAnnotations2020-10-12_attributes.csv" & "data/queries/query2020-10-12_attributes_from_nonannotated_datapackages/attributes_from_nonannotated_datapackages_tidied.csv"
# output: "data/output/annotate_these_attributes_2020-11-17.csv"

##########################################################################################
# Summary
##########################################################################################

# Identify any snow water equivalent-related attributes; assign appropriate annotation URIs

##############################
# Load packages
##############################

source(here::here("code", "00_libraries.R"))

##############################
# Import data
##############################

source(here::here("code", "09a_list_nonannotated_attributes.R"))

##########################################################################################################################
#---------------------------------------------snow water equivalent------------------------------------------------------#
##########################################################################################################################

##########################################################################################
# 2) snow water equivalent attributeNames 
  # a) identify attributeName variants of 'snow water equivalent'
  # b) assign appropriate valueURIs -- manually inspected attributeNames, attributeLabels, attributeDefinitions, and downloaded those that needed further investigation
  # c) combine into single df
##########################################################################################

##############################
# a) identify datapackages that use variants of 'snow water equivalent'  
##############################

# coarse filter
swe <- nonannotated_attributes %>% 
  filter(str_detect(attributeDefinition, "(?i)snow water equivalent"))

###############################
# b) determine appropriate valueURIs 
##############################

#--------------------snow water equivalent: "http://purl.dataone.org/odo/ECSO_00001747"--------------------
swe_depth <- swe %>% 
  filter(attributeUnit %in% c("millimeter", "centimeter")) %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00001747"))

#--------------------snow water equivalent MOV: "http://purl.dataone.org/odo/ECSO_00000059"-------------------- 
swe_mov <- swe %>% 
  filter(attributeUnit %in% c("kilogramPerMeterSquared")) %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00000059"))

##############################
# c) combine snow water equivalent dfs
##############################

snow_water_equivalent_annotations <- rbind(swe_depth, swe_mov)

# check for duplicates
double_check <- snow_water_equivalent_annotations %>% 
  select(-assigned_valueURI)
double_check2 <- get_dupes(double_check)

# get distinct rows
snow_water_equivalent_annotations <- distinct(snow_water_equivalent_annotations)
