###___________________________________________________________________________
# Scraping utility functions ----
###___________________________________________________________________________

# HEARTLAND WEBSITE FUNCTIONS --------------------------------------------

###___________________________________________________________________________----
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
###___________________________________________________________________________----

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


###___________________________________________________________________________----
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
###___________________________________________________________________________----

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

###___________________________________________________________________________----
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
###___________________________________________________________________________----

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


# FEEDING AMERICA API FUNCTIONS ----------------------------------------------

###___________________________________________________________________________
# Function: fa_get_page()
#
# Purpose:
#   Retrieve a single page of results from any HSDS v3 endpoint within the
#   Feeding America API. HSDS endpoints are fully paginated, with a default
#   page size of 100 records. This helper performs one request, parses JSON,
#   and returns the HSDS metadata wrapper as a tibble. Optional benchmarking
#   reports execution time for performance diagnostics.
#
# Inputs:
#   endpoint  : Character. HSDS endpoint beginning with "/hsds/v3/", such as
#               "/hsds/v3/locations".
#   page_num  : Integer. Page number to retrieve.
#   size      : Integer. Page size. Default is 100.
#   benchmark : Logical. If TRUE, the function reports execution time
#               using cli alerts.
#
# Output:
#   Tibble containing the HSDS metadata wrapper (total_items, end,
#   page_number, size, first_page, last_page, empty, contents).
#
# Notes:
#   - The "contents" list-column is not tidied here. Use hsds_tidy() for that.
#   - Benchmarking is intended for iterative parallel ingestion diagnostics.
###___________________________________________________________________________

fa_get_page <- function(endpoint, page_num, size = 100, benchmark = FALSE) {
  if (benchmark) {
    start_time <- Sys.time()
  }

  out <- httr2::request(
    paste0("https://feedam.org/hsds/v3/", endpoint)
  ) |>
    httr2::req_options(fresh_connect = TRUE) |>
    httr2::req_url_query(page = page_num, size = size, format = "json") |>
    httr2::req_headers("Accept" = "application/json") |>
    httr2::req_perform() |>
    httr2::resp_body_json() |>
    tibble::as_tibble()

  if (benchmark) {
    end_time <- Sys.time()
    total_time <- difftime(end_time, start_time, units = "auto")
    time_val <- total_time |> as.numeric() |> round(digits = 2)
    time_units <- attr(total_time, "units")

    cli::cli_alert_info(
      "{.fn fa_get_page} ran in {col_blue(time_val)} {col_blue(time_units)}."
    )
  }

  return(out)
}


###___________________________________________________________________________
# Function: fa_get_total_pages()
#
# Purpose:
#   Retrieve the total number of pages available from any HSDS v3 endpoint.
#   HSDS responses include pagination metadata in every page. This helper
#   queries the first page and extracts the total_pages field.
#
# Inputs:
#   endpoint  : Character. HSDS endpoint beginning with "/hsds/v3/".
#   page_num  : Integer. Page number to inspect. Defaults to 1 since all pages
#               include identical pagination metadata.
#   size      : Integer. Page size. Default = 100.
#   benchmark : Logical. When TRUE, passes benchmarking through fa_get_page().
#
# Output:
#   Integer indicating total number of pages in the HSDS endpoint.
#
# Notes:
#   - Used by parallel ingestion workflows and mori/mirai iteration strategies.
#   - HSDS endpoints often contain very large datasets (hundreds of thousands
#     of records). Knowing total_pages assists performance planning.
###___________________________________________________________________________

fa_get_total_pages <- function(
  endpoint,
  page_num = 1,
  size = 100,
  benchmark = FALSE
) {
  temp <- fa_get_page(
    endpoint = endpoint,
    page_num = page_num,
    size = size,
    benchmark = benchmark
  )

  out <- temp |>
    dplyr::distinct(total_pages) |>
    dplyr::pull(total_pages)

  return(out)
}


