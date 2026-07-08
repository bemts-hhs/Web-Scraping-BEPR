###___________________________________________________________________________
# Scraping utility functions
###___________________________________________________________________________

# custom function to finish webscrape by pulling data into a rectangular
# format
initial_scrape_heartland <- function(url) {
  # initialize chromote session
  b <- ChromoteSession$new()

  # Navigate to page and wait for JS to finish
  b$Page$navigate(url)

  # Allows Storepoint scripts to finish injecting locations
  Sys.sleep(6)

  # Get rendered html
  html_rendered <- b$Runtime$evaluate(
    "document.documentElement.outerHTML"
  )$result$value

  # read html via rvest
  html <- rvest::read_html(html_rendered)

  # get the storepoint location tags
  locations <- html |> rvest::html_elements(".storepoint-location")

  # create a tibble from the locations data
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
}


# wrapper function for the whole heartland scrape workflow
heartland_full_scrape <- function(url) {
  
}
