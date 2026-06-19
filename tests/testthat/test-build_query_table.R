test_that("build_query_table produces correct row count and columns", {
  stations <- data.frame(
    group_id = 1, region = "Romandie / Valais",
    is_origin = c(TRUE, FALSE, FALSE),
    city = c("Lausanne", "Geneva", "Sion"),
    station_id = c("8501120", "8501008", "8501506"),
    stringsAsFactors = FALSE
  )
  result <- build_query_table(stations, "2026-06-19", c("08:00", "10:00"))
  
  # 1 origin x 2 destinations x 2 times = 4 rows
  expect_equal(nrow(result), 4)
  expect_true(all(c("from_station_id", "to_station_id", "query_date", "query_time") %in% names(result)))
  expect_equal(unique(result$query_date), "2026-06-19")
})