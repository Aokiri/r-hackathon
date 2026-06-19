#' Fetch routes for multiple destinations in a single API call
#'
#' Uses the search.ch \code{one_to_many} endpoint to retrieve routes from one
#' origin to multiple destinations, issuing one request per time slot instead
#' of one request per destination. Results are cached individually so that
#' \code{\link{get_route}} can read them on subsequent runs without any further
#' API calls.
#'
#' @param from Character. Station ID of the origin.
#' @param to Character vector. Station IDs of the destinations.
#' @param date Character. Date in "YYYY-MM-DD" format.
#' @param times Character vector. Departure times in "HH:MM" format.
#' @param num Integer. Maximum connections per destination (default 5).
#' @param cache_dir Character. Directory for caching results (default "cache").
#'
#' @return Invisibly returns \code{NULL}. Results are written to \code{cache_dir}
#'   in the same format as \code{\link{get_route}} so the rest of the workflow
#'   is unchanged.
#' @export
#' @examples
#' \dontrun{
#' stations <- read_stations(
#'   system.file("extdata", "SwissCities.csv", package = "hackpkg"),
#'   "Romandie / Valais"
#' )
#' to_ids <- stations[stations[["is_origin"]] == FALSE, "station_id", drop = TRUE]
#' get_routes_batch("8501120", to_ids, "2026-06-19", c("08:00", "10:00"),
#'                  cache_dir = "cache")
#' }
get_routes_batch <- function(from, to, date, times, num = 5, cache_dir = "cache") {
  dir.create(cache_dir, showWarnings = FALSE, recursive = TRUE)

  for (time in times) {
    time_tag <- gsub(":", "", time)

    missing <- to[!vapply(to, function(t) {
      file.exists(file.path(cache_dir, paste0(from, "_", t, "_", date, "_", time_tag, ".rds")))
    }, logical(1))]

    if (length(missing) == 0) next

    to_params <- paste0("to[", seq_along(missing) - 1L, "]=", missing, collapse = "&")
    url <- paste0(
      "https://search.ch/timetable/api/route.json?one_to_many=1",
      "&from=", from,
      "&date=", date,
      "&time=", time,
      "&num=", num, "&",
      to_params
    )

    resp <- httr::GET(utils::URLencode(url))
    raw  <- httr::content(resp, as = "text", encoding = "UTF-8")

    # Parse without simplification to safely extract each destination's connections
    parsed <- jsonlite::fromJSON(raw, simplifyVector = FALSE)
    api_results <- parsed[["results"]]

    for (i in seq_along(missing)) {
      conn_list  <- api_results[[i]][["connections"]]
      # Re-encode and re-parse so the cached object matches get_route()'s format
      normalized <- jsonlite::fromJSON(
        jsonlite::toJSON(list(connections = conn_list), auto_unbox = TRUE, null = "null")
      )
      saveRDS(normalized, file.path(cache_dir,
        paste0(from, "_", missing[[i]], "_", date, "_", time_tag, ".rds")))
    }
  }

  invisible(NULL)
}
