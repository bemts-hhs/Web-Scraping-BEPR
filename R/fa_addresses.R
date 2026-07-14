###___________________________________________________________________________
# Scrape the Feeding America /addresses endpoint
# must first run the setup.R and source scrape_utils.R
###___________________________________________________________________________

# utilize parallel processing ----
daemons(5) # <- conservative approach to avoid over throttling

# addresses ----

## addresses chunk 1 ----
fa_addresses_1 <- fa_get_parallel(
  endpoint = "addresses",
  start = 1,
  end = 400,
  size = 100
)

## addresses chunk 2 ----
fa_addresses_2 <- fa_get_parallel(
  endpoint = "addresses",
  start = 401,
  end = 800,
  size = 100
)

## addresses chunk 3 ----
fa_addresses_3 <- fa_get_parallel(
  endpoint = "addresses",
  start = 801,
  end = 1200,
  size = 100
)

## addresses chunk 4 ----
fa_addresses_4 <- fa_get_parallel(
  endpoint = "addresses",
  start = 1201,
  end = 1600,
  size = 100
)

## addresses chunk 5 ----
fa_addresses_5 <- fa_get_parallel(
  endpoint = "addresses",
  start = 1601,
  end = 2000,
  size = 100
)

## addresses chunk 6 ----
fa_addresses_6 <- fa_get_parallel(
  endpoint = "addresses",
  start = 2001,
  end = 2400,
  size = 100
)

## addresses chunk 7 ----
fa_addresses_7 <- fa_get_parallel(
  endpoint = "addresses",
  start = 2401,
  end = 2800,
  size = 100
)

## addresses chunk 8 ----
fa_addresses_8 <- fa_get_parallel(
  endpoint = "addresses",
  start = 2801,
  end = fa_get_total_pages(endpoint = "addresses"),
  size = 100
)

# wind down daemons ----
daemons(0)

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

### export addresses ----
write_csv(
  x = fa_addresses_all,
  file = "./out/feeding_america_addresses.csv"
)
