###___________________________________________________________________________
# Scrape the Feeding America /service_at_location endpoint
# must first run the setup.R and source scrape_utils.R
###___________________________________________________________________________

# service_at_location ----

## service_at_location chunk 1 ----
fa_service_at_location_1 <- fa_loop_ingest(
  endpoint = "service_at_location",
  start = 1,
  end = 400,
  size = 100
)

## service_at_location chunk 2 ----
fa_service_at_location_2 <- fa_loop_ingest(
  endpoint = "service_at_location",
  start = 401,
  end = 800,
  size = 100
)

## service_at_location chunk 3 ----
fa_service_at_location_3 <- fa_loop_ingest(
  endpoint = "service_at_location",
  start = 801,
  end = 1200,
  size = 100
)

## service_at_location chunk 4 ----
fa_service_at_location_4 <- fa_loop_ingest(
  endpoint = "service_at_location",
  start = 1201,
  end = 1600,
  size = 100
)

## service_at_location chunk 5 ----
fa_service_at_location_5 <- fa_loop_ingest(
  endpoint = "service_at_location",
  start = 1601,
  end = 2000,
  size = 100
)

## service_at_location chunk 6 ----
fa_service_at_location_6 <- fa_loop_ingest(
  endpoint = "service_at_location",
  start = 2001,
  end = 2400,
  size = 100
)

## service_at_location chunk 7 ----
fa_service_at_location_7 <- fa_loop_ingest(
  endpoint = "service_at_location",
  start = 2401,
  end = 2800,
  size = 100
)

## service_at_location chunk 8 ----
fa_service_at_location_8 <- fa_loop_ingest(
  endpoint = "service_at_location",
  start = 2801,
  end = fa_get_total_pages(endpoint = "service_at_location"),
  size = 100
)

## union service_at_location ----
fa_service_at_location_all <- dplyr::bind_rows(
  fa_service_at_location_1,
  fa_service_at_location_2,
  fa_service_at_location_3,
  fa_service_at_location_4,
  fa_service_at_location_5,
  fa_service_at_location_6,
  fa_service_at_location_7,
  fa_service_at_location_8
)

## get iowa service_at_location
fa_service_at_location_full <- fa_service_at_location_all |>
  dplyr::filter(state_province == "IA")

### export service_at_location ----
write_csv(
  x = fa_service_at_location_full,
  file = "./out/feeding_america_service_at_location_ia.csv"
)
