# title: Identifying attributes to be annotated -- station, site, transect ids
# author: "Sam Csik"
# date created: "2020-11-13"
# date edited: "2020-11-20"
# R version: 3.6.3
# input: "data/queries/query2020-10-12/fullQuery_semAnnotations2020-10-12_attributes.csv" & "data/queries/query2020-10-12_attributes_from_nonannotated_datapackages/attributes_from_nonannotated_datapackages_tidied.csv"
# output: "data/output/annotate_these_attributes_2020-11-17.csv"

##########################################################################################
# Summary
##########################################################################################

# Identify any station/site/transect-id-related attributes; assign appropriate annotation URIs

##############################
# Load packages
##############################

source(here::here("code", "00_libraries.R"))

##############################
# Import data
##############################

source(here::here("code", "09a_list_nonannotated_attributes.R"))

##########################################################################################################################
#-------------------------------------------------Site/Station-----------------------------------------------------------#
##########################################################################################################################

##########################################################################################
# 1) site attributeNames 
  # a) identify attributeName variants of 'site'
  # b) assign appropriate valueURIs -- manually inspected attributeNames, attributeLabels, attributeDefinitions, and downloaded those that needed further investigation
  # c) combine into single df
##########################################################################################

##############################
# a) identify datapackages that use variants of 'date' and/or 'time'  
##############################

# all site attributeNames
site_attNames <- unique_nonAnnotated_attNames %>% 
  filter(str_detect(attributeName, "(?i)site"),
         attributeName %in% c("abbr_site_name", "full_site_name", "MICROSITE", # other variants of 'microsite' removed after exploration 
                              "Sample Site", "site", "site", "Site", "Site", "SITE", "Site code", "Site ID", "Site name", 
                              "Site Name", "Site Number", "site_id", "Site_ID", "Site_ID_Alt2", "Site_ID_AOV", "Site_ID_Alt1", 
                              "Site_ID_BAID", "site_name", "Site_Name", "Site_Name_IDs", "Site.Code", "Site.ID", 
                              "Site.name", "Site.Name", "Site.Number", "SideCode", "SiteCode_New", "SiteCodeHistorical", 
                              "SiteID","SiteName", "siteNumber", "Sites"))

# all station attributeNames
station_attNames <- unique_nonAnnotated_attNames %>% 
  filter(str_detect(attributeName, "(?i)station"),
         !attributeName %in% c("C_stationarity", "Decimal Gregorian Days of the station", "Q_stationarity", "Station (GPS)", 
                               "station_sampling_priority", "StationPressure_mbar", "StationType", "T_stationarity"))

# combine
site_station_attNames <- rbind(site_attNames, station_attNames)

# 447 occurrances
site_station_counts <- site_station_attNames %>%
  count(wt = n)

# 182 unique datapackage identifiers
site_station_ids <- nonannotated_attributes %>%
  filter(attributeName %in% site_station_attNames$attributeName)

length(unique(site_station_ids$identifier))

###############################
# b) determine appropriate valueURIs 
##############################

#--------------------site identifier: "http://purl.dataone.org/odo/ECSO_00002997"--------------------
site_identifier <- site_station_ids %>% 
  filter(attributeName %in%  c("abbr_site_name", "full_site_name", "MICROSITE", "Sample Site", 
                               "site", "site", "Site", "Site", "SITE", "Site code", "Site ID", "Site name",
                               "Site Name", "Site Number", "site_id", "Site_ID", 
                               "Site_ID_Alt2", "Site_ID_AOV", "Site_ID_Alt1", 
                               "Site_ID_BAID", "site_name", "Site_Name", "Site_Name_IDs", "Site.Code", "Site.ID", 
                               "Site.name", "Site.Name", "Site.Number", "SideCode", "SiteCode_New", "SiteCodeHistorical", 
                               "SiteID","SiteName", "siteNumber", "Sites")) %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00002997"))


#--------------------station identifier: "http://purl.dataone.org/odo/ECSO_00002393"--------------------
station_identifier <- site_station_ids %>% 
  filter(attributeName %in% c("CTD_station_number", "DBO_station", "DBO_Station", "DBO_StationName", "DBOstation", 
                              "HistStationNme", "Kolyma Station ID", "Kolyma_Station_ID", "name_station", "Radar station",
                              "station", "Station", "Station #", "Station Name", "Station Number", "station_name",
                              "Station_name", "Station_Name", "station_num", "Station_Short", "STATION_SHORT", "Station.Name",
                              "StationName", "StationNme", "StationNum", "WeatherStationName-Identifier", "WX Station")) %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00002393"))

##############################
# c) combine site/station dfs
##############################

site_station_annotations <- rbind(site_identifier, station_identifier)

##########################################################################################################################
#---------------------------------------------------Transect-------------------------------------------------------------#
##########################################################################################################################

##########################################################################################
# 2) site attributeNames 
  # a) identify attributeName variants of 'transect'
  # b) assign appropriate valueURIs -- manually inspected attributeNames, attributeLabels, attributeDefinitions, and downloaded those that needed further investigation
  # c) combine into single df
##########################################################################################

##############################
# a) identify datapackages that use variants of 'transect'
##############################

# all site attributeNames (filtered out those that were not correct)
transect_attNames <- unique_nonAnnotated_attNames %>% 
  filter(str_detect(attributeName, "(?i)transect"),
         !attributeName %in% c("DISTANCE FROM TRANSECT", "distance_along_transect"))

# 88 occurrances
transect_counts <- transect_attNames %>%
  count(wt = n)

# 18 unique datapackage identifiers
transect_ids <- nonannotated_attributes %>%
  filter(attributeName %in% transect_attNames$attributeName)

length(unique(transect_ids$identifier))

###############################
# b) determine appropriate valueURIs
##############################

#--------------------transect identifier: "http://purl.dataone.org/odo/ECSO_00002213"--------------------
transect_annotations <- transect_ids %>% 
  filter(attributeName %in% transect_attNames$attributeName) %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00002213"))

##############################
# c) combine site, station, transect dfs 
##############################

# combine all annotations
site_station_transect_annotations <- rbind(site_station_annotations, transect_annotations)

# check for duplicates
double_check <- site_station_transect_annotations %>% 
  select(-assigned_valueURI)
double_check2 <- get_dupes(double_check)

# get distinct rows
site_station_transect_annotations <- distinct(site_station_transect_annotations)
