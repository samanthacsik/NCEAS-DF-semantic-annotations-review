# title: Identifying attributes to be annotated -- latitude & longitude
# author: "Sam Csik"
# date created: "2020-11-13"
# date edited: "2020-11-20"
# R version: 3.6.3
# input: "data/queries/query2020-10-12/fullQuery_semAnnotations2020-10-12_attributes.csv" & "data/queries/query2020-10-12_attributes_from_nonannotated_datapackages/attributes_from_nonannotated_datapackages_tidied.csv"
# output: "data/output/annotate_these_attributes_2020-11-17.csv"

##########################################################################################
# Summary
##########################################################################################

# Identify any latitude and/or longitude-related attributes; assign appropriate annotation URIs

##############################
# Load packages
##############################

source(here::here("code", "00_libraries.R"))

##############################
# Import data
##############################

source(here::here("code", "09a_list_nonannotated_attributes.R"))

#########################################################################################################################
#---------------------------------------------------latitude-------------------------------------------------------------#
##########################################################################################################################

##########################################################################################
# 1) latitude attributeNames (NOTE: can use modifier to ignore cases, e.g. `filter(str_detect(attributeName, "(?i)transect"))`)
  # a) identify attributeName variants of 'latitude'
  # b) assign appropriate valueURIs -- manually inspected attributeNames, attributeLabels, attributeDefinitions, and downloaded those that needed further investigation
  # c) combine into single df
##########################################################################################

##############################
# a) identify datapackages that use variants of 'latitude'  
##############################

# all latitude attributeNames
latitude_attNames <- c("lat", "Lat","LAT", "Lat (DD)", "LAT (N)", "lat_bnds", "lat_dd", "Lat(North)", "latitude", "Latitude", "LATITUDE", "Latitude - Deg (N)", "Latitude - Min", "Latitude - Sec", "Latitude (dd.ddd) N", "LATITUDE (DD)", "Latitude (deg N)", "Latitude (N)", "latitude (N+)", "Latitude (North)", "Latitude [degrees_north]", "latitude_dd", "Latitude_ddeg", "Latitude_deg", "latitude_degree", "Latitude_degrees_north", "latitude_minute", "Latitude_N", "Latitude_north", "latitude_WGS84", "latitude..degrees_north.", "Latitute")

# 2949 occurrances
latitude_counts <- unique_nonAnnotated_attNames %>% 
  filter(attributeName %in% latitude_attNames) %>% 
  count(wt = n)

# 818 unique datapackage identifiers
latitude_ids <- nonannotated_attributes %>% 
  filter(attributeName %in% latitude_attNames)

length(unique(latitude_ids$identifier))

###############################
# b) determine appropriate valueURIs 
##############################

#--------------------latitude coordinate: "http://purl.dataone.org/odo/ECSO_00002130"--------------------
latitude_coordinate <- latitude_ids %>% 
  filter(attributeName %in% c("Latitude (dd.ddd) N", "latitude..degrees_north.", "Latitude_deg", "latitude..degrees_north.", "latitude_WGS84", "Latitute", "Latitude_north", "Latitude_N", "Latitude_degrees_north", "Latitude_ddeg", "latitude_dd", "Latitude [degrees_north]", "Latitude (North)", "latitude (N+)", "Latitude (N)", "Latitude (deg N)", "LATITUDE (DD)", "Latitude (dd.ddd) N", "latitude", "Latitude", "LATITUDE", "Lat(North)", "lat_dd", "lat_bnds", "LAT (N)", "Lat (DD)", "LAT", "Lat", "lat")) %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00002130"))

#--------------------latitude degree component: "http://purl.dataone.org/odo/ECSO_00002247"--------------------
latitude_degree <- latitude_ids %>% 
  filter(attributeName %in% c("Latitude - Deg (N)", "latitude_degree")) %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00002247"))

#--------------------latitude minute component: "http://purl.dataone.org/odo/ECSO_00002137"--------------------
latitude_minute <- latitude_ids %>% 
  filter(attributeName %in% c("Latitude - Min", "latitude_minute")) %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00002137"))

