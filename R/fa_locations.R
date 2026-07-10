###___________________________________________________________________________
# Scrape the Feeding America /locations endpoint
# must first run the setup.R and source scrape_utils.R
###___________________________________________________________________________

# locations ----

## locations chunk 1 ----
fa_locations_1 <- fa_loop_ingest(
  endpoint = "/hsds/v3/locations",
  start = 1,
  end = 400,
  size = 100
)

## locations chunk 2 ----
fa_locations_2 <- fa_loop_ingest(
  endpoint = "/hsds/v3/locations",
  start = 401,
  end = 800,
  size = 100
)

## locations chunk 3 ----
fa_locations_3 <- fa_loop_ingest(
  endpoint = "/hsds/v3/locations",
  start = 801,
  end = 1200,
  size = 100
)

## locations chunk 4 ----
fa_locations_4 <- fa_loop_ingest(
  endpoint = "/hsds/v3/locations",
  start = 1201,
  end = 1600,
  size = 100
)

## locations chunk 5 ----
fa_locations_5 <- fa_loop_ingest(
  endpoint = "/hsds/v3/locations",
  start = 1601,
  end = 2000,
  size = 100
)

## locations chunk 6 ----
fa_locations_6 <- fa_loop_ingest(
  endpoint = "/hsds/v3/locations",
  start = 2001,
  end = 2400,
  size = 100
)

## locations chunk 7 ----
fa_locations_7 <- fa_loop_ingest(
  endpoint = "/hsds/v3/locations",
  start = 2401,
  end = 2800,
  size = 100
)

## locations chunk 8 ----
fa_locations_8 <- fa_loop_ingest(
  endpoint = "/hsds/v3/locations",
  start = 2801,
  end = fa_get_total_pages(endpoint = "/hsds/v3/locations"),
  size = 100
)

## union locations ----
fa_locations_all <- dplyr::bind_rows(
  fa_locations_1,
  fa_locations_2,
  fa_locations_3,
  fa_locations_4,
  fa_locations_5,
  fa_locations_6,
  fa_locations_7,
  fa_locations_8
)

## get iowa locations
fa_locations_full <- fa_locations_all |> dplyr::filter(state_province == "IA")

### export locations ----
write_csv(
  x = fa_locations_full,
  file = "./out/feeding_america_locations_ia.csv"
)
