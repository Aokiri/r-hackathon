#' Parse route legs from a single API response into a tidy data frame
#'
#' Extracts one row per leg (vehicle segment or walk) for every connection in
#' the response. Use \code{dplyr::bind_rows(lapply(..., parse_legs, ...))} to
#' combine results across multiple queries.
#'
#' @param response List returned by \code{get_route}.
#' @param from_station_id Origin station ID, added as a column for identification.
#' @param to_station_id Destination station ID, added as a column for identification.
#' @return A data frame with one row per leg: from_station_id, to_station_id,
#'   connection_id, leg_id, from_stop, from_stop_id, to_stop, to_stop_id,
#'   mode, line.
#' @export
#' @examples
#' legs_df <- data.frame(name = "Lausanne", stopid = "8501120",
#'                       type = "express_train", line = "RE33",
#'                       stringsAsFactors = FALSE)
#' legs_df$exit <- data.frame(name = "Geneva", stopid = "8501008",
#'                            stringsAsFactors = FALSE)
#' resp <- list(connections = data.frame(departure = "2026-06-19 08:00:00",
#'                                       stringsAsFactors = FALSE))
#' resp$connections$legs <- list(legs_df)
#' parse_legs(resp, "8501120", "8501008")
parse_legs <- function(response, from_station_id, to_station_id) {
  conn <- response$connections

  dplyr::bind_rows(
    lapply(seq_len(nrow(conn)), function(ci) {
      legs <- conn[["legs"]][[ci]]
      if (is.null(legs) || nrow(legs) == 0) return(NULL)

      data.frame(
        from_station_id = from_station_id,
        to_station_id   = to_station_id,
        connection_id   = ci,
        leg_id          = seq_len(nrow(legs)),
        from_stop       = legs[["name"]],
        from_stop_id    = legs[["stopid"]],
        to_stop         = legs[["exit"]][["name"]],
        to_stop_id      = legs[["exit"]][["stopid"]],
        mode            = legs[["type"]],
        line            = legs[["line"]],
        stringsAsFactors = FALSE
      )
    })
  )
}
