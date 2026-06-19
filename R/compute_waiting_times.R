#' Compute median waiting time to the next departure per destination
#'
#' For each origin-destination-time query, keeps the connection with the
#' smallest non-negative wait (query time to departure). Then summarizes
#' by destination using the median wait across all query times.
#'
#' @param routes Data frame of all parsed connections (output of combining
#'   multiple \code{parse_routes} calls with \code{dplyr::bind_rows}).
#' @param query_table Data frame returned by \code{build_query_table}.
#' @return A data frame with one row per destination: to_station_id, to_city,
#'   median_wait (in minutes).
#' @export
#' @examples
#' routes <- data.frame(
#'   from_station_id = c("8501120", "8501120"),
#'   to_station_id   = c("8501008", "8501008"),
#'   departure       = c("2026-06-19 08:05:00", "2026-06-19 08:35:00"),
#'   stringsAsFactors = FALSE
#' )
#' query <- data.frame(
#'   from_station_id = "8501120", to_station_id = "8501008",
#'   to_city = "Geneva", query_date = "2026-06-19", query_time = "08:00",
#'   stringsAsFactors = FALSE
#' )
#' compute_waiting_times(routes, query)
compute_waiting_times <- function(routes, query_table) {
  next_conn <- dplyr::left_join(query_table, routes,
                                by = c("from_station_id", "to_station_id")) |>
    dplyr::mutate(
      query_dt     = as.POSIXct(paste(.data$query_date, .data$query_time),
                                format = "%Y-%m-%d %H:%M", tz = "Europe/Zurich"),
      departure_dt = as.POSIXct(.data$departure,
                                format = "%Y-%m-%d %H:%M:%S", tz = "Europe/Zurich"),
      wait_min     = as.numeric(difftime(.data$departure_dt, .data$query_dt, units = "mins"))
    ) |>
    dplyr::filter(.data$wait_min >= 0) |>
    dplyr::group_by(.data$from_station_id, .data$to_station_id,
                    .data$query_date, .data$query_time) |>
    dplyr::slice_min(.data$wait_min, n = 1, with_ties = FALSE) |>
    dplyr::ungroup()
  
  dplyr::group_by(next_conn, .data$to_station_id, .data$to_city) |>
    dplyr::summarise(median_wait = median(.data$wait_min, na.rm = TRUE), .groups = "drop")
}