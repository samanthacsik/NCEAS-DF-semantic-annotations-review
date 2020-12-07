# title: Identifying attributes to be annotated -- salinity
# author: "Sam Csik"
# date created: "2020-11-24"
# date edited: "2020-11-24"
# R version: 3.6.3
# input: "data/queries/query2020-10-12/fullQuery_semAnnotations2020-10-12_attributes.csv" & "data/queries/query2020-10-12_attributes_from_nonannotated_datapackages/attributes_from_nonannotated_datapackages_tidied.csv"
# output: "data/output/annotate_these_attributes_2020-11-17.csv"

##########################################################################################
# Summary
##########################################################################################

# Identify all salinity-related attributes; assign appropriate annotation URIs

##############################
# Load packages
##############################

source(here::here("code", "00_libraries.R"))

##############################
# Import data
##############################

source(here::here("code", "09a_list_nonannotated_attributes.R"))

##########################################################################################################################
#----------------------------------------------------salinity------------------------------------------------------------#
##########################################################################################################################

##########################################################################################
# 1) salinity attributeNames 
  # a) identifiy attributeName variants of 'salinity'
  # b) assign appropriate valueURIs -- manually inspected attributeNames, attributeLabels, attributeDefinitions, and downloaded those that needed further investigation
  # c) combine into single df
##########################################################################################

##############################
# a) identify datapackages that use variants of 'salinity'  
##############################

# coarse filter
general_salinity <- nonannotated_attributes %>% 
  filter(str_detect(attributeDefinition, "(?i)salinity") |
         str_detect(attributeName, "(?i)salinity") |
         str_detect(attributeLabel, "(?i)salinity"))

###############################
# b) determine appropriate valueURIs 
##############################

#--------------------calibrated water salinity: "http://purl.dataone.org/odo/ECSO_00001655"--------------------
cal_water_sal <- general_salinity %>% 
  filter(attributeDefinition %in% c("calibrated primary salinity")) %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00001655"))

#--------------------salinity uncertainty: "http://purl.dataone.org/odo/ECSO_00001656"--------------------
sal_uncertainty <- general_salinity %>% 
  filter(attributeName %in% c("Salinity_unc")) %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00001656"))

#--------------------sea surface salinity: "http://purl.dataone.org/odo/ECSO_00001658"--------------------
sss <- general_salinity %>% 
  filter(attributeName %in% c("SSS", "Surface salinity") |
         attributeDefinition %in% c("Surface salinity")) %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00001658")) 

#--------------------computed salinity: ""--------------------
# NOTE: other 'salinity' attributes in in https://search.dataone.org/view/https://pasta.lternet.edu/package/metadata/eml/knb-lter-ble/3/1 that should probably be computed salinity and not water salinity
computed_salinity <- general_salinity %>% 
  filter(attributeName %in% c("Computed_salinity") |
         entityName %in% c("Water column physiochemistry data (YSI), 2018-ongoing") |
         identifier %in% c("doi:10.18739/A2K806", "doi:10.18739/A2K806", "doi:10.18739/A2XS5JH16", "doi:10.18739/A29R5F", "doi:10.18739/A2CN6Z06W")) %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00001659"))

#--------------------do not consider--------------------
quality_flag <- general_salinity %>% 
  filter(str_detect(attributeDefinition, "(?i)quality flag")|
         attributeLabel %in% c("Salinity Quality Control Flag") |
         attributeName %in% c("flags_condsal")) %>% 
  mutate(assigned_valueURI = rep("do not consider"))

change_in_sal <- general_salinity %>% 
  filter(str_detect(attributeDefinition, "^Change in salinity*")) %>% 
  mutate(assigned_valueURI = rep("do not consider"))

o2_sat <- general_salinity %>% 
  filter(str_detect(attributeDefinition, "^oxygen saturation concentration*") |
         attributeName %in% c("corr O2Ar")) %>% 
  mutate(assigned_valueURI = rep("do not consider"))

random <- general_salinity %>% 
  filter(attributeLabel %in% c("net community production", "Ω_aragonite", "Ω_calcite") |
         attributeName %in% c("Calculated_brine_density", "Calculated_brine_salinity", "Temperature at Salinity Sensor", "Temperature at Salinity Sensor (C)",
                              "TSG_S_sm", "TSG_Teq_sm")) %>% 
  mutate(assigned_valueURI = rep("do not consider"))

#--------------------water salinity: "http://purl.dataone.org/odo/ECSO_00001164"--------------------
# all remaining fall under 'water salinity'
accounted_for <- rbind(cal_water_sal, sal_uncertainty, sss, computed_salinity, quality_flag, change_in_sal, o2_sat, random)
remaining_water_salinity <- general_salinity %>%
  anti_join(accounted_for) %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00001164"))

##############################
# c) combine salinity dfs
##############################

salinity_annotations <- rbind(cal_water_sal, sal_uncertainty, sss, computed_salinity, remaining_water_salinity)

# check for duplicates
double_check <- salinity_annotations %>% 
  select(-assigned_valueURI)
double_check2 <- get_dupes(double_check)

# get distinct rows
salinity_annotations <- distinct(salinity_annotations)
