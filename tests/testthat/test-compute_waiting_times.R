test_that("compute_waiting_times returns the minimum non-negative wait per destination", {
  routes <- data.frame(
    from_station_id = c("8501120", "8501120"),
    to_station_id   = c("8501008", "8501008"),
    departure       = c("2026-06-19 08:05:00", "2026-06-19 08:35:00"),
    stringsAsFactors = FALSE
  )
  query <- data.frame(
    from_station_id = "8501120", to_station_id = "8501008",
    to_city = "Geneva", query_date = "2026-06-19", query_time = "08:00",
    stringsAsFactors = FALSE
  )
  result <- compute_waiting_times(routes, query)
  
  # 08:05 is 5 min after 08:00, 08:35 is 35 min — minimum is 5, median of one value is 5
  expect_equal(result$median_wait, 5)
  expect_equal(result$to_city, "Geneva")
})

