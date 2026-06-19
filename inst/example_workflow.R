library(hackpkg)

REGION    <- "Romandie / Valais"
DATE      <- "2026-06-19"
TIMES     <- c("08:00", "10:00", "12:00", "14:00", "16:00")
CACHE_DIR <- "cache"

stations    <- read_stations(system.file("extdata", "SwissCities.csv", package = "hackpkg"), REGION)
query_table <- build_query_table(stations, DATE, TIMES)

# Fetch all routes: 5 batch API calls (one per time slot) via the one_to_many
# endpoint. Subsequent runs read from cache with no network requests.
get_routes_batch(
  unique(query_table$from_station_id),
  unique(query_table$to_station_id),
  DATE, TIMES, cache_dir = CACHE_DIR
)

# Load each cached response and parse
responses <- lapply(seq_len(nrow(query_table)), function(i) {
  row <- query_table[i, ]
  readRDS(file.path(CACHE_DIR, paste0(
    row$from_station_id, "_", row$to_station_id, "_",
    row$query_date, "_", gsub(":", "", row$query_time), ".rds"
  )))
})

all_routes <- dplyr::bind_rows(lapply(seq_len(nrow(query_table)), function(i) {
  row <- query_table[i, ]
  parse_routes(responses[[i]], row$from_station_id, row$to_station_id)
}))

all_legs <- dplyr::bind_rows(lapply(seq_len(nrow(query_table)), function(i) {
  row <- query_table[i, ]
  parse_legs(responses[[i]], row$from_station_id, row$to_station_id)
}))

waiting <- compute_waiting_times(all_routes, query_table)

map <- waiting_time_map(stations, waiting, system.file("extdata", "boundaries", package = "hackpkg"))
print(map)

output_file <- "waiting_time_map.png"
ggplot2::ggsave(output_file, map, width = 10, height = 7, dpi = 300)
cat("Map saved to:", output_file, "\n")

cat("\nLegs table (first 10 rows):\n")
print(head(all_legs[, c("connection_id", "leg_id", "from_stop", "to_stop", "mode", "line")], 10))
