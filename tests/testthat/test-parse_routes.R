test_that("parse_routes returns one row per connection with correct columns", {
  resp <- list(connections = data.frame(
    departure = c("2026-06-19 08:05:00", "2026-06-19 08:35:00"),
    arrival   = c("2026-06-19 09:01:00", "2026-06-19 09:31:00"),
    duration  = c("0:56:00", "0:56:00"),
    stringsAsFactors = FALSE
  ))
  result <- parse_routes(resp, "8501120", "8501008")
  
  expect_equal(nrow(result), 2)
  expect_equal(result$from_station_id[1], "8501120")
  expect_equal(result$to_station_id[1], "8501008")
})