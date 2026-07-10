###___________________________________________________________________________
# Scrape the Feeding America /languages endpoint
# must first run the setup.R and source scrape_utils.R
###___________________________________________________________________________

# languages ----

## languages chunk 1 ----
fa_languages_1 <- fa_loop_ingest(
  endpoint = "languages",
  start = 1,
  end = 400,
  size = 100
)

## languages chunk 2 ----
fa_languages_2 <- fa_loop_ingest(
  endpoint = "languages",
  start = 401,
  end = 800,
  size = 100
)

## languages chunk 3 ----
fa_languages_3 <- fa_loop_ingest(
  endpoint = "languages",
  start = 801,
  end = 1200,
  size = 100
)

## languages chunk 4 ----
fa_languages_4 <- fa_loop_ingest(
  endpoint = "languages",
  start = 1201,
  end = 1600,
  size = 100
)

## languages chunk 5 ----
fa_languages_5 <- fa_loop_ingest(
  endpoint = "languages",
  start = 1601,
  end = 2000,
  size = 100
)

## languages chunk 6 ----
fa_languages_6 <- fa_loop_ingest(
  endpoint = "languages",
  start = 2001,
  end = 2400,
  size = 100
)

## languages chunk 7 ----
fa_languages_7 <- fa_loop_ingest(
  endpoint = "languages",
  start = 2401,
  end = 2800,
  size = 100
)

## languages chunk 8 ----
fa_languages_8 <- fa_loop_ingest(
  endpoint = "languages",
  start = 2801,
  end = fa_get_total_pages(endpoint = "languages"),
  size = 100
)

## union languages ----
fa_languages_all <- dplyr::bind_rows(
  fa_languages_1,
  fa_languages_2,
  fa_languages_3,
  fa_languages_4,
  fa_languages_5,
  fa_languages_6,
  fa_languages_7,
  fa_languages_8
)

## get iowa languages
fa_languages_full <- fa_languages_all |> dplyr::filter(state_province == "IA")

### export languages ----
write_csv(
  x = fa_languages_full,
  file = "./out/feeding_america_languages_ia.csv"
)
