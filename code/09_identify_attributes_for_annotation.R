# title: Identifying attributes to be annotated
# author: "Sam Csik"
# date created: "2020-11-13"
# date edited: "2020-11-15"
# R version: 3.6.3
# input: "data/queries/query2020-10-12/fullQuery_semAnnotations2020-10-12_attributes.csv" & "data/queries/query2020-10-12_attributes_from_nonannotated_datapackages/attributes_from_nonannotated_datapackages_tidied.csv"
# output: 

##########################################################################################
# Summary
##########################################################################################

# We want to mass annotate attributes that are used widely across the ADC corpus to increase the number of datapackages that have at least one annotation
# Here, we'll extract all the datapackage identifiers that have attributes of the following types:
  # coordinates (latitude, longitude)
  # dates and times
  # site identifiers
  # transect identifiers
# This requires some manual assessments of attributeNames to determine which valueURI they should be assigned to

# IMPORTANT CONSIDERATIONS:
  # `base_time` is used in 104 unique datapackage identifiers to refer to seconds since EPOC (1970-01-01); currently have listed as seconds elapsed (http://purl.dataone.org/odo/ECSO_00002054), but maybe could use it's own annotation?
  # `time_bounds`, `time_bnds`: unclear what these are (no definition) so I haven't yet assigned them a valueURI

##############################
# Load packages
##############################

source(here::here("code", "00_libraries.R"))

##############################
# Import data
##############################

# from datapackages that already have at least one annotation; remove annotated attributes
extracted_attributes_from_annotated_datapackages <- read_csv(here::here("data", "queries", "query2020-10-12", "fullQuery_semAnnotations2020-10-12_attributes.csv")) %>% 
  filter(is.na(valueURI)) %>% 
  mutate(status = rep("dp has at least one annotation"))

# from datapackages that do not yet have any annotations (does NOT include ACADIS data)
extracted_attributes_from_nonAnnotated_datapackages <- read_csv(here::here("data", "queries", "query2020-10-12_attributes_from_nonannotated_datapackages", "attributes_from_nonannotated_datapackages_tidied.csv")) %>% 
  mutate(status = rep("dp was never annotated"))

##########################################################################################
# 1) combine all nonannotated attributes into a single df
##########################################################################################

# combine
nonannotated_attributes <- rbind(extracted_attributes_from_annotated_datapackages, extracted_attributes_from_nonAnnotated_datapackages)

# clean up environment
rm(extracted_attributes_from_annotated_datapackages, extracted_attributes_from_nonAnnotated_datapackages)

# inspect attributeNames
unique_nonAnnotated_attNames <- nonannotated_attributes %>% 
  count(attributeName) %>% 
  arrange(attributeName)

##########################################################################################################################
#---------------------------------------------------latitude-------------------------------------------------------------#
##########################################################################################################################

##########################################################################################
# 2) latitude attributeNames (NOTE: can use modifier to ignore cases, e.g. `filter(str_detect(attributeName, "(?i)transect"))`)
  # a) identifiy attributeName variants of 'latitude'
  # b) assign appropriate valueURIs
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
# b) determine appropriate valueURIs -- manually inspected attributeNames, attributeLabels, attributeDefinitions, and downloaded those that needed further investigation
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
  # a) identifiy attributeName variants of 'longitude'
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
# b) determine appropriate valueURIs -- manually inspected attributeNames, attributeLabels, attributeDefinitions, and downloaded those that needed further investigation
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
#--------------------------------------------------Date/Time-------------------------------------------------------------#
##########################################################################################################################

##########################################################################################
# 3) date/time attributeNames 
  # a) identifiy attributeName variants of 'date and/or time'
  # b) assign appropriate valueURIs
  # c) combine into single df
##########################################################################################

##############################
# a) identify datapackages that use variants of 'date' and/or 'time'  
##############################

# all date attributeNames
date_attNames <- unique_nonAnnotated_attNames %>% 
  filter(str_detect(attributeName, "(?i)date"))

