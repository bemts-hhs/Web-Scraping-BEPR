###___________________________________________________________________________
# Scraping utility functions
###___________________________________________________________________________

httr2_request_safe <- function(url) {
  httr2::request(url) |>
    httr2::req_user_agent("WEB-SCRAPER-BEPR/1.0") |>
    httr2::req_timeout(30) |>
    httr2::req_retry(max_tries = 3) |>
    httr2::req_perform()
}

read_html_safe <- function(resp) {
  resp |> httr2::resp_body_html()
}

scrape_one <- function(url) {
  resp <- httr2_request_safe(url)
  html <- read_html_safe(resp)
  parse_generic(html, url)
}
