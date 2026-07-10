###___________________________________________________________________________
# Scrape the Feeding America /addresses endpoint
# must first run the setup.R and source scrape_utils.R
###___________________________________________________________________________

# addresses ----

## addresses chunk 1 ----
fa_addresses_1 <- fa_loop_ingest(
  endpoint = "addresses",
  start = 1,
  end = 400,
  size = 100
)

## addresses chunk 2 ----
fa_addresses_2 <- fa_loop_ingest(
  endpoint = "addresses",
  start = 401,
  end = 800,
  size = 100
)

## addresses chunk 3 ----
fa_addresses_3 <- fa_loop_ingest(
  endpoint = "addresses",
  start = 801,
  end = 1200,
  size = 100
)

## addresses chunk 4 ----
fa_addresses_4 <- fa_loop_ingest(
  endpoint = "addresses",
  start = 1201,
  end = 1600,
  size = 100
)

## addresses chunk 5 ----
fa_addresses_5 <- fa_loop_ingest(
  endpoint = "addresses",
  start = 1601,
  end = 2000,
  size = 100
)

## addresses chunk 6 ----
fa_addresses_6 <- fa_loop_ingest(
  endpoint = "addresses",
  start = 2001,
  end = 2400,
  size = 100
)

## addresses chunk 7 ----
fa_addresses_7 <- fa_loop_ingest(
  endpoint = "addresses",
  start = 2401,
  end = 2800,
  size = 100
)

## addresses chunk 8 ----
fa_addresses_8 <- fa_loop_ingest(
  endpoint = "addresses",
  start = 2801,
  end = fa_get_total_pages(endpoint = "addresses"),
  size = 100
)

## union addresses ----
fa_addresses_all <- dplyr::bind_rows(
  fa_addresses_1,
  fa_addresses_2,
  fa_addresses_3,
  fa_addresses_4,
  fa_addresses_5,
  fa_addresses_6,
  fa_addresses_7,
  fa_addresses_8
)

## get iowa addresses
fa_addresses_full <- fa_addresses_all |> dplyr::filter(state_province == "IA")

### export addresses ----
write_csv(
  x = fa_addresses_full,
  file = "./out/feeding_america_addresses_ia.csv"
)