###___________________________________________________________________________
# Function: hsds_tidy()
#
# Purpose:
#   Convert the nested HSDS “contents” field into a rectangular tibble. All HSDS
#   records contain optional fields that may be NULL. Since NULL is not a valid
#   tibble column type, this helper replaces NULL values with NA.
#
# Inputs:
#   x : A tibble produced by fa_get_page(), containing a “contents” list-column
#       where each element is a list of HSDS fields.
#
# Output:
#   A rectangular tibble where each HSDS record is one row and all NULL fields
#   are replaced with NA.
#
# Notes:
#   - Required by all HSDS entity types (locations, services, addresses, phones,
#     schedules, organizations).
#   - HSDS is compliant with OpenReferral; this NULL→NA transformation is standard.
###___________________________________________________________________________

hsds_tidy <- function(x) {
  x$contents |>
    purrr::map(\(rec) {
      rec |>
        purrr::modify(\(val) if (is.null(val)) NA else val) |>
        tibble::as_tibble()
    }) |>
    purrr::list_rbind()
}

###___________________________________________________________________________
# Function: fa_loop_ingest()
#
# Purpose:
#   Sequentially retrieve all pages from a Feeding America HSDS v3 endpoint,
#   apply HSDS tidying logic to each page, and combine the results into a single
#   rectangular tibble. This function implements a progress bar using
#   cli::cli_progress_along(), providing real-time reporting on page number,
#   total pages, and percent complete. This loop serves as a baseline benchmark
#   against parallel mirai ingestion.
#
# Inputs:
#   endpoint : Character. HSDS v3 endpoint beginning with "/hsds/v3/", such as
#              "/hsds/v3/locations", "/hsds/v3/services", etc.
#
#   size     : Integer. Page size. HSDS defaults to 100. Rarely adjusted.
#
# Output:
#   Tibble containing all HSDS records from the endpoint, fully tidied.
#
# Workflow:
#   1. Determine total page count for the endpoint via fa_get_total_pages().
#   2. Initialize progress reporting via cli_progress_along().
#   3. Iterate through page indices, retrieving each page with fa_get_page().
#   4. Convert each raw page’s contents list into a tidy tibble using hsds_tidy().
#   5. Bind all page-level tibbles together via vctrs::list_rbind().
#
# Notes:
#   - This function is serial and slower than mirai ingestion; however,
#     it is stable, predictable, and ideal for controlled benchmarking.
#   - HSDS datasets can be very large (hundreds of thousands of records).
#     Progress reporting meaningfully improves monitoring during long runs.
###___________________________________________________________________________

fa_loop_ingest <- function(
  endpoint,
  start = NULL,
  end = NULL,
  size = 100
) {
  # if start is NULL, start from the first index, else use start
  if (is.null(start)) {
    start <- 1
  }

  # if total_pages is NULL, then get all pages
  if (is.null(end)) {
    # Retrieve the total number of pages for the endpoint
    end <- fa_get_total_pages(
      endpoint = endpoint,
      size = size,
      benchmark = FALSE
    )
  }

  # Header
  cli_h1("Feeding America HSDS Data Ingestion")

  # Informative message to user
  cli::cli_inform(c(
    "i" = "Serial HSDS client initialized. Listener active on {endpoint}.\n",
    "v" = "Beginning paginated retrieval at page {start}, ending retrieval at page {end} with {end - start + 1} pages queued.\n"
  ))

  # Preallocate results list for efficiency
  out_list <- list()

  # initialize pages vector
  pages <- start:end

  # Generate the progress-aware index sequence
  cli::cli_progress_bar(
    name = "HSDS Ingestion",
    total = length(pages),
    format = paste0(
      "Ingesting [",
      "{cli::pb_bar}",
      "] ",
      "Page {cli::pb_current}/{cli::pb_total} ",
      "({round(cli::pb_current/cli::pb_total*100)}%) ",
      "| Elapsed: {cli::pb_elapsed} | ETA: {cli::pb_eta}"
    )
  )

  # Serial ingestion loop with progress reporting
  for (i in pages) {
    # update progress
    cli::cli_progress_update()

    # Retrieve page i of HSDS data
    raw_page <- fa_get_page(
      endpoint = endpoint,
      page_num = i,
      size = size,
      benchmark = FALSE
    )

    # Transform nested contents list into tidy rectangular tibble
    out_list[[i]] <- hsds_tidy(raw_page)
  }

  # return a tidy tibble of results
  out <- out_list |> purrr::list_rbind()

  return(out)
}


