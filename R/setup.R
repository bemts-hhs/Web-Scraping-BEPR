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
  "dplyr"
))
