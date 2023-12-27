#' Create an interactive force network plot in a htmlwidget
#'
#' @param data a tree network description in one of numerous forms (see
#' details)
#' @param width,height width and height of exported htmlwidget in pixels (single integer value; default == NULL)
#' @param ... other options (see details)
#' @param viewer whether to view the plot in the internal viewer or browser
#'
#' @description
#' The `force_network` function creates an interactive force network plot in a
#' htmlwidget
#'
#' @md
#' @export

force_network <- function(data, width = NULL, height = NULL, ..., viewer = "internal") {
  data <- as_force_data(data, ...)

  data <- jsonlite::toJSON(data, null = "null", na = "null", auto_unbox = TRUE,
                           digits = getOption("shiny.json.digits", 16),
                           use_signif = TRUE, force = TRUE, POSIXt = "ISO8601",
                           UTC = TRUE, rownames = FALSE, keep_vec_names = TRUE,
                           json_verabitm = TRUE)

  r2d3::r2d3(
    data = data,
    options = list(...),
    script = system.file("force_network.js", package = "network.r2d3"),
    d3_version = 4,
    container = "canvas",
    width = width,
    height = height,
    viewer = viewer
  )
}
