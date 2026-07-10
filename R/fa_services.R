###___________________________________________________________________________
# Scrape the Feeding America /services endpoint
# must first run the setup.R and source scrape_utils.R
###___________________________________________________________________________

# services ----

## services chunk 1 ----
fa_services_1 <- fa_loop_ingest(
  endpoint = "services",
  start = 1,
  end = 400,
  size = 100
)

## services chunk 2 ----
fa_services_2 <- fa_loop_ingest(
  endpoint = "services",
  start = 401,
  end = 800,
  size = 100
)

## services chunk 3 ----
fa_services_3 <- fa_loop_ingest(
  endpoint = "services",
  start = 801,
  end = 1200,
  size = 100
)

## services chunk 4 ----
fa_services_4 <- fa_loop_ingest(
  endpoint = "services",
  start = 1201,
  end = 1600,
  size = 100
)

## services chunk 5 ----
fa_services_5 <- fa_loop_ingest(
  endpoint = "services",
  start = 1601,
  end = 2000,
  size = 100
)

## services chunk 6 ----
fa_services_6 <- fa_loop_ingest(
  endpoint = "services",
  start = 2001,
  end = 2400,
  size = 100
)

## services chunk 7 ----
fa_services_7 <- fa_loop_ingest(
  endpoint = "services",
  start = 2401,
  end = 2800,
  size = 100
)

## services chunk 8 ----
fa_services_8 <- fa_loop_ingest(
  endpoint = "services",
  start = 2801,
  end = fa_get_total_pages(endpoint = "services"),
  size = 100
)

## union services ----
fa_services_all <- dplyr::bind_rows(
  fa_services_1,
  fa_services_2,
  fa_services_3,
  fa_services_4,
  fa_services_5,
  fa_services_6,
  fa_services_7,
  fa_services_8
)

## get iowa services
fa_services_full <- fa_services_all |> dplyr::filter(state_province == "IA")

### export services ----
write_csv(
  x = fa_services_full,
  file = "./out/feeding_america_services_ia.csv"
)
