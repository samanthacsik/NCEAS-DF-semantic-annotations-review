# title: datapack testing
# author: "Sam Csik"
# date created: "2020-12-21"
# date edited: "2020-12-21"
# R version: 3.6.3
# input: "data/outputs/annotate_these_attributes_2020-12-17.csv"
# output: 

##########################################################################################
# Summary
##########################################################################################

##########################################################################################
# General Setup
##########################################################################################

# load packages
library(dataone)
library(datapack)
library(arcticdatautils)
library(uuid)
library(tidyverse)

# import data
attributes <- read_csv(here::here("data", "outputs", "annotate_these_attributes_2020-12-17.csv"))

