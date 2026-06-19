#' Fetch and parse all routes for a query table
#'
#' Calls \code{get_routes_batch} to download all routes in the query table
#' (one API request per time slot), then parses each response with
#' \code{parse_routes} and returns the combined result. Subsequent calls read
#' from the local cache with no network requests.
#'
#' @param query_table Data frame returned by \code{build_query_table}.
#' @param cache_dir Character. Directory for caching API responses (default "cache").
#'
#' @return A data frame with one row per connection, combining the output of
#'   \code{parse_routes} across all origin-destination-time combinations.
#' @export
#' @examples
#' \dontrun{
#' stations    <- read_stations(
#'   system.file("extdata", "SwissCities.csv", package = "hackpkg"),
#'   "Romandie / Valais"
#' )
#' query_table <- build_query_table(stations, "2026-06-19", c("08:00", "10:00"))
#' all_routes  <- fetch_all_routes(query_table)
#' }
fetch_all_routes <- function(query_table, cache_dir = "cache") {
  get_routes_batch(
    unique(query_table$from_station_id),
    unique(query_table$to_station_id),
    unique(query_table$query_date),
    unique(query_table$query_time),
    cache_dir = cache_dir
  )

  dplyr::bind_rows(lapply(seq_len(nrow(query_table)), function(i) {
    row  <- query_table[i, ]
    resp <- readRDS(file.path(cache_dir, paste0(
      row$from_station_id, "_", row$to_station_id, "_",
      row$query_date, "_", gsub(":", "", row$query_time), ".rds"
    )))
    parse_routes(resp, row$from_station_id, row$to_station_id)
  }))
}
