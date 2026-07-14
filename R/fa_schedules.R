###___________________________________________________________________________
# Scrape the Feeding America /schedules endpoint
# must first run the setup.R and source scrape_utils.R
###___________________________________________________________________________

# utilize parallel processing ----
daemons(5) # <- conservative approach to avoid over throttling

# schedules ----

## schedules chunk 1 ----
fa_schedules <- fa_get_parallel(
  endpoint = "schedules",
  start = 1,
  end = fa_get_total_pages(endpoint = "schedules"),
  size = 100
)

# wind down daemons ----
daemons(0)

### export schedules ----
write_csv(
  x = fa_schedules,
  file = "./out/feeding_america_schedules.csv"
)
