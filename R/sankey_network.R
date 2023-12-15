#' Create an interactive sankey network plot in a htmlwidget
#'
#' @param data a network description in one of numerous forms (see details)
#' @param width,height width and height of exported htmlwidget in pixels
#' (single integer value; default == NULL)
#' @param ... other options (see details)
#' @param viewer whether to view the plot in the internal viewer or browser
#'
#' @description
#' The `sankey_network` function creates an interactive sankey network plot in
#' a htmlwidget
#'
#' @md
#' @export

sankey_network <- function(data, width = NULL, height = NULL, ..., viewer = "browser") {
  data <- as_sankey_data(data, ...)

  data <- jsonlite::toJSON(data, null = "null", na = "null", auto_unbox = TRUE,
                           digits = getOption("shiny.json.digits", 16),
                           use_signif = TRUE, force = TRUE, POSIXt = "ISO8601",
                           UTC = TRUE, rownames = FALSE, keep_vec_names = TRUE,
                           json_verabitm = TRUE)

  options <- list(
    linkStrokeOpacity = ifelse(methods::hasArg("linkStrokeOpacity"), list(...)$linkStrokeOpacity, 0.3),
    linkMixBlendMode = ifelse(methods::hasArg("linkMixBlendMode"), list(...)$linkMixBlendMode, "multiply"),
    linkPath = ifelse(methods::hasArg("linkPath"), list(...)$linkPath, "d3.sankeyLinkHorizontal()"),
    linkColor = ifelse(methods::hasArg("linkColor"), list(...)$linkColor, "source-target"),
    nodeAlign = ifelse(methods::hasArg("nodeAlign"), list(...)$nodeAlign, "justify"),
    nodeGroup = ifelse(methods::hasArg("nodeGroup"), list(...)$nodeGroup, "group"),
    nodeWidth = ifelse(methods::hasArg("nodeWidth"), list(...)$nodeWidth, 15),
    nodePadding = ifelse(methods::hasArg("nodePadding"), list(...)$nodePadding, 10),
    nodeLabelPadding = ifelse(methods::hasArg("nodeLabelPadding"), list(...)$nodeLabelPadding, 6),
    nodeLabelFontFamily = ifelse(methods::hasArg("nodeLabelFontFamily"), list(...)$nodeLabelFontFamily, "sans-serif"),
    nodeLabelFontSize = ifelse(methods::hasArg("nodeLabelFontSize"), list(...)$nodeLabelFontSize, 10),
    colors = ifelse(methods::hasArg("color"), list(...)$color, "d3.schemeCategory10")
  )

  r2d3::r2d3(
    data = data,
    options = options,
    script = system.file("sankey_network.js", package = "network.r2d3"),
    dependencies = system.file("lib/d3-sankey/d3-sankey.min.js", package = "network.r2d3"),
    d3_version = 6,
    container = "svg",
    width = width,
    height = height,
    viewer = viewer
  )
}
