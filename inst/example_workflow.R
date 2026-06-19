library(hackpkg)

REGION <- "Romandie / Valais"
DATE   <- "2026-06-19"
TIMES  <- c("08:00", "10:00", "12:00", "14:00", "16:00")

stations    <- read_stations(system.file("extdata", "SwissCities.csv", package = "hackpkg"), REGION)
query_table <- build_query_table(stations, DATE, TIMES)

# Fetch all routes: one API call per time slot (5 total) instead of one per
# origin-destination-time combination (70 total). Results go to cache so the
# loop below reads everything locally with no further network requests.
to_ids <- unique(query_table$to_station_id)
get_routes_batch(unique(query_table$from_station_id), to_ids, DATE, TIMES, cache_dir = "cache")

# Load from cache
responses <- lapply(seq_len(nrow(query_table)), function(i) {
  row <- query_table[i, ]
  get_route(row$from_station_id, row$to_station_id,
            row$query_date, row$query_time, cache_dir = "cache")
})

# Parse flat connections table
all_routes <- dplyr::bind_rows(
  lapply(seq_len(nrow(query_table)), function(i) {
    row <- query_table[i, ]
    parse_routes(responses[[i]], row$from_station_id, row$to_station_id)
  })
)

# Parse legs table (bonus task)
all_legs <- dplyr::bind_rows(
  lapply(seq_len(nrow(query_table)), function(i) {
    row <- query_table[i, ]
    parse_legs(responses[[i]], row$from_station_id, row$to_station_id)
  })
)

waiting <- compute_waiting_times(all_routes, query_table)

map <- waiting_time_map(stations, waiting, system.file("extdata", "boundaries", package = "hackpkg"))
print(map)

output_file <- "waiting_time_map.png"
ggplot2::ggsave(output_file, map, width = 10, height = 7, dpi = 300)
cat("Map saved to:", output_file, "\n")

cat("\nLegs table (first 10 rows):\n")
print(head(all_legs[, c("connection_id", "leg_id", "from_stop", "to_stop", "mode", "line")], 10))
