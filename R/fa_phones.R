###___________________________________________________________________________
# Scrape the Feeding America /phones endpoint
# must first run the setup.R and source scrape_utils.R
###___________________________________________________________________________

# phones ----

## phones chunk 1 ----
fa_phones_1 <- fa_loop_ingest(
  endpoint = "phones",
  start = 1,
  end = 400,
  size = 100
)

## phones chunk 2 ----
fa_phones_2 <- fa_loop_ingest(
  endpoint = "phones",
  start = 401,
  end = 800,
  size = 100
)

## phones chunk 3 ----
fa_phones_3 <- fa_loop_ingest(
  endpoint = "phones",
  start = 801,
  end = 1200,
  size = 100
)

## phones chunk 4 ----
fa_phones_4 <- fa_loop_ingest(
  endpoint = "phones",
  start = 1201,
  end = 1600,
  size = 100
)

## phones chunk 5 ----
fa_phones_5 <- fa_loop_ingest(
  endpoint = "phones",
  start = 1601,
  end = 2000,
  size = 100
)

## phones chunk 6 ----
fa_phones_6 <- fa_loop_ingest(
  endpoint = "phones",
  start = 2001,
  end = 2400,
  size = 100
)

## phones chunk 7 ----
fa_phones_7 <- fa_loop_ingest(
  endpoint = "phones",
  start = 2401,
  end = 2800,
  size = 100
)

## phones chunk 8 ----
fa_phones_8 <- fa_loop_ingest(
  endpoint = "phones",
  start = 2801,
  end = fa_get_total_pages(endpoint = "phones"),
  size = 100
)

## union phones ----
fa_phones_all <- dplyr::bind_rows(
  fa_phones_1,
  fa_phones_2,
  fa_phones_3,
  fa_phones_4,
  fa_phones_5,
  fa_phones_6,
  fa_phones_7,
  fa_phones_8
)

## get iowa phones
fa_phones_full <- fa_phones_all |> dplyr::filter(state_province == "IA")

### export phones ----
write_csv(
  x = fa_phones_full,
  file = "./out/feeding_america_phones_ia.csv"
)
