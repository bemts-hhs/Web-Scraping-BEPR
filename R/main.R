###___________________________________________________________________________
# Web scraping and exporting data ----
###___________________________________________________________________________

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

## source custom functions ----
source("./R/scrape_utils.R")

## read in URLs ----
urls <- c(
  "https://riverbendfoodbank.org/findfood/",
  "https://foodbankheartland.org/food-resources/find-food/",
  "https://www.neifb.org/find-help/services-in-your-area",
  "https://foodbankiowa.org/find-food/",
  "https://www.fciowa.org/clinichoursdetails",
  "https://freeclinicdirectory.org/iowa_care.html",
  "https://experience.arcgis.com/experience/a6cae906a7964b01af4b56120f4e0670/page/Food-Pantry-Finder?views=Near-Me"
)

# get the heartland food bank data ----
heartland_foodbank <- heartland_full_scrape(
  url = urls[2],
  address_col = address
)

## write the rectangular data to .csv
readr::write_csv(x = heartland_foodbank, file = "./out/heartland_foodbank.csv")
