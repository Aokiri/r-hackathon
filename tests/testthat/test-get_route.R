test_that("get_route loads from cache without calling the API", {
  tmp        <- tempdir()
  fake       <- list(connections = data.frame(departure = "2026-06-19 08:05:00"))
  cache_file <- file.path(tmp, "8501120_8501008_2026-06-19_0800.rds")
  saveRDS(fake, cache_file)
  
  result <- get_route("8501120", "8501008", "2026-06-19", "08:00", cache_dir = tmp)
  expect_equal(result$connections$departure, "2026-06-19 08:05:00")
})