# all time attributeNames
time_attNames <- unique_nonAnnotated_attNames %>% 
  filter(str_detect(attributeName, "(?i)time"))

# combined date/time attributeNames (filtered out attributes that don't belong or uncertain of unit and/or desciption unclear)
dateTime_attNames  <- rbind(date_attNames, time_attNames) %>% 
  distinct(attributeName, n) %>% 
  filter(!attributeName %in% c("Dated Bone", "Dated Material", "Material dated",
                               "material_dated", "Altimeter", "Depth_Avg_centimeters_Avg",
                               "Data Quality Mode (0-good, 1-bad, 2-timeout), no_unit", 
                               "float Avg_CloudFraction[nheights,time]", 
                               "float Avg_IceEffectiveRadius[nheights,time]", 
                               "float Avg_LiqEffectiveRadius[nheights,time]", 
                               "float Avg_Retrieved_IWC[nheights,time]", 
                               "float Avg_Retrieved_LWC[nheights,time]", "ntimes",
                               "Relative_Br(time_corrected)", 
                               "short CloudPhaseMask[nheights,time]", 
                               "short CloudRetrievalMask[nheights,time]",
                               "Whole_summertime_measurements", "daytime",
                               "day_used_for_hatch_date_or_last_date_checked", "Time_Int", "time_of_season",
                               "Time.1", "TIME_bnds", "Time (year)", "qc_time", 
                               "Start flight time (local)", "End flight time (local)")) 


# 7911 occurrances
dateTime_counts <- dateTime_attNames %>%
  count(wt = n)

# 968 unique datapackage identifiers
dateTime_ids <- nonannotated_attributes %>%
  filter(attributeName %in% dateTime_attNames$attributeName)

length(unique(dateTime_ids$identifier))

###############################
# b) determine appropriate valueURIs -- manually inspected attributeNames, attributeLabels, attributeDefinitions, and downloaded those that needed further investigation
##############################

#--------------------date: "http://purl.dataone.org/odo/ECSO_00002051"--------------------
date <- c("Dates_methane", "Dates_methane (YYYY-MM-DD)", "MaximumIceThicknessDate", "%date", "date", "Date", "Date ", "DATE", "Date (mm/dd/yyyy)", "Date Caught", "Date collected", "Date Harvested", "Date sampled", "Date Taken", "Date yyyy-mm-dd", "date_collected", "Date_Collected", "date_measured", "Date_Taken", "Analysis Date", "beg_date","end_date", "End date", "COLLECTION DATE", "COLLECTION_DATE", "DataDate", "Date in", "Date out", "Date of Arrival, Year-Month-Day", "Date of Sensor Reading, Year-Month-Day", "Date received", "Date_1", "date_measured", "Date_ratingcurve", "DATE_UTC", "dateYYMMDD", "db_Date_Collected", "db_Date_Created", "db_Date_Export", "db_Date_Modified", "Filename_StartDate", "Date.Collected", "Date.sampled", "Date/time_monitoringrecord", "dateDrilled", "LoadDate", "ObservationDate", "PDATE", "Report Date", "Sample Date", "Sample_date", "Sample_Date", "Sample.Date", "sampleDate", "Sampling Date Local", "Sampling Date Zulu", "sampling_date", "Set Date", "Site_Photo_Date", "Site_Photo1_Date", "Site_Photo2_Date", "SNOW DEPTH SAMPLE DATE", "spatialDate", "Start date", "start_date", "Stop Date", "temporalDates", "temporalVelDates", "TO_DATE", "UTC_date", "Water Collection Date", "WATER- AND THAW DEPTH SAMPLE DATE", "X2015.date", "X2017.date", "X2018.date")

date_filtered <- dateTime_ids %>% 
  filter(attributeName %in% date) %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00002051"))

#--------------------day of year (syn: Julian day): "http://purl.dataone.org/odo/ECSO_00002058"--------------------
julian_day <- c("timeJ")

