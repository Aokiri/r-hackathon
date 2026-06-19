test_that("waiting_time_map returns a ggplot object", {
  skip_if_not_installed("sf")
  skip_if_not_installed("ggplot2")
  skip_if(system.file("extdata", "boundaries", package = "hackpkg") == "", "boundaries not found")

  stations <- data.frame(
    group_id = 1, region = "Romandie / Valais",
    is_origin = c(TRUE, FALSE, FALSE),
    city = c("Lausanne", "Geneva", "Sion"),
    station_id = c("8501120", "8501008", "8501506"),
    canton = c("VD", "GE", "VS"),
    latitude = c(46.52, 46.20, 46.23),
    longitude = c(6.63, 6.14, 7.36),
    population = c(140202, 203856, 34708),
    stringsAsFactors = FALSE
  )
  waiting <- data.frame(
    to_station_id = c("8501008", "8501506"),
    to_city       = c("Geneva", "Sion"),
    median_wait   = c(12.5, 8.0),
    stringsAsFactors = FALSE
  )
  p <- waiting_time_map(stations, waiting, system.file("extdata", "boundaries", package = "hackpkg"))
  expect_s3_class(p, "ggplot")
})