###___________________________________________________________________________
# Prepare project - load packages
###___________________________________________________________________________

# install renv
# install.packages("renv")

# initialize renv
# renv::init()

# Install packages if needed
renv::install(c(
  "rvest",
  "httr2",
  "xml2",
  "selectr",
  "janitor",
  "purrr",
  "tibble",
  "dplyr",
  "chromote",
  "readr",
  "mirai",
  "cli"
))

# Set up environment ----

## load needed packages ----
library(httr2)
library(rvest)
library(xml2)
library(janitor)
library(purrr)
library(tibble)
library(dplyr)
library(stringr)
library(chromote)
library(vctrs)
library(readr)
library(mirai)
library(cli)

## source custom functions ----
source("./R/scrape_utils.R")
