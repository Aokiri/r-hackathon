library(hackpkg)

REGION <- "Romandie / Valais"
DATE   <- "2026-06-19"
TIMES  <- c("08:00", "10:00", "12:00", "14:00", "16:00")

stations    <- read_stations(system.file("extdata", "SwissCities.csv", package = "hackpkg"), REGION)
query_table <- build_query_table(stations, DATE, TIMES)
all_routes  <- fetch_all_routes(query_table)
waiting     <- compute_waiting_times(all_routes, query_table)
map         <- waiting_time_map(stations, waiting, system.file("extdata", "boundaries", package = "hackpkg"))

print(map)
ggplot2::ggsave("waiting_time_map.png", map, width = 10, height = 7, dpi = 300)
cat("Map saved to: waiting_time_map.png\n")
