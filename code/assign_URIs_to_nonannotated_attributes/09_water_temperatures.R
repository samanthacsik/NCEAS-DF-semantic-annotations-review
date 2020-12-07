# title: Identifying attributes to be annotated -- water temperature
# author: "Sam Csik"
# date created: "2020-11-13"
# date edited: "2020-11-20"
# R version: 3.6.3
# input: "data/queries/query2020-10-12/fullQuery_semAnnotations2020-10-12_attributes.csv" & "data/queries/query2020-10-12_attributes_from_nonannotated_datapackages/attributes_from_nonannotated_datapackages_tidied.csv"
# output: "data/output/annotate_these_attributes_2020-11-17.csv"

##########################################################################################
# Summary
##########################################################################################

# Identify all water temperature-related attributes; assign appropriate annotation URIs

##############################
# Load packages
##############################

source(here::here("code", "00_libraries.R"))

##############################
# Import data
##############################

source(here::here("code", "09a_list_nonannotated_attributes.R"))

##########################################################################################################################
#-----------------------------------------------water temperature--------------------------------------------------------#
##########################################################################################################################

##########################################################################################
# 1) water temperature attributeNames 
  # a) identifiy attributeName variants of 'water temperature'
  # b) assign appropriate valueURIs -- manually inspected attributeNames, attributeLabels, attributeDefinitions, and downloaded those that needed further investigation
  # c) combine into single df
##########################################################################################

##############################
# a) identify datapackages that use variants of 'water temperature'  
##############################

lake_temp_attNames <- nonannotated_attributes %>% 
  filter(str_detect(attributeDefinition, "^Recorded temperature in celsius by the logger*")) 

# coarse filter
general_water_temp <- nonannotated_attributes %>% 
  filter(str_detect(attributeDefinition, "(?i)water temperature"))

###############################
# b) determine appropriate valueURIs 
##############################

#--------------------Lake Temperature: "http://purl.dataone.org/odo/ECSO_00001231"--------------------
lake_temps1 <- lake_temp_attNames %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00001231"))

lake_temps2 <- general_water_temp %>% 
  filter(entityName %in% c("2013_Eugster-Kling_AON_Toolik_met.csv", "Kangerlussuaq_water_quality_data_2013_2018.csv") |
         str_detect(entityName, "^2015_2016_Orcutt_*") |
         attributeName %in% c("Temp_ºC")) %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00001231"))

#--------------------sea water temperature: "http://purl.dataone.org/odo/ECSO_00001226"-------------------- 
seawater_temp1 <- general_water_temp %>% 
  filter(attributeName %in% c("Surface Temperature", "Temp ( C)", "temperature_C", "TSG_Teq_sm") |
         attributeDefinition %in% c("sea water temperature", "Sea water temperature in degrees Celsius as measured by RBR XR-620 CTD (#18608).", "sea water temperature (degrees_Celsius)") |
         attributeLabel %in% c("Temperature, probe 1", "Temperature, probe 2") |
         identifier %in% c("doi:10.18739/A2DJ58G59", "doi:10.18739/A2N29P63K", "doi:10.18739/A2HM52K5S") |
         str_detect(entityName, "^PetermannIceShelf_*")) %>% 
  filter(attributeName != "Salinity") %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00001226"))

seawater_temp2 <- general_water_temp %>% 
  filter(identifier == "doi:10.18739/A22J6846K",
         attributeName == "Temperature") %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00001226"))

#--------------------sea surface temperature: "http://purl.dataone.org/odo/ECSO_00001523"--------------------
sst <- general_water_temp %>% 
  filter(attributeName %in% c("SST_sm")) %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00001523"))

#--------------------potential temperature: "http://purl.dataone.org/odo/ECSO_00001161"--------------------
potential_temp <- general_water_temp %>% 
  filter(identifier == "doi:10.18739/A22J6846K",
         attributeName == "Potential temperature") %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00001161"))

#--------------------river water temperature: "http://purl.dataone.org/odo/ECSO_00001528"-------------------- 
river_temp <- general_water_temp %>% 
  filter(identifier %in% c("urn:uuid:0b548a56-aff5-48c6-ae8d-0bc94d954ed1", "doi:10.18739/A26P32", "doi:10.18739/A22804Z8M", "doi:10.18739/A25M62692", "doi:10.18739/A20P0WR15", "doi:10.18739/A2DN3ZW76", "doi:10.18739/A2D795B84") |
         entityName %in% c("2002-2013_Kling_AON_Imnavait_Chemistry.csv", "2002-2018_Kling_AON_Imnavait_Chemistry_csv") |
         attributeName %in% c("Temperature (deg-C)", "Water_T")) %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00001528"))

#--------------------do not consider--------------------
do_not_consider <- general_water_temp %>% 
  filter(attributeName %in% c("borehole_water_temp_C", "drill_water_temp_C", "Groundwater_temperature", "mean.temp", "Salinity") |
         entityName %in% c("IBP C Daily NEP")) %>% 
  mutate(assigned_valueURI = rep("do not consider"))

meltwater_temp_NO_ANNOTATION_MATCH <- general_water_temp %>% 
  filter(entityName %in% c("Russell_Glacier_Water.csv")) %>% 
  mutate(assigned_valueURI = rep("do not consider"))

# check-in to make sure all terms are accouted for
# accounted_for <- rbind(seawater_temp1, seawater_temp2, sst, potential_temp, lake_temps2, river_temp, do_not_consider, meltwater_temp_NO_ANNOTATION_MATCH)
# remaining <- general_water_temp %>%
#   anti_join(accounted_for)

##############################
# c) combine water temp dfs
##############################

water_temp_annotations <- rbind(lake_temps1, lake_temps2, seawater_temp1, seawater_temp2, potential_temp, river_temp)

# check for duplicates
double_check <- water_temp_annotations %>% 
  select(-assigned_valueURI)
double_check2 <- get_dupes(double_check)

# get distinct rows
water_temp_annotations <- distinct(water_temp_annotations)
