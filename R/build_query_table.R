#' Build the origin-destination-time query table
#'
#' Produces all combinations of origin and destination stations crossed with
#' the given query times, in the format expected by \code{get_route}.
#'
#' @param stations Data frame returned by \code{read_stations}.
#' @param date Query date as a string ("YYYY-MM-DD").
#' @param times Character vector of query times ("HH:MM"), at most 5.
#' @return A data frame with one row per origin-destination-time combination.
#' @export
#' @examples
#' stations <- data.frame(
#'   group_id = 1, region = "Romandie / Valais",
#'   is_origin = c(TRUE, FALSE, FALSE),
#'   city = c("Lausanne", "Geneva", "Sion"),
#'   station_id = c("8501120", "8501008", "8501506"),
#'   stringsAsFactors = FALSE
#' )
#' build_query_table(stations, "2026-06-19", c("08:00", "10:00"))
build_query_table <- function(stations, date, times) {
  origins      <- dplyr::filter(stations, .data$is_origin == TRUE)
  destinations <- dplyr::filter(stations, .data$is_origin == FALSE)
  
  from <- dplyr::select(origins, "group_id", "region", from_city = "city", from_station_id = "station_id")
  to   <- dplyr::select(destinations, to_city = "city", to_station_id = "station_id")

  dplyr::cross_join(from, to) |>
    dplyr::cross_join(data.frame(query_time = times)) |>
    dplyr::mutate(query_date = date) |>
    dplyr::select("group_id", "region", "from_city", "to_city",
                  "from_station_id", "to_station_id", "query_date", "query_time")
}