julian_day_filtered <- dateTime_ids %>% 
  filter(attributeName %in% julian_day) %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00002058"))

#--------------------day of month: "http://purl.dataone.org/odo/ECSO_00002122"--------------------
day_of_month <- c("date_day")

day_of_month_filtered <- dateTime_ids %>% 
  filter(attributeName %in% day_of_month) %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00002122"))

#--------------------month of year: "http://purl.dataone.org/odo/ECSO_00002047"--------------------
month_of_year <- c("date_mon")

month_of_year_filtered <- dateTime_ids %>% 
  filter(attributeName %in% month_of_year) %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00002047"))

#--------------------year of measurement: "http://purl.dataone.org/odo/ECSO_00002050"--------------------
year_of_measurement <- c("date_yr", "Time_Perio", "to_date")

year_of_measurement_filtered <- dateTime_ids %>% 
  filter(attributeName %in% year_of_measurement) %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00002050"))

#--------------------hour of measurement time: "http://purl.dataone.org/odo/ECSO_00002048"--------------------
hour_of_measurement <- c("date_hr", "Time_UTC_hours", "Time_to_peak(hrs)")

hour_of_measurement_filtered <- dateTime_ids %>% 
  filter(attributeName %in% hour_of_measurement) %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00002048"))

#--------------------minute of measurement time: "http://purl.dataone.org/odo/ECSO_00002069"--------------------
minute_of_measurement <- c("date_min")

minute_of_measurement_filtered <- dateTime_ids %>% 
  filter(attributeName %in% minute_of_measurement) %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00002069"))

#--------------------second of measurement time: "http://purl.dataone.org/odo/ECSO_00002070"--------------------
second_of_measurement <- c("UTCTIMESOD", "gps_time")

second_of_measurement_filtered <- dateTime_ids %>% 
  filter(attributeName %in% second_of_measurement) %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00002070"))

#--------------------date and time of measurement: "http://purl.dataone.org/odo/ECSO_00002043"--------------------
date_and_time <- c("Date and Time", "Date Time", "Date_and_time", "date_time", "Date_time", "date_time_deployed", "Date_Time_Local", "date_time_retrieved", "Date_Time_UTC", "Date_UTC", "Date-time", "date.time", "date.time.1", "Date/Time", "datetime", "Datetime", "DateTime", "datetime_UTC", "Date (UTC)", "time_UTC", "date yyyy-mm-dd hh:mm", "Date_adt", "Date_light", "Date_DO", "Date_pressure", "Date_Temp", "Date_Time", "TimeStamp", "Times", "utc_YYYY.MM.DD_HH.MM_timezone", "UTC_YYYY.MM.DD_HH.MM_timezone", "TIMESTAMP_TS_", "TIMESTAMP_TS_.1", "TIMESTAMP_TS_.2", "timeHHMMSS", "Date.P", "datetime (summer)", "DateTimeHr", "from_date", "FROM_DATE", "Measure Date", "Measurement Local Date/Time (UTC -4)", "recdatetime", "SAMI-CO2_Date_Time", "SAMI-pH_Date_Time", "time_AKDT", "time_ADST", "time_AST", "time_AKST", "Time_AST", "Time_grid", "Soil.date.time", "UTC.DateTime", "time_utc", "time_5day", "satellite_timestamp", "local_YYYY.MM.DD_HH.MM_timezone", "Data and Time", "Data/Time", "Fractional Day Of Year (UTC Time)")
#TIME_UTC taking forever to load

date_and_time_filtered <- dateTime_ids %>% 
  filter(attributeName %in% date_and_time) %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00002043"))

timestamp_unconfirmed <- c("timestamp", "Timestamp", "TIMESTAMP") # these are a mix of dates, times, and date/times

timestamp_unconfirmed_filtered <- dateTime_ids %>% 
  filter(attributeName %in% timestamp_unconfirmed) %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00002043"))