###___________________________________________________________________________
# Function: fa_get_parallel()
#
# Purpose:
#   Execute parallel ingestion of Feeding America HSDS v3 endpoint data using
#   mirai_map() and multiple daemons. This implementation uses
#   cli_progress_along() to provide a progress bar that reports status, percent
#   complete, elapsed time, and estimated remaining time. All pages are executed
#   concurrently and then collapsed into a single rectangular tibble.
#
# Inputs:
#   endpoint : Character. HSDS v3 endpoint beginning with "/hsds/v3/", such as
#              "/hsds/v3/locations" or "/hsds/v3/addresses".
#   size     : Integer. Page size. Default is 100.
#
# Output:
#   A tibble containing all records from the HSDS endpoint, fully tidied.
#
# Workflow:
#   1. Query page 1 to identify total_pages.
#   2. Establish parallel mirai daemons.
#   3. Construct a progress-aware sequence of page indices.
#   4. For each page index, invoke helper1 (fa_get_page) to retrieve raw data
#      and helper2 (hsds_tidy) to convert nested contents into a tidy tibble.
#   5. Return a flat, combined tibble using purrr::list_rbind().
#
# Helper Functions Passed Explicitly:
#   helper1 : fa_get_page() — retrieves a single HSDS page.
#   helper2 : hsds_tidy() — tidies HSDS page contents into rectangular tibble.
#
# Notes:
#   - This function is designed for large HSDS endpoints (thousands of pages).
#   - The progress bar uses cli's internal timing estimates to report ETA.
#   - Daemons(10) is appropriate for Windows 11 ingestion; adjust as needed.
###___________________________________________________________________________

fa_get_parallel <- function(
  endpoint,
  start = NULL,
  end = NULL,
  size = 100
) {
  # get the function start time
  start_time <- Sys.time()

  # if start is NULL, start from the first index, else use start
  if (is.null(start)) {
    start <- 1
  }

  # if end is NULL, then get all pages
  if (is.null(end)) {
    # Retrieve the total number of pages for the endpoint
    end <- fa_get_total_pages(
      endpoint = endpoint,
      size = size,
      benchmark = FALSE
    )
  }

  # Header
  cli_h1("Feeding America HSDS Data Ingestion")

  # Informative message to user
  cli::cli_inform(c(
    "i" = "Parallel HSDS client initialized. Listener active on {endpoint}.\n",
    "v" = "Beginning paginated retrieval at page {start}, ending retrieval at page {end} with {end - start + 1} pages queued.\n"
  ))

  # Parallel ingestion loop with progress reporting
  out <- mirai_map(
    .x = start:end,

    \(pg) {
      #_________________________________________________________________
      # helper1: fa_get_page()
      #   Retrieves one HSDS v3 page. The page contains pagination
      #   metadata and a "contents" list-column that must be tidied.
      #_________________________________________________________________
      dat <- helper1(
        endpoint = endpoint,
        page_num = pg,
        size = size,
        benchmark = FALSE
      )

      #_________________________________________________________________
      # helper2: hsds_tidy()
      #   Converts HSDS nested lists into a rectangular tibble,
      #   replacing NULL with NA and binding fields into columns.
      #_________________________________________________________________
      helper2(dat)
    },
    helper1 = fa_get_page,
    helper2 = hsds_tidy
  )[.progress, .stop]

  # bind list rows to create a tidy tibble
  out_tbl <- purrr::list_rbind(out)

  # get the function end time
  end_time <- Sys.time()

  # get raw time difference
  runtime <- difftime(end_time, start_time, units = "auto")

  # unit attribute
  unit <- attr(runtime, which = "units")

  # get rounded time without unit
  runtime_val <- round(
    as.numeric(runtime),
    digits = 2
  )

  # print a dynamic message on how long the function took to run
  cli::cli_alert_success(
    "{.fn fa_get_parallel} ran for {cli::col_blue(runtime_val)} {unit}."
  )

  return(out_tbl)
}
