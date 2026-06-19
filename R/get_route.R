#' Download route data from the search.ch timetable API with caching
#'
#' Checks for a cached .rds file before making a network request. On a cache
#' miss, it calls the API, saves the response locally, and returns it.
#'
#' @param from Origin station ID (character).
#' @param to Destination station ID (character).
#' @param date Date string ("YYYY-MM-DD").
#' @param time Time string ("HH:MM").
#' @param num Number of connections to retrieve (default 5).
#' @param cache_dir Path to the directory used for caching responses (default "cache").
#' @return A list with the parsed JSON response from the API.
#' @export
#' @examples
#' \dontrun{
#' route <- get_route("8501120", "8501008", "2026-06-19", "08:00")
#' }
get_route <- function(from, to, date, time, num = 5, cache_dir = "cache") {
  filename   <- paste0(from, "_", to, "_", date, "_", gsub(":", "", time), ".rds")
  cache_file <- file.path(cache_dir, filename)
  
  if (file.exists(cache_file)) {
    return(readRDS(cache_file))
  }
  
  response <- httr::GET(
    "https://search.ch/timetable/api/route.json",
    query = list(from = from, to = to, date = date, time = time, num = num)
  )
  result <- jsonlite::fromJSON(httr::content(response, as = "text", encoding = "UTF-8"))
  
  dir.create(cache_dir, showWarnings = FALSE, recursive = TRUE)
  saveRDS(result, cache_file)
  result
}