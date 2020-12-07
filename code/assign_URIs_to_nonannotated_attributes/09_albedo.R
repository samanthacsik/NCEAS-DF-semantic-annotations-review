# title: Identifying attributes to be annotated -- albedo 
# author: "Sam Csik"
# date created: "2020-11-24"
# date edited: "2020-11-24"
# R version: 3.6.3
# input: "data/queries/query2020-10-12/fullQuery_semAnnotations2020-10-12_attributes.csv" & "data/queries/query2020-10-12_attributes_from_nonannotated_datapackages/attributes_from_nonannotated_datapackages_tidied.csv"
# output: "data/output/annotate_these_attributes_2020-11-17.csv"

##########################################################################################
# Summary
##########################################################################################

# Identify all x-related attributes; assign appropriate annotation URIs

##############################
# Load packages
##############################

source(here::here("code", "00_libraries.R"))

##############################
# Import data
##############################

source(here::here("code", "09a_list_nonannotated_attributes.R"))

##########################################################################################################################
#----------------------------------------------------x------------------------------------------------------------#
##########################################################################################################################

##########################################################################################
# 1) salinity attributeNames 
  # a) identifiy attributeName variants of 'albedo'
  # b) assign appropriate valueURIs -- manually inspected attributeNames, attributeLabels, attributeDefinitions, and downloaded those that needed further investigation
  # c) combine into single df
##########################################################################################

##############################
# a) identify datapackages that use variants of 'albedo'  
##############################

general_albedo <- nonannotated_attributes %>% 
  filter(str_detect(attributeDefinition, "(?i)albedo") |
         str_detect(attributeName, "(?i)albedo") |
         str_detect(attributeLabel, "(?i)albedo"))

###############################
# b) determine appropriate valueURIs 
##############################

#--------------------albedo: "http://purl.dataone.org/odo/ECSO_00001694"--------------------
albedo <- general_albedo %>% 
  filter(identifier != "doi:10.18739/A2HM52K87") %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00001694"))

##############################
# c) combine albedo dfs
##############################

albedo_annotations <- rbind(albedo)

# check for duplicates
double_check <- albedo_annotations %>% 
  select(-assigned_valueURI)
double_check2 <- get_dupes(double_check)

# get distinct rows
albedo_annotations <- distinct(albedo_annotations)
