# title: Identifying attributes to be annotated -- soil temperature
# author: "Sam Csik"
# date created: "2020-11-13"
# date edited: "2020-11-20"
# R version: 3.6.3
# input: "data/queries/query2020-10-12/fullQuery_semAnnotations2020-10-12_attributes.csv" & "data/queries/query2020-10-12_attributes_from_nonannotated_datapackages/attributes_from_nonannotated_datapackages_tidied.csv"
# output: "data/output/annotate_these_attributes_2020-11-17.csv"

##########################################################################################
# Summary
##########################################################################################

# Identify any soil temperature-related attributes; assign appropriate annotation URIs

##############################
# Load packages
##############################

source(here::here("code", "00_libraries.R"))

##############################
# Import data
##############################

source(here::here("code", "09a_list_nonannotated_attributes.R"))

##########################################################################################################################
#-----------------------------------------------soil temperature---------------------------------------------------------#
##########################################################################################################################

##########################################################################################
# 1) soil temperature attributeNames 
  # a) identify attributeName variants of 'soil temperature'
  # b) assign appropriate valueURIs -- manually inspected attributeNames, attributeLabels, attributeDefinitions, and downloaded those that needed further investigation
  # c) combine into single df
##########################################################################################

##############################
# a) identify datapackages that use variants of 'soil temperature'  
##############################

# from doi:10.18739/A2D21RH94, a large datapackage of permafrost measurements with cryptic attributeNames
`doi:10.18739/A2D21RH94_soil_temp` <- nonannotated_attributes %>% 
  filter(identifier == "doi:10.18739/A2D21RH94") %>% 
  filter(str_detect(attributeDefinition, "(?i)temperature")) 

# filtered for def 'Temperature of the soil"
temperature_of_the_soil <- nonannotated_attributes %>% 
  filter(str_detect(attributeDefinition, "^(?i)Temperature of the soil*"))

# all soil temperature attributeNames
soil_temp_attNames <- nonannotated_attributes %>% 
  filter(str_detect(attributeName, "(?i)soil temp") |
           str_detect(attributeDefinition, "(?i)soil temp"))

# identify means and SE attributes
mean_and_SE_soil_temp <- soil_temp_attNames %>% 
  filter(str_detect(attributeDefinition, "(?i)mean")) %>% 
  mutate(assigned_valueURI = rep("TBD"))

# soil temps with means and SEs removed
soil_temp_filtered_attNames <- soil_temp_attNames %>% 
  filter(!attributeName %in% c("Purpose for Measurement", "doy_st", "year_st", "Air or Soil temperature")) %>% 
  anti_join(mean_and_SE_soil_temp)

# there are lots of these...
temp_mrc_all <- nonannotated_attributes %>% 
  filter(str_detect(attributeName, "^Temp_MRC_*"))
  
temp_mrc_soil_depth <- temp_mrc_all %>% 
  filter(!attributeName %in% c("Temp_MRC_air", "Temp_MRC_surf"))

temp_mrc_surf <- temp_mrc_all  %>% 
  filter(attributeName == "Temp_MRC_surf")

# temp_mrc_air <- temp_mrc_all %>% 
#   filter(attributeName == "Temp_MRC_air")

# more soil temps found 2020-12-03 (couldn't figure out how to filter by attributeName == "temp")
more_temps <- nonannotated_attributes %>% 
  filter(attributeDefinition == "The half-hourly mean temperature in degrees Celsius measured by type E thermocouples.")

###############################
# b) determine appropriate valueURIs 
##############################

#--------------------Soil Temperature: "http://purl.dataone.org/odo/ECSO_00001230"--------------------
`doi:10.18739/A2D21RH94_soil_temp_filtered` <- `doi:10.18739/A2D21RH94_soil_temp` %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00001230"))

soil_temps <- soil_temp_filtered_attNames %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00001230"))

temperature_of_the_soil <- temperature_of_the_soil %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00001230"))

temp_mrc_soil_depth <- temp_mrc_soil_depth %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00001230"))

more_temps <- more_temps %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00001230"))

#--------------------soil temperature standard error: "http://purl.dataone.org/odo/ECSO_00002958"--------------------
SE_soil_temp <- mean_and_SE_soil_temp %>% 
  filter(str_detect(attributeDefinition, "(?i)standard error")) %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00002958"))

#--------------------soil surface temperature: "http://purl.dataone.org/odo/ECSO_00001533"--------------------
temp_mrc_surf <- temp_mrc_surf %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00001533"))

#--------------------(do not consider for now) Mean Soil Temperature: "????????????????"--------------------
mean_soil_temp <- mean_and_SE_soil_temp %>% 
  anti_join(SE_soil_temp) %>% 
  mutate(assigned_valueURI = rep("TBD"))

##############################
# c) combine soil temp dfs -- STILL NEED TO ADD IN mean_soil_temp ATTRIBUTES WITH APPROPRIATE URI
##############################

soil_temp_annotations <- rbind(`doi:10.18739/A2D21RH94_soil_temp_filtered`, soil_temps, temperature_of_the_soil, more_temps, SE_soil_temp, temp_mrc_soil_depth, temp_mrc_surf)

# check for duplicates
double_check <- soil_temp_annotations %>% 
  select(-assigned_valueURI)
double_check2 <- get_dupes(double_check)

# get distinct rows
soil_temp_annotations <- distinct(soil_temp_annotations)

