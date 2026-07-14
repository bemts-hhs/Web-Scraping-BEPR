###___________________________________________________________________________
# Scrape the Feeding America /languages endpoint
# must first run the setup.R and source scrape_utils.R
###___________________________________________________________________________

# utilize parallel processing ----
daemons(5) # <- conservative approach to avoid over throttling

# languages ----

## languages chunk 1 ----
fa_languages <- fa_get_parallel(
  endpoint = "languages",
  start = 1,
  end = fa_get_total_pages(endpoint = "languages"),
  size = 100
)

# wind down daemons ----
daemons(0)

### export languages ----
write_csv(
  x = fa_languages,
  file = "./out/feeding_america_languages.csv"
)
