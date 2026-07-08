###___________________________________________________________________________
# Tools for parsing data from the web
###___________________________________________________________________________

parse_generic <- function(html, url) {
  title <- html |> rvest::html_element("title") |> rvest::html_text2()

  tables <- html |>
    rvest::html_table() |>
    purrr::map(janitor::clean_names)

  tibble::tibble(
    url = url,
    page_title = title,
    n_tables = length(tables),
    tables = list(tables)
  )
}
