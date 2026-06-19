test_that("get_routes_batch skips already-cached destinations", {
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

  # All destinations already cached — must not attempt any network call
  expect_silent(
    get_routes_batch("8501120", "8501008", "2026-06-19", "08:00", cache_dir = tmp)
  )

  loaded <- readRDS(file.path(tmp, "8501120_8501008_2026-06-19_0800.rds"))
  expect_equal(loaded$connections$departure, "2026-06-19 08:00:00")
})