#--------------------latitude second component: "	http://purl.dataone.org/odo/ECSO_00002243"--------------------
latitude_second <- latitude_ids %>% 
  filter(attributeName == "Latitude - Sec") %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00002243"))

##############################
# c) combine latitude dfs
##############################

latitude_annotations <- rbind(latitude_coordinate, latitude_degree, latitude_minute, latitude_second)

##########################################################################################################################
#--------------------------------------------------longitude-------------------------------------------------------------#
##########################################################################################################################

##########################################################################################
# 3) longitude attributeNames 
  # a) identify attributeName variants of 'longitude' -- manually inspected attributeNames, attributeLabels, attributeDefinitions, and downloaded those that needed further investigation
  # b) assign appropriate valueURIs
  # c) combine into single df
##########################################################################################

##############################
# a) identify datapackages that use variants of 'longitude'  
##############################

# all latitude attributeNames
longitude_attNames <- c("lon", "Lon", "LON", "lon_bnds", "Lon(East)", "Longitude", "long", "Long", "LONG", "Long (DD)", "LONG (W)", "long_", "Long_", "long_dd", "longitude", "Longitude", "LONGITUDE", "Longitude - Min", "Longitude - Sec", "Longitude (dd.ddd) E", "LONGITUDE (DD)", "Longitude (deg E)", "Longitude (E)", "longitude (E+)", "Longitude [degrees_east]", "longitude_dd", "Longitude_ddeg", "Longitude_deg", "longitude_degree", "Longitude_degrees_east", "longitude_minute", "Longitude_W", "Longitude_west", "longitude_WGS84", "Longitude- Deg (W)", "longitude..degrees_east.", "Longitude(West)")

# 3389 occurrances
longitude_counts <- unique_nonAnnotated_attNames %>% 
  filter(attributeName %in% longitude_attNames) %>% 
  count(wt = n)

# 818 unique datapackage identifiers
longitude_ids <- nonannotated_attributes %>% 
  filter(attributeName %in% longitude_attNames)

length(unique(longitude_ids$identifier))

###############################
# b) determine appropriate valueURIs -
##############################

#--------------------longitude coordinate: "http://purl.dataone.org/odo/ECSO_00002132"--------------------
longitude_coordinate <- longitude_ids %>% 
  filter(attributeName %in% c("lon", "Lon", "LON", "lon_bnds", "Lon(East)", "Longitude", "long", "Long", "LONG", "Long (DD)", "LONG (W)", "long_", "Long_", "long_dd", "longitude", "Longitude", "LONGITUDE", "Longitude (dd.ddd) E", "LONGITUDE (DD)", "Longitude (deg E)", "Longitude (E)", "longitude (E+)", "Longitude [degrees_east]", "longitude_dd", "Longitude_ddeg", "Longitude_deg", "Longitude_degrees_east", "Longitude_W", "Longitude_west", "longitude_WGS84", "longitude..degrees_east.", "Longitude(West)")) %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00002132"))

#--------------------longitude degree component: "http://purl.dataone.org/odo/ECSO_00002239"--------------------
longitude_degree <- longitude_ids %>% 
  filter(attributeName %in% c("longitude_degree", "Longitude- Deg (W)")) %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00002239"))

#--------------------longitude minute component: "http://purl.dataone.org/odo/ECSO_00002151"--------------------
longitude_minute <- longitude_ids %>% 
  filter(attributeName %in% c("Longitude - Min", "longitude_minute")) %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00002151"))

#--------------------longitude second component: "http://purl.dataone.org/odo/ECSO_00002250"--------------------
longitude_second <- longitude_ids %>% 
  filter(attributeName == "Longitude - Sec") %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00002250"))

##############################
# c) combine longitude dfs
##############################

longitude_annotations <- rbind(longitude_coordinate, longitude_degree, longitude_minute, longitude_second)

##########################################################################################################################
# combine lat long annotations
##########################################################################################################################
lat_long_annotations <- rbind(latitude_annotations, longitude_annotations)

# check for duplicates
double_check <- lat_long_annotations %>% 
  select(-assigned_valueURI)
double_check2 <- get_dupes(double_check)

# get distinct rows
lat_long_annotations <- distinct(lat_long_annotations)

