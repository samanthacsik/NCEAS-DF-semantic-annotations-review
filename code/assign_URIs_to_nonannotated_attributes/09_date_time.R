# title: Identifying attributes to be annotated -- date & time
# author: "Sam Csik"
# date created: "2020-11-13"
# date edited: "2020-11-20"
# R version: 3.6.3
# input: "data/queries/query2020-10-12/fullQuery_semAnnotations2020-10-12_attributes.csv" & "data/queries/query2020-10-12_attributes_from_nonannotated_datapackages/attributes_from_nonannotated_datapackages_tidied.csv"
# output: "data/output/annotate_these_attributes_2020-11-17.csv"

##########################################################################################
# Summary
##########################################################################################

# Identify date and/or time-related attributes in ADC corpus; assign appropriate annotation URI

##############################
# Load packages
##############################

source(here::here("code", "00_libraries.R"))

##############################
# Import data
##############################

source(here::here("code", "09a_list_nonannotated_attributes.R"))

##########################################################################################################################
#--------------------------------------------------Date/Time-------------------------------------------------------------#
##########################################################################################################################

##########################################################################################
# 1) date/time attributeNames 
  # a) identify attributeName variants of 'date and/or time'
  # b) assign appropriate valueURIs -- manually inspected attributeNames, attributeLabels, attributeDefinitions, and downloaded those that needed further investigation
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
# b) determine appropriate valueURIs 
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
  filter(attributeName %in% milliseconds_elapsed) %>% 
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

# check for duplicates
double_check <- dateTime_annotations %>% 
  select(-assigned_valueURI)
double_check2 <- get_dupes(double_check)

# get distinct rows
dateTime_annotations <- distinct(dateTime_annotations)
