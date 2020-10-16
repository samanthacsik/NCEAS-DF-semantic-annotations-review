# title: Packages to source into scripts
# author: "Sam Csik"
# date created: "2020-10-01"
# date edited: "2020-10-01"
# R version: 3.6.3
# input: "NA"
# output: "NA"

##############################
# Load packages
##############################

library(dataone)
library(tidyverse)
library(eatocsv) # NOTE: B.Mecum merged my changes to `extract_ea()` into master on 10/6/2020; if that doesn't work for some reason, re-download at`devtools::install_github("samanthacsik/eatocsv")`
library(svMisc)
library(rvest)
library(xml2)
library(tidytext)