#--------------------time of measurement: "http://purl.dataone.org/odo/ECSO_00002040"--------------------
time_confirmed <- c("pres_time", "Res. Time", "TIME_UTC", "Time.Collected", "time(UTC)", "Time_ratingcurve", "Time_hr_dst", "Time_Local", "Time_of_Sampling", "Time_of_Sampling_GMT", "Time_Start", "Time_End", "UTC_DateTime", "Sampling Time Local", "Sampling Time Zulu", "UTC_time", "Time_GMT", "Time of Sensor Reading, Hour:Minute:Second", "Time of Arrival, Hour:Minute:Second", "Time hh:mm UTC", "Time AKST", "Time (24:00)", "Time (24 hr)", "Local_time", "Hom. Time", "Stop Time", "Core Time", "end_time", "CalCheckTime", "RxCalTimeStamp", "StartTime", "start_time")

time_confirmed_filtered <- dateTime_ids %>% 
  filter(attributeName %in% time_confirmed) %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00002040"))

time_unconfirmed <- c("time", "Time", "TIME")

time_unconfirmed_filtered <- dateTime_ids %>% 
  filter(attributeName %in% time_unconfirmed) %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00002040"))

#--------------------Time Step: "http://purl.dataone.org/odo/ECSO_00001183"-------------------- 
time_step <- c("Deploy Time Range", "Dates")

time_step_filtered <- dateTime_ids %>% 
  filter(attributeName %in% time_step) %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00001183"))

#--------------------elapsed time: "http://purl.dataone.org/odo/ECSO_00002068"-------------------- 
elapsed_time <- c("elapsed time", "trace_time", "delta_time", "double time", "Sample time")

elapsed_time_filtered <- dateTime_ids %>% 
  filter(attributeName %in% elapsed_time) %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00002068"))

#--------------------elapsed time after treatment: "http://purl.dataone.org/odo/ECSO_00002049"-------------------- 
elapsed_time_after_treatment <- c("Sample_time")

elapsed_time_after_treatment_filtered <- dateTime_ids %>% 
  filter(attributeName %in% elapsed_time_after_treatment) %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00002049"))

#--------------------hours elapsed: "http://purl.dataone.org/odo/ECSO_00002067"--------------------
hours_elapsed <- c("elapsed_time_hours", "drilling_time_h", "Delta_Time", "tau_time", "collTime")

hours_elapsed_filtered <- dateTime_ids %>% 
  filter(attributeName %in% hours_elapsed) %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00002067"))

#--------------------minutes elapsed: "http://purl.dataone.org/odo/ECSO_00002238"--------------------
minutes_elapsed <- c("XTIME", "ITIMESTEP")

minutes_elapsed_filtered <- dateTime_ids %>% 
  filter(attributeName %in% minutes_elapsed) %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00002238"))

#--------------------seconds elapsed: "http://purl.dataone.org/odo/ECSO_00002054"--------------------
seconds_elapsed <- c("Elapsed Time Seconds", "elapsed_time_seconds", "timeS", "TwoWayTime", 
                     "travel_time", "double time_offset[time]","ocean_time",
                     "surface_melt_rate_time_since_reset", "surface_runoff_rate_time_since_reset",
                     "tendency_of_ice_mass_due_to_basal_mass_flux_time_since_reset",
                     "tendency_of_ice_mass_due_to_conservation_error_time_since_reset",
                     "tendency_of_ice_mass_due_to_discharge_time_since_reset",
                     "tendency_of_ice_mass_due_to_flow_time_since_reset",
                     "tendency_of_ice_mass_due_to_surface_mass_flux_time_since_reset", 
                     "time_post", "elaspsed time", "int base_time", "surface_accumulation_rate_time_since_reset") 

seconds_elapsed_filtered <- dateTime_ids %>% 
  filter(attributeName %in% seconds_elapsed) %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00002054"))

base_time_associated_values_unconfirmed <- c("base_time", "time_offset", "TimeAvg")

