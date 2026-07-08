###___________________________________________________________________________
# Web scraping and exporting data
###___________________________________________________________________________

library(httr2)
library(rvest)
library(xml2)
library(janitor)
library(purrr)
library(tibble)
library(dplyr)

source("./R/scrape_utils.R")
source("./R/parsers.R")

urls <- c(
  "https://riverbendfoodbank.org/findfood/",
  "https://foodbankheartland.org/food-resources/find-food/",
  "https://www.neifb.org/find-help/services-in-your-area",
  "https://foodbankiowa.org/find-food/",
  "https://www.fciowa.org/clinichoursdetails",
  "https://freeclinicdirectory.org/iowa_care.html",
  "https://experience.arcgis.com/experience/a6cae906a7964b01af4b56120f4e0670/page/Food-Pantry-Finder?views=Near-Me"
)

# test on one url
result <- urls[1] |> scrape_one()

results <- urls |> purrr::map_df(scrape_one)
print(results)
