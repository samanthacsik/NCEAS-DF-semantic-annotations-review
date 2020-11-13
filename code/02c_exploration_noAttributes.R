# title: Exploring datasets without attribute information
# author: "Sam Csik"
# date created: "2020-11-10"
# date edited: "2020-11-10"
# R version: 3.6.3
# input: "data/queries/query2020-10-12/fullQuery_semAnnotations2020-10-12_labeledACADIS.csv"
# output: 

##########################################################################################
# Summary
##########################################################################################


##########################################################################################
# General setup
##########################################################################################

##############################
# Load packages & custom functions
##############################

source(here::here("code", "00_libraries.R"))
source(here::here("code", "00_functions.R"))

##############################
# Import data
##############################

solr_query <- read_csv(here::here("data", "queries", "query2020-10-12", "fullQuery_semAnnotations2020-10-12_labeledACADIS.csv"))

##########################################################################################
# 1) confirm what we already know from scripts 02a and 02b:
  # a) total number of datapackages should be 6193 (script 02b after full_joining ACADIS ids with solr_query)
  # b) number of datasets with annotations = 1428
##########################################################################################

# a) total number of data packages = 6193
num_total_datapackages <- length(unique(solr_query$identifier))     

# b) total data packages containing attributes = 1428
attributes_only <- solr_query %>% 
  filter(attribute != "NA") 

###########################################################################################
# 2) isolate data packages that do not have attributes listed in their metadata, then remove ACADIS data
##########################################################################################

# all data packages without attributes listed in their metadata
no_attributes <- solr_query %>% 
  anti_join(attributes_only) 

# for RMarkdown - 4765 datapackages with no attributes in metadata
num_datapackages_without_attributes <- length(unique(no_attributes$identifier))

# data packages that do not have attributes and are not ACADIS data; total = 1074
no_attributesOrACADIS <- no_attributes %>% 
  filter(is.na(dataSubset),
         !is.na(title)) # 67 identifiers with no metadata information whatsoever

# data packages that do not have attributes and are not ACADIS data; total = 1074
table5 <- no_attributesOrACADIS %>% 
  select(identifier, author, title, keywords, datePublished, dateUploaded)
# write_csv(no_attributesOrACADIS, here::here("data", "outputs", "no_attributesOrACADIS.csv"))

# for RMarkdown
num_nonACADIS_data_no_attributes <- length(no_attributesOrACADIS$identifier)

###########################################################################################
# 3) identify groupings of datapackages to describe why they don't have attribute information
##########################################################################################

# look at most common authors
most_common_authors <- no_attributesOrACADIS %>%
  group_by(author) %>%
  count(author, sort = T)

# # image data
# image_data <- no_attributesOrACADIS %>% 
#   filter(str_detect(title, "image") |
#          str_detect(keywords, "image"))

#----------- breakdown by author subsets ----------
# (123) acoustic data, noted by Matt Jones 
kathleen_stafford_data <- no_attributesOrACADIS %>%
  filter(author == "Kathleen M Stafford")

ks <- length(kathleen_stafford_data$identifier)

# (129) thaw depth measurements for the CALM project -- all zip files (some contain images and pdfs, others .xls files) 
dmitry_streletskiy_data <- no_attributesOrACADIS %>%
  filter(author == "Dmitry A Streletskiy")

ds <- length(dmitry_streletskiy_data$identifier)

# (29) txt files which could have annotated attributes (NOTE: Igor Polyakov authors 12 additional non-NABOS datasets that are filtered out here) 
igor_polyakov_data <- no_attributesOrACADIS %>% 
  filter(author == "Igor Polyakov",
         str_detect(title, "^NABOS*"),
         str_detect(abstract, "^The primary goal of our mooring observations*"))

ip <- length(igor_polyakov_data$identifier)

# (37) oceanographic and acoustic data contained in .cnv & .mat file formats (filtered for similar datapackages, 39 total)
carolina_nobre_data <- no_attributesOrACADIS %>%
  filter(author == "Carolina Nobre",
         str_detect(abstract, "^This dataset contains oceanographic*"))

# (32) ice sheet data contained mostly .mat, .kml, and .pdf file types, though there are some .csv files as well (haven't looked through them all): 
  # doi:10.18739/A2QR9P (csv)
john_paden_data <- no_attributesOrACADIS %>%
  filter(author == "John Paden")

# (9) moorning data contained in .mat, .dat file types (filtered for similar datapackages, 23 total)
richard_krishfield_data <- no_attributesOrACADIS %>%
  filter(author == "Richard Krishfield",
         str_detect(title, "^Beaufort Gyre*"))

# (16) mostly spatial data but DOES have attribute informaton in metadata which is not showing up in query results
  # doi:10.18739/A2901ZG82
andrey_petrov_data <- no_attributesOrACADIS %>%
  filter(author == "Andrey Petrov",
         str_detect(title, "^Aerial census of reindeer*"))

# (13) ITEX data contained in zip files but DOES have attribute information in metadata which is not showing up in query results
ITEX_data <- no_attributesOrACADIS %>%
  filter(str_detect(abstract, "^The International Tundra Experiment (ITEX)*"))

# (13) CTD data as .pdfs and also contained in zip files (.cnv file types)
leah_mcraven_data <- no_attributesOrACADIS %>% 
  filter(author == "Leah McRaven",
         str_detect(title, "^Distributed Biological*"))

# (5) airglow image data
kim_nielsen_data <- no_attributesOrACADIS %>% 
  filter(author == "Kim Nielsen")

kn <- length(kim_nielsen_data$identifier)

# (9) in-cloud dissipation rates contained in netCDF files
matthew_shupe_data <- no_attributesOrACADIS %>% 
  filter(author == "Matthew Shupe",
         str_detect(title, "^Cloud-scale*"))

 #------------------------------------------------

# datasets without attributes that we can explain
confirmed_no_attributes <- rbind(kathleen_stafford_data, dmitry_streletskiy_data, igor_polyakov_data, 
                                 carolina_nobre_data, john_paden_data, richard_krishfield_data, 
                                 andrey_petrov_data, ITEX_data,  leah_mcraven_data, kim_nielsen_data)

# remove datasets without attributes that we have an explanation for from the others
unexplained_missing_attributes <- no_attributesOrACADIS %>% 
  anti_join(confirmed_no_attributes)

num_unexplained_no_attributes <- length(unexplained_missing_attributes$identifier)

##############################
# isolate data packages that do not have attributes
# NOTE: all dateUploaded = post 2020-01-01
##############################


# active_layer_grid <- no_attributes %>% 
#   filter(str_detect(title, "^Active Layer ARCSS grid"))
# 
# # 24/82 definitely contain photos (zip files), others NEED  CLOSER LOOK
# sergio_vargas_zesati_data <- no_attributes %>% 
#   filter(author == "Sergio Vargas-Zesati")
# 
# matthew_sturm_data <- no_attributes %>%
#   filter(author == "Matthew Sturm")
# 

# 
# # NEEDS CLOSER LOOK
# andreas_muenchow_data <- no_attributes %>%
#   filter(author == "Andreas Muenchow")
# 
# # NEEDS CLOSER LOOK - at least some have .xls files with data
# steven_oberbauer_data <- no_attributes %>% 
#   filter(author == "Steven F. Oberbauer")
#---------------------------------------------

# # datasets without attributes that we can explain
# confirmed_no_attributes <- rbind(kathleen_stafford_data, kim_neilsen_data)

# remove datasets without attributes that we have an explanation for from the others
no_attributes_unexplained <- no_attributes %>% 
  anti_join(confirmed_no_attributes)
