# title: Identifying attributes to be annotated -- dissolved oxygen
# author: "Sam Csik"
# date created: "2020-11-13"
# date edited: "2020-11-20"
# R version: 3.6.3
# input: "data/queries/query2020-10-12/fullQuery_semAnnotations2020-10-12_attributes.csv" & "data/queries/query2020-10-12_attributes_from_nonannotated_datapackages/attributes_from_nonannotated_datapackages_tidied.csv"
# output: "data/output/annotate_these_attributes_2020-11-17.csv"

##########################################################################################
# Summary
##########################################################################################

# Identify dissolved oxygen-related attributes in ADC corpus; assign appropriate annotation URI

##############################
# Load packages
##############################

source(here::here("code", "00_libraries.R"))

##############################
# Import data
##############################

source(here::here("code", "09a_list_nonannotated_attributes.R"))

##########################################################################################################################
#-----------------------------------------------dissolved oxygen--------------------------------------------------------#
##########################################################################################################################

##########################################################################################
# 1) dissolved oxygen attributeNames 
  # a) identify attributeName variants of 'dissolved oxygen'
  # b) assign appropriate valueURIs -- manually inspected attributeNames, attributeLabels, attributeDefinitions, and downloaded those that needed further investigation
  # c) combine into single df
##########################################################################################

##############################
# a) identify datapackages that use variants of 'dissolved oxygen'  
##############################

DO_attNames <- nonannotated_attributes %>% 
  filter(str_detect(attributeDefinition, "(?i)dissolved oxygen"))

OS_attNames <- nonannotated_attributes %>% 
  filter(str_detect(attributeDefinition, "(?i)oxygen saturation"))

OC_attNames <- nonannotated_attributes %>% 
  filter(str_detect(attributeDefinition, "(?i)oxygen concentration"))

recorded_oxygen <- nonannotated_attributes %>% 
  filter(str_detect(attributeDefinition, "(?i)recorded oxygen"))

oxygen <- nonannotated_attributes %>% 
  filter(attributeName %in% c("Oxygen", "oxygen"))

# combine all of the above and make sure we're only looking at distinct rows
all_oxygen_related_attNames <- rbind(DO_attNames, OS_attNames, OC_attNames, recorded_oxygen, oxygen)
distinct_oxygen_related_attNames <- distinct(all_oxygen_related_attNames)

###############################
# b) determine appropriate valueURIs 
##############################

#--------------------dissolved oxygen concentration: "http://purl.dataone.org/odo/ECSO_00001669"--------------------
dissolved_oxygen_conc <- distinct_oxygen_related_attNames %>% 
  filter(attributeName %in% c("sbeox0Mm/kg", "dissolved_oxygen", "DO (mg/L)", "O2.µmol/L", "O2calc_µmol_kg", "O2", "DO Concentration (mg/L)", 
                              "DO_milligramPerLiter", "DO_mg.L", "CTD O2", "DO_mg/L", "O2 (umol/kg)", "sbeox0ML/L", "xmiss",
                              "Dissolved Oxygen", "OXYG", "OXYG2", "DO", "Oxygen") | # going off units for these
         str_detect(attributeDefinition, "Concentration of dissolved oxygen at top of OsmoSampler") |
         str_detect(attributeDefinition, "Recorded dissolved oxygen in milligrams per liter") |
         attributeDefinition == "Oxygen concentration (CTD sensor)") %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00001669"))

#--------------------oxygen saturation percentage: "http://purl.dataone.org/odo/ECSO_00001668"--------------------
perc_O2_sat <- distinct_oxygen_related_attNames %>% 
  filter(attributeName %in% c("pDO", "DO_%sat", "Dissolved Oxygen (percent)", "DO_percent", "Dissolved Oxygen (%)", "DO (%)")) %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00001668"))

#--------------------dissolved oxygen saturation: "http://purl.dataone.org/odo/ECSO_00002386"--------------------
DO_sat <- distinct_oxygen_related_attNames %>% 
  filter(attributeName %in% c("oxsolMm/kg", "sbeox0PS", "dissolved_oxygen_saturation", "O2Sat_µmol/kg", "O2sat")) %>% 
  mutate(assigned_valueURI = rep("http://purl.dataone.org/odo/ECSO_00002386"))

#--------------------do not consider--------------------
# do_not_consider <- distinct_oxygen_related_attNames %>% 
#   filter(attributeUnit %in% c("volt") | attributeName %in% c("D17", "d17O", "d18O", "Date_DO", "O2 flag", "Sat_ratio")) %>% 
#   mutate(assigned_valueURI = rep("do not consider"))

# check-in to make sure all terms are accouted for
# accounted_for <- rbind(dissolved_oxygen_conc, perc_O2_sat, DO_sat, do_not_consider)
# remaining <- distinct_oxygen_related_attNames %>% 
#   anti_join(accounted_for)

##############################
# c) combine DO dfs
##############################

dissolved_oxygen_annotations <- rbind(dissolved_oxygen_conc, perc_O2_sat, DO_sat)

# check for duplicates
double_check <- dissolved_oxygen_annotations %>% 
  select(-assigned_valueURI)
double_check2 <- get_dupes(double_check)

# get distinct rows
dissolved_oxygen_annotations <- distinct(dissolved_oxygen_annotations)

