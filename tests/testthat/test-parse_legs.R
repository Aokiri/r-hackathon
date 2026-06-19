test_that("parse_legs returns one row per leg with correct columns", {
  legs_df <- data.frame(
    name   = c("Lausanne", "Geneve-Airport"),
    stopid = c("8501120", "8501407"),
    type   = c("express_train", "walk"),
    line   = c("RE33", NA_character_),
    stringsAsFactors = FALSE
  )
  legs_df$exit <- data.frame(
    name   = c("Geneva", "Geneva"),
    stopid = c("8501008", "8501008"),
    stringsAsFactors = FALSE
  )
  resp <- list(connections = data.frame(departure = "2026-06-19 08:00:00",
                                        stringsAsFactors = FALSE))
  resp$connections$legs <- list(legs_df)

  result <- parse_legs(resp, "8501120", "8501008")

  expect_equal(nrow(result), 2)
  expect_equal(result$from_stop[1], "Lausanne")
  expect_equal(result$to_stop[1], "Geneva")
  expect_equal(result$mode[1], "express_train")
  expect_equal(result$connection_id[1], 1L)
  expect_equal(result$leg_id, c(1L, 2L))
  expect_true(all(c("from_stop_id", "to_stop_id", "line") %in% names(result)))
})
