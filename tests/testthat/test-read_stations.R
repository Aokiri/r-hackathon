test_that("read_stations filters to the requested region", {
  tmp <- tempfile(fileext = ".csv")
  write.csv(data.frame(
    group_id = c(1, 2), region = c("Romandie / Valais", "Other"),
    is_origin = c(TRUE, FALSE), city = c("Lausanne", "Bern"),
    station_name = c("Lausanne", "Bern"), station_id = c("8501120", "8507000"),
    canton = c("VD", "BE"), latitude = c(46.52, 46.95),
    longitude = c(6.63, 7.45), population = c(140202, 134290)
  ), tmp, row.names = FALSE)
  
  result <- read_stations(tmp, "Romandie / Valais")
  expect_equal(nrow(result), 1)
  expect_equal(result$city, "Lausanne")
})