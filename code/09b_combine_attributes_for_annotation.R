# title: Identifying attributes to be annotated -- combine attributes to annotate
# author: "Sam Csik"
# date created: "2020-11-13"
# date edited: "2020-11-20"
# R version: 3.6.3
# input: "data/queries/query2020-10-12/fullQuery_semAnnotations2020-10-12_attributes.csv" & "data/queries/query2020-10-12_attributes_from_nonannotated_datapackages/attributes_from_nonannotated_datapackages_tidied.csv"
# output: "data/output/annotate_these_attributes_2020-11-17.csv"

##########################################################################################
# Summary
##########################################################################################


##############################
# Load packages
##############################

source(here::here("code", "00_libraries.R"))

##############################
# Import data
##############################

source(here::here("code", "assign_URIs_to_nonannotated_attributes", "09_latitude_longitude.R"))
source(here::here("code", "assign_URIs_to_nonannotated_attributes", "09_date_time.R"))
source(here::here("code", "assign_URIs_to_nonannotated_attributes", "09_station_site_transect_ids.R"))
source(here::here("code", "assign_URIs_to_nonannotated_attributes", "09_soil_temperature.R"))
source(here::here("code", "assign_URIs_to_nonannotated_attributes", "09_ice_temperatures.R"))
source(here::here("code", "assign_URIs_to_nonannotated_attributes", "09_water_temperatures.R"))
source(here::here("code", "assign_URIs_to_nonannotated_attributes", "09_dissolved_oxygen.R"))
source(here::here("code", "assign_URIs_to_nonannotated_attributes", "09_snow_water_equivalent.R"))
source(here::here("code", "assign_URIs_to_nonannotated_attributes", "09_salinity.R"))
source(here::here("code", "assign_URIs_to_nonannotated_attributes", "09_albedo.R"))
source(here::here("code", "assign_URIs_to_nonannotated_attributes", "09_soil_moisture.R"))
source(here::here("code", "assign_URIs_to_nonannotated_attributes", "09_precipitation.R"))

##########################################################################################################################
#------------------------------------combine all attributes to be annotated----------------------------------------------#
##########################################################################################################################

# geotemporal attributes 
geotemporal_atts <- rbind(latitude_annotations, longitude_annotations, dateTime_annotations, site_station_annotations, transect_annotations)
length(unique(geotemporal_atts$identifier)) # 1119 unique identifiers

# measurement attributes
measurement_atts <- rbind(soil_temp_annotations, ice_temp_annotations, water_temp_annotations, dissolved_oxygen_annotations, 
                  snow_water_equivalent_annotations, salinity_annotations, albedo_annotations, soil_moisture_annotations,
                  precipitation_annotations)
length(unique(measurement_atts$identifier)) # 401 unique identifiers

# all attributes to annotate
annotate_these_attributes <- rbind(geotemporal_atts, measurement_atts)
length(unique(annotate_these_attributes$identifier)) # 1175 unique identifiers (so 345 overlap)

# make sure there aren't duplicates
annotated_these_attributes_DUPLICATES <- get_dupes(annotate_these_attributes)
annotate_these_attributes_DISTINCT <- distinct(annotate_these_attributes)
length(unique(annotate_these_attributes_DISTINCT$identifier)) # 1175 total unique identifiers (datasets)

double_check <- annotate_these_attributes_DISTINCT %>% 
  select(-assigned_valueURI)
double_check2 <- get_dupes(double_check)

# attributes that still have not yet been assigned an annotation URI
not_yet_assignedURI <- nonannotated_attributes %>% 
  anti_join(annotate_these_attributes_DISTINCT)

# only attributes from datapackages that currently have NO annotations
previously_nonannotated <- annotate_these_attributes_DISTINCT %>% 
  filter(status == "dp was never annotated")

# By annotated these attributes, we will add an addtional 1129 data packages that have at least 1 annotated attribute, bringing our total from 185 to __
length(unique(previously_nonannotated$identifier))

# write_csv(annotate_these_attributes, here::here("data", "outputs", "annotate_these_attributes_2020-11-17.csv"))
