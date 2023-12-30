#' Create an interactive icicle network plot in a htmlwidget
#'
#' @param data a network description in one of numerous forms (see details)
#' @param width,height width and height of exported htmlwidget in pixels
#' (single integer value; default == NULL)
#' @param ... other options (see details)
#' @param viewer whether to view the plot in the internal viewer or browser
#'
#' @description
#' The `icicle_network` function creates an interactive icicle network plot in
#' a htmlwidget
#'
#' @md
#'
#' @export

icicle_network <- function(data, width = NULL, height = NULL, ..., viewer = "internal") {
  stopifnot(all(c("nodeId", "parentId", "value") %in% names(data)))
  data <- jsonlite::toJSON(data)

  options <- list(...)

  r2d3::r2d3(
    data = data,
    options = options,
    script = system.file("icicle_network.js", package = "network.r2d3"),
    d3_version = 6,
    container = "svg",
    width = width,
    height = height,
    viewer = viewer
  )
}
