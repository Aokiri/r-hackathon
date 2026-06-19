#' Parse a single route API response into a tidy data frame
#'
#' Extracts the top-level connection fields from one \code{get_route} response.
#' To combine multiple responses, use \code{dplyr::bind_rows(lapply(..., parse_routes, ...))}.
#'
#' @param response List returned by \code{get_route}.
#' @param from_station_id Origin station ID, added as a column for identification.
#' @param to_station_id Destination station ID, added as a column for identification.
#' @return A data frame with one row per connection.
#' @export
#' @examples
#' resp <- list(connections = data.frame(
#'   departure = c("2026-06-19 08:05:00", "2026-06-19 08:35:00"),
#'   arrival   = c("2026-06-19 09:01:00", "2026-06-19 09:31:00"),
#'   duration  = c("0:56:00", "0:56:00"),
#'   stringsAsFactors = FALSE
#' ))
#' parse_routes(resp, "8501120", "8501008")
parse_routes <- function(response, from_station_id, to_station_id) {
  conn <- response$connections
  data.frame(
    from_station_id = from_station_id,
    to_station_id   = to_station_id,
    departure       = conn$departure,
    arrival         = conn$arrival,
    duration        = conn$duration,
    stringsAsFactors = FALSE
  )
}