library(hackpkg)

REGION <- "Romandie / Valais"
DATE   <- "2026-06-19"
TIMES  <- c("08:00", "10:00", "12:00", "14:00", "16:00")

stations    <- read_stations("data/SwissCities.csv", REGION)
query_table <- build_query_table(stations, DATE, TIMES)

all_routes <- dplyr::bind_rows(
  lapply(seq_len(nrow(query_table)), function(i) {
    row  <- query_table[i, ]
    resp <- get_route(row$from_station_id, row$to_station_id,
                      row$query_date, row$query_time,
                      cache_dir = "cache")
    parse_routes(resp, row$from_station_id, row$to_station_id)
  })
)

waiting <- compute_waiting_times(all_routes, query_table)

map <- waiting_time_map(stations, waiting, "data/boundaries")
print(map)
ggplot2::ggsave("waiting_time_map.png", map, width = 10, height = 7)