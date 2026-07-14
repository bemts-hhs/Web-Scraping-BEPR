###___________________________________________________________________________
# Scrape the Feeding America /phones endpoint
# must first run the setup.R and source scrape_utils.R
###___________________________________________________________________________

# utilize parallel processing ----
daemons(5) # <- conservative approach to avoid over throttling

# phones ----

## phones chunk 1 ----
fa_phones_1 <- fa_get_parallel(
  endpoint = "phones",
  start = 1,
  end = 400,
  size = 100
)

## phones chunk 2 ----
fa_phones_2 <- fa_get_parallel(
  endpoint = "phones",
  start = 401,
  end = 800,
  size = 100
)

## phones chunk 3 ----
fa_phones_3 <- fa_get_parallel(
  endpoint = "phones",
  start = 801,
  end = 1200,
  size = 100
)

## phones chunk 4 ----
fa_phones_4 <- fa_get_parallel(
  endpoint = "phones",
  start = 1201,
  end = fa_get_total_pages(endpoint = "phones"),
  size = 100
)

# wind down daemons ----
daemons(0)

## union phones ----
fa_phones_all <- dplyr::bind_rows(
  fa_phones_1,
  fa_phones_2,
  fa_phones_3,
  fa_phones_4
)

### export phones ----
write_csv(
  x = fa_phones_all,
  file = "./out/feeding_america_phones.csv"
)
