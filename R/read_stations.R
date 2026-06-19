#' Read and filter the SwissCities station data
#'
#' Reads SwissCities.csv and returns only the rows for the given region.
#'
#' @param path Path to SwissCities.csv.
#' @param region_name Region string to filter on (e.g., "Romandie / Valais").
#' @return A data frame with one row per station in the region.
#' @export
#' @examples
#' \dontrun{
#' stations <- read_stations("data/SwissCities.csv", "Romandie / Valais")
#' }
read_stations <- function(path, region_name) {
  stations <- readr::read_csv(
    path,
    col_types = readr::cols(station_id = readr::col_character()),
    show_col_types = FALSE
  )
  dplyr::filter(stations, .data$region == region_name)
}