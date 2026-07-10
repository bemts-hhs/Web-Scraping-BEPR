###___________________________________________________________________________
# Scrape the Feeding America /organizations endpoint
# must first run the setup.R and source scrape_utils.R
###___________________________________________________________________________

# organizations data ----

## organizations chunk 1 ----
fa_organizations_1 <- fa_loop_ingest(
  endpoint = "/hsds/v3/organizations",
  start = 1,
  end = 350,
  size = 100
)

## organizations chunk 2 ----
fa_organizations_2 <- fa_loop_ingest(
  endpoint = "/hsds/v3/organizations",
  start = 351,
  end = 700,
  size = 100
)

## organizations chunk 3 ----
fa_organizations_3 <- fa_loop_ingest(
  endpoint = "/hsds/v3/organizations",
  start = 701,
  end = 1050,
  size = 100
)

## organizations chunk 4 ----
fa_organizations_4 <- fa_loop_ingest(
  endpoint = "/hsds/v3/organizations",
  start = 1051,
  end = 1400,
  size = 100
)

## organizations chunk 5 ----
fa_organizations_5 <- fa_loop_ingest(
  endpoint = "/hsds/v3/organizations",
  start = 1401,
  end = 1750,
  size = 100
)

## organizations chunk 6 ----
fa_organizations_6 <- fa_loop_ingest(
  endpoint = "/hsds/v3/organizations",
  start = 1751,
  end = 2152,
  size = 100
)


### union organizations
fa_organizations_full <- fa_organizations |>
  purrr::discard(is_mirai_error) |>
  purrr::list_rbind()