base_time_associated_values_unconfirmed_filtered <- dateTime_ids %>% 
  filter(attributeName %in% base_time_associated_values_unconfirmed) %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00002054"))

#--------------------milliseconds elapsed: "http://purl.dataone.org/odo/ECSO_00002882"--------------------
milliseconds_elapsed <- c("Tr. Time usec")

milliseconds_elapsed_filtered <- dateTime_ids %>% 
  filter(attributeName %in% miliseconds_elapsed) %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00002882"))


#--------------------# SANITY CHECK TO SEE WHICH ATTRIBUTE NAMES HAVE NOT YET BEEN ACCOUTNED FOR--------------------
all <- c(date, julian_day, day_of_month, month_of_year, 
         year_of_measurement, hour_of_measurement, 
         minute_of_measurement, second_of_measurement,
         date_and_time, timestamp_unconfirmed,
         time_confirmed, time_unconfirmed,
         time_step, elapsed_time, elapsed_time_after_treatment, 
         hours_elapsed, minutes_elapsed, 
         seconds_elapsed, milliseconds_elapsed,
         base_time_associated_values_unconfirmed)

remaining_dateTime_attNames <- dateTime_attNames %>% 
  filter(!attributeName %in% all)

##############################
# c) combine dateTime dfs
##############################

dateTime_annotations <- rbind(date_filtered, julian_day_filtered, day_of_month_filtered, month_of_year_filtered, 
                              year_of_measurement_filtered, hour_of_measurement_filtered, 
                              minute_of_measurement_filtered, second_of_measurement_filtered,
                              date_and_time_filtered, timestamp_unconfirmed_filtered,
                              time_confirmed_filtered, time_unconfirmed_filtered, 
                              time_step_filtered, elapsed_time_filtered, elapsed_time_after_treatment_filtered, 
                              hours_elapsed_filtered, minutes_elapsed_filtered, 
                              seconds_elapsed_filtered, milliseconds_elapsed_filtered,
                              base_time_associated_values_unconfirmed_filtered)

##########################################################################################################################
#-------------------------------------------------Site/Station-----------------------------------------------------------#
##########################################################################################################################

##########################################################################################
# 3) site attributeNames 
  # a) identifiy attributeName variants of 'site'
  # b) assign appropriate valueURIs
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

# 451 occurrances
site_station_counts <- site_station_attNames %>%
  count(wt = n)

# 110 unique datapackage identifiers
site_station_ids <- nonannotated_attributes %>%
  filter(attributeName %in% site_station_attNames$attributeName)

length(unique(site_ids$identifier))

###############################
# b) determine appropriate valueURIs -- manually inspected attributeNames, attributeLabels, attributeDefinitions, and downloaded those that needed further investigation
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
# 3) site attributeNames 
  # a) identifiy attributeName variants of 'transect'
  # b) assign appropriate valueURIs
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
# b) determine appropriate valueURIs -- manually inspected attributeNames, attributeLabels, attributeDefinitions, and downloaded those that needed further investigation
##############################

#--------------------transect identifier: "http://purl.dataone.org/odo/ECSO_00002213"--------------------
transect_annotations <- transect_ids %>% 
  filter(attributeName %in% transect_attNames$attributeName) %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00002213"))

##########################################################################################################################
#------------------------------------combine all attributes to be annotated----------------------------------------------#
##########################################################################################################################

# all attributes to annotate
annotate_these_attributes <- rbind(latitude_annotations, longitude_annotations, dateTime_annotations, site_station_annotations, transect_annotations)

# only attributes from datapackages that currently have NO annotations
previously_nonannotated <- annotate_these_attributes %>% 
  filter(status == "dp was never annotated")

# By annotated these attributes, we will bring our total of 185 datapackages with at least one annotated attribute up to 1265.
length(unique(previously_nonannotated$identifier))

# write_csv(annotate_these_attributes, here::here("data", "outputs", "annotate_these_attributes_2020-11-17.csv"))
