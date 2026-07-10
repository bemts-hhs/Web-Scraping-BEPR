###___________________________________________________________________________
# Scrape the Feeding America /schedules endpoint
# must first run the setup.R and source scrape_utils.R
###___________________________________________________________________________

# schedules ----

## schedules chunk 1 ----
fa_schedules_1 <- fa_loop_ingest(
  endpoint = "/hsds/v3/schedules",
  start = 1,
  end = 400,
  size = 100
)

## schedules chunk 2 ----
fa_schedules_2 <- fa_loop_ingest(
  endpoint = "/hsds/v3/schedules",
  start = 401,
  end = 800,
  size = 100
)

## schedules chunk 3 ----
fa_schedules_3 <- fa_loop_ingest(
  endpoint = "/hsds/v3/schedules",
  start = 801,
  end = 1200,
  size = 100
)

## schedules chunk 4 ----
fa_schedules_4 <- fa_loop_ingest(
  endpoint = "/hsds/v3/schedules",
  start = 1201,
  end = 1600,
  size = 100
)

## schedules chunk 5 ----
fa_schedules_5 <- fa_loop_ingest(
  endpoint = "/hsds/v3/schedules",
  start = 1601,
  end = 2000,
  size = 100
)

## schedules chunk 6 ----
fa_schedules_6 <- fa_loop_ingest(
  endpoint = "/hsds/v3/schedules",
  start = 2001,
  end = 2400,
  size = 100
)

## schedules chunk 7 ----
fa_schedules_7 <- fa_loop_ingest(
  endpoint = "/hsds/v3/schedules",
  start = 2401,
  end = 2800,
  size = 100
)

## schedules chunk 8 ----
fa_schedules_8 <- fa_loop_ingest(
  endpoint = "/hsds/v3/schedules",
  start = 2801,
  end = fa_get_total_pages(endpoint = "/hsds/v3/schedules"),
  size = 100
)

## union schedules ----
fa_schedules_all <- dplyr::bind_rows(
  fa_schedules_1,
  fa_schedules_2,
  fa_schedules_3,
  fa_schedules_4,
  fa_schedules_5,
  fa_schedules_6,
  fa_schedules_7,
  fa_schedules_8
)

## get iowa schedules
fa_schedules_full <- fa_schedules_all |> dplyr::filter(state_province == "IA")

### export schedules ----
write_csv(
  x = fa_schedules_full,
  file = "./out/feeding_america_schedules_ia.csv"
)
