#' Create an interactive tree network plot in an htmlwidget
#'
#' @param data a tree network description in one of numerous forms (see
#' details)
#' @param width width of exported htmlwidget in pixels (single integer value; default == NULL)
#' @param height height of exported htmlwidget in pixels (single integer value; default == NULL)
#' @param treeType type of tree; one of "tidy" or "cluster" (see details) (default == "tidy")
#' @param direction direction toward which the tree grows; one of "right", "left", "down", or "up" (see details) (default == "right")
#' @param linkType type on link shape; one of "diagonal" or "elbow" (see details) (default == "diagonal")
#' @param ... other options (see details)
#'
#' @description
#' The `treeNetwork` function creates an interactive tree network plot in an htmlwidget
#'
#' @examples
#' treedf <- data.frame(nodeId = LETTERS[1:7],
#'                      parentId = c("", "A", "A", "B", "B", "C", "C"),
#'                      name = LETTERS[1:7],
#'                      stringsAsFactors = FALSE)
#' treeNetwork(treedf)
#'
#' @md
#' @export
treeNetwork <- function(data, width = NULL, height = NULL, treeType = 'tidy',
                        direction = 'right', linkType = 'diagonal', ...) {
  data <- as_tree_data(data)

  default <- function(defaults = NULL) {
    defaults_ <-
      list(
        nodeSize = 10,
        nodeStroke = 'steelblue',
        nodeColor = 'steelblue',
        nodeSymbol = 'circle',
        nodeFont = 'sans-serif',
        nodeFontSize = 12,
        textColor = 'grey',
        textOpacity = 1,
        linkColor = 'grey',
        linkWidth = '1.5px'
      )
    if (missing(defaults)) {
      return(defaults_)
    } else {
      defaults <- as.list(defaults)
      names(defaults) <- sub('Colour$', 'Color', names(defaults))
      return(c(defaults, defaults_[!names(defaults_) %in% names(defaults)]))
    }
  }

  defaults <- default(list(...))

  for(i in 1:length(defaults)) {
    if (! names(defaults)[i] %in% names(data)) {
      data[names(defaults)[i]] <- defaults[i]
    }
  }

  options <- list(treeType = treeType, direction = direction,
                  linkType = linkType)

  data <- jsonlite::toJSON(data, null = "null", na = "null", auto_unbox = TRUE,
                           digits = getOption("shiny.json.digits", 16),
                           use_signif = TRUE, force = TRUE, POSIXt = "ISO8601",
                           UTC = TRUE, rownames = FALSE, keep_vec_names = TRUE,
                           json_verabitm = TRUE)

  r2d3::r2d3(
    data = data,
    options = options,
    script = system.file("d3/treeNetwork.js", package = "network.r2d3"),
    d3_version = 4,
    width = width,
    height = height
  )
}
