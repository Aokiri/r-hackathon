#' Plot a waiting-time accessibility map for the region
#'
#' Produces a map of Switzerland with the group's cantons highlighted,
#' straight-line connections from the origin to each destination, destination
#' cities shown as points colored by median waiting time and sized by
#' population, and the origin station marked with a star.
#'
#' @param stations Data frame returned by \code{read_stations}.
#' @param waiting_times Data frame returned by \code{compute_waiting_times}
#'   (columns: to_station_id, to_city, median_wait).
#' @param boundaries_path Path to the directory or shapefile containing Swiss
#'   canton boundaries. Use
#'   \code{system.file("extdata", "boundaries", package = "hackpkg")} for the
#'   bundled data.
#' @return A ggplot2 object.
#' @export
#' @examples
#' \dontrun{
#' stations <- read_stations(system.file("extdata", "SwissCities.csv", package = "hackpkg"),
#'                           "Romandie / Valais")
#' waiting  <- compute_waiting_times(all_routes, query_table)
#' waiting_time_map(stations, waiting,
#'                  system.file("extdata", "boundaries", package = "hackpkg"))
#' }
waiting_time_map <- function(stations, waiting_times, boundaries_path) {
  borders <- sf::read_sf(boundaries_path) |>
    sf::st_transform(crs = 4326)
  borders$in_region <- borders$KTKZ %in% unique(stations$canton)

  destinations <- stations |>
    dplyr::filter(.data$is_origin == FALSE) |>
    dplyr::left_join(
      dplyr::select(waiting_times, station_id = "to_station_id", "median_wait"),
      by = "station_id"
    ) |>
    sf::st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

  origin <- stations |>
    dplyr::filter(.data$is_origin == TRUE) |>
    sf::st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

  origin_coord <- sf::st_coordinates(origin)[1, , drop = FALSE]
  route_lines  <- sf::st_sf(
    geometry = sf::st_sfc(
      lapply(sf::st_geometry(destinations), function(d) {
        sf::st_linestring(rbind(origin_coord, sf::st_coordinates(d)))
      }),
      crs = 4326
    )
  )

  ggplot2::ggplot() +
    ggplot2::geom_sf(data = borders,
                     ggplot2::aes(fill = .data$in_region),
                     color = "grey50", linewidth = 0.3) +
    ggplot2::scale_fill_manual(
      values = c("FALSE" = "grey93", "TRUE" = "#cfe2f3"),
      guide  = "none"
    ) +
    ggplot2::geom_sf(data = route_lines, color = "steelblue", linewidth = 0.4, alpha = 0.5) +
    ggplot2::geom_sf(data = destinations,
                     ggplot2::aes(color = .data$median_wait, size = .data$population)) +
    ggplot2::geom_sf(data = origin, shape = 8, size = 4, color = "firebrick") +
    ggplot2::geom_sf_text(data = destinations,
                          ggplot2::aes(label = .data$city), size = 2.5, nudge_y = 0.03) +
    ggplot2::scale_color_viridis_c(name = "Median wait (min)", option = "plasma") +
    ggplot2::scale_size_continuous(name = "Population", range = c(2, 8)) +
    ggplot2::labs(
      title    = "Waiting-time accessibility",
      subtitle = "Romandie / Valais - departures from Lausanne"
    ) +
    ggplot2::theme_minimal()
}