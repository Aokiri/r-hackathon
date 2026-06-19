test_that("fetch_all_routes reads from cache and returns combined routes", {
  tmp <- tempfile()
  dir.create(tmp)
  on.exit(unlink(tmp, recursive = TRUE))

  mock <- list(connections = data.frame(
    departure = "2026-06-19 08:00:00",
    arrival   = "2026-06-19 08:51:00",
    duration  = 3060L,
    stringsAsFactors = FALSE
  ))
  saveRDS(mock, file.path(tmp, "8501120_8501008_2026-06-19_0800.rds"))

  qt <- data.frame(
    from_station_id = "8501120",
    to_station_id   = "8501008",
    query_date      = "2026-06-19",
    query_time      = "08:00",
    stringsAsFactors = FALSE
  )

  result <- fetch_all_routes(qt, cache_dir = tmp)

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 1L)
  expect_equal(result$from_station_id, "8501120")
  expect_equal(result$departure, "2026-06-19 08:00:00")
})
