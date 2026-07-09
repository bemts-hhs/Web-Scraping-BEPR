###___________________________________________________________________________
# Scraping utility functions ----
###___________________________________________________________________________

# HEARTLAND WEBSITE FUNCTIONS --------------------------------------------

###---------------------------------------------------------------------------
# Function: initial_scrape_heartland()
#
# Purpose:
#   Executes a headless-browser scrape of a Storepoint-based food pantry
#   locator. The function loads the page in a Chromote session, waits for
#   all JavaScript-driven Storepoint rendering to complete, captures the
#   fully rendered HTML, and extracts all .storepoint-location nodes.
#
# Inputs:
#   url : character. The page URL that contains a Storepoint map.
#
# Output:
#   A rectangular tibble containing name, description, address, phone,
#   hours, and tags for each Storepoint location.
#
# Notes:
#   - The function uses Sys.sleep() to allow sufficient JS rendering time.
#   - Chromote sessions are not closed automatically; user handles cleanup.
###---------------------------------------------------------------------------

initial_scrape_heartland <- function(url) {
  # Initialize Chromote headless browser session
  b <- chromote::ChromoteSession$new()

  # Navigate to the Storepoint page
  b$Page$navigate(url)

  # Allow JavaScript to fully inject Storepoint results
  Sys.sleep(10)

  # Retrieve fully rendered HTML as string
  html_rendered <- b$Runtime$evaluate(
    "document.documentElement.outerHTML"
  )$result$value

  # Parse HTML with rvest
  html <- rvest::read_html(html_rendered)

  # Extract all Storepoint location HTML nodes
  locations <- html |> rvest::html_elements(".storepoint-location")

  # Convert each Storepoint location node into a row-level tibble
  df <- locations |>
    purrr::map(function(loc) {
      tibble::tibble(
        name = loc |>
          rvest::html_element(".storepoint-name") |>
          rvest::html_text2(),

        description = loc |>
          rvest::html_element(".storepoint-description") |>
          rvest::html_text2(),

        address = loc |>
          rvest::html_element(".storepoint-address") |>
          rvest::html_text2(),

        phone = loc |>
          rvest::html_element(
            ".storepoint-contact-phone, .storepoint-sidebar-phone"
          ) |>
          rvest::html_text2(),

        hours = loc |>
          rvest::html_elements(".storepoint-popup-hours") |>
          rvest::html_text2() |>
          paste(collapse = "; "),

        tags = loc |>
          rvest::html_elements(".tag-text") |>
          rvest::html_text2() |>
          paste(collapse = ", ")
      )
    }) |>
    purrr::list_rbind()

  # close chromote session
  b$close()

  return(df)
}


###---------------------------------------------------------------------------
# Function: clean_address_components()
#
# Purpose:
#   Standardizes Storepoint address strings into analytic components.
#
# Behavior:
#   - Strips excess whitespace.
#   - If a colon is present, removes all text up to the colon and the
#     trailing space.
#   - Splits the address into three comma-delimited elements:
#       addr_1: street address
#       addr_2: city
#       addr_3: state and ZIP combined
#   - Extracts state (two uppercase letters) from addr_3.
#   - Extracts ZIP (five digits) from addr_3.
#
# Inputs:
#   df  : tibble containing an address column.
#   col : bare column name for the raw address field.
#
# Output:
#   Mutated tibble with full_address, addr_1, addr_2, addr_3, state, zip.
###---------------------------------------------------------------------------

clean_address_components <- function(df, col) {
  df |>
    dplyr::mutate(
      # Normalize whitespace
      full_address = stringr::str_squish({{ col }}),

      # Remove any preface ending with a colon
      short_address = dplyr::if_else(
        stringr::str_detect(full_address, ":"),
        stringr::str_replace(full_address, "^.*?:\\s*", ""),
        full_address
      ),

      # Split into comma-delimited components
      comma_count = str_count(short_address, pattern = ","),
      street = ifelse(
        comma_count == 1,
        stringr::word(short_address, 1, sep = ", ") |>
          str_squish() |>
          stringr::str_remove(pattern = "\\s\\w+$"),
        ifelse(
          comma_count == 2,
          stringr::word(short_address, 1, sep = ", ") |>
            stringr::str_squish(),
          stringr::word(short_address, 1, 2, sep = ",") |> stringr::str_squish()
        )
      ),
      city = ifelse(
        comma_count == 1,
        stringr::word(short_address, 1, sep = ", ") |>
          stringr::str_extract(pattern = "\\w+$") |>
          stringr::str_squish(),
        ifelse(
          comma_count == 2,
          stringr::word(short_address, 2, sep = ",") |> stringr::str_squish(),
          stringr::word(short_address, 3, sep = ",") |> stringr::str_squish()
        )
      ),
      state_zip = stringr::word(
        short_address,
        -1,
        sep = ", "
      ) |>
        stringr::str_squish(),

      # Extract state (two letters after a space)
      state = str_extract(str_squish(state_zip), pattern = "[A-Z]{2}"),

      # Extract ZIP code
      zip = stringr::str_extract(state_zip, "\\d{5}"),
      .after = {{ col }}
    ) |>
    dplyr::select(-comma_count, -state_zip, -{{ col }}) |>
    dplyr::mutate(
      requirements = stringr::word(description, 1, sep = "\n"),
      details = stringr::word(description, 2, sep = "\n"),
      .after = description
    ) |>
    dplyr::select(-description)
}

###---------------------------------------------------------------------------
# Function: heartland_full_scrape()
#
# Purpose:
#   Wrapper to execute the entire scrape-and-clean workflow for a
#   Storepoint-powered food bank site.
#
# Inputs:
#   url         : character. Page URL with Storepoint map.
#   address_col : bare column name for address field in scrape output.
#
# Output:
#   Fully cleaned tibble with standardized address components.
#
# Notes:
#   - Calls initial_scrape_heartland() for rendered HTML extraction.
#   - Calls clean_address_components() for address normalization.
###---------------------------------------------------------------------------

heartland_full_scrape <- function(url, address_col) {
  # Run headless scrape
  scraped <- initial_scrape_heartland(url)

  # Clean address column and return structured tibble
  out <- clean_address_components(
    df = scraped,
    col = {{ address_col }}
  )

  return(out)
}


# RAPIDAPI FUNCTIONALITY -------------------------------------------------

fa_get <- function(endpoint) {
  httr2::request(
    paste0("https://feedam.org", endpoint)
  ) |>
    httr2::req_headers("Accept" = "application/json") |>
    httr2::req_perform() |>
    httr2::resp_body_json() |>
    tibble::as_tibble()
}

# Examples
# fa_orgs      <- fa_get("/hsds/v3/organizations")
# fa_services  <- fa_get("/hsds/v3/services")
# fa_locations <- fa_get("/hsds/v3/locations")
# fa_addresses <- fa_get("/hsds/v3/addresses")
# fa_phones    <- fa_get("/hsds/v3/phones")
# fa_schedules <- fa_get("/hsds/v3/schedules")
