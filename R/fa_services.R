###___________________________________________________________________________
# Scrape the Feeding America /services endpoint
# must first run the setup.R and source scrape_utils.R
###___________________________________________________________________________

# utilize parallel processing ----
daemons(5) # <- conservative approach to avoid over throttling

# services ----

## services chunk 1 ----
fa_services_1 <- fa_get_parallel(
  endpoint = "services",
  start = 1,
  end = 400,
  size = 100
)

## services chunk 2 ----
fa_services_2 <- fa_get_parallel(
  endpoint = "services",
  start = 401,
  end = 800,
  size = 100
)

## services chunk 3 ----
fa_services_3 <- fa_get_parallel(
  endpoint = "services",
  start = 801,
  end = 1200,
  size = 100
)

## services chunk 4 ----
fa_services_4 <- fa_get_parallel(
  endpoint = "services",
  start = 1201,
  end = 1600,
  size = 100
)

## services chunk 5 ----
fa_services_5 <- fa_get_parallel(
  endpoint = "services",
  start = 1601,
  end = 2000,
  size = 100
)

## services chunk 6 ----
fa_services_6 <- fa_get_parallel(
  endpoint = "services",
  start = 2001,
  end = 2400,
  size = 100
)

## services chunk 7 ----
fa_services_7 <- fa_get_parallel(
  endpoint = "services",
  start = 2401,
  end = 2800,
  size = 100
)

## services chunk 8 ----
fa_services_8 <- fa_get_parallel(
  endpoint = "services",
  start = 2801,
  end = fa_get_total_pages(endpoint = "services"),
  size = 100
)

# wind down daemons ----
daemons(0)

## union services ----
fa_services_all <- dplyr::bind_rows(
  fa_services_1,
  fa_services_2,
  fa_services_3,
  fa_services_4,
  fa_services_5 |>
    dplyr::mutate(
      assured_date = as.Date(assured_date),
      last_modified = lubridate::ymd_hms(last_modified)
    ),
  fa_services_6 |>
    dplyr::mutate(
      assured_date = as.Date(assured_date),
      last_modified = lubridate::ymd_hms(last_modified)
    ),
  fa_services_7 |>
    dplyr::mutate(
      assured_date = as.Date(assured_date),
      last_modified = lubridate::ymd_hms(last_modified)
    ),
  fa_services_8 |>
    dplyr::mutate(
      assured_date = as.Date(assured_date),
      last_modified = lubridate::ymd_hms(last_modified)
    )
)

### export services ----
write_csv(
  x = fa_services_all,
  file = "./out/feeding_america_services.csv"
)
