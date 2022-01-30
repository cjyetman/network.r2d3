#' Convert one of numerous data types to sankey_network's 'native' data format
#'
#' @param .data a sankey network description in one of numerous forms (see
#' details).
#' @param ... other arguments that will be passed on to as_sankey_data
#'
#' @description
#' The `sankey_network` function uses a 'native' data format that consists of a...
#'
#' @md
#' @export

as_sankey_data <- function(.data, ...) {
  UseMethod("as_sankey_data")
}


#' @describeIn as_sankey_data
#' @export

as_sankey_data.character <- function(.data, ...) {
  if (is_url(.data)) {
    return(as_sankey_data(jsonlite::fromJSON(.data)))
  }

  stop("`data` must be an object or valid URL to a JSON file", call. = FALSE)
}


#' @describeIn as_sankey_data
#' @export

as_sankey_data.data.frame <-
  function(.data, ...) {
    # convert links data frame
    .data <- as_sankey_data_links(.data)

    # build nodes data frame
    nodes <- data.frame(id = unique(c(.data$source, .data$target)), group = 1L)

    return(list(nodes = nodes, links = .data))
  }


#' @describeIn as_sankey_data
#' @export

as_sankey_data.igraph <-
  function(.data, ...) {
    links <- igraph::as_data_frame(.data, "edges")
    nodes <- igraph::as_data_frame(.data, "vertices")

    # find the nodes name column, otherwise assume it's the first
    nodes_name_label <- c("name", "label", "id")
    nodes_name_idx <- first_found_in(tolower(names(nodes)), nodes_name_label, default = 1L)

    nodes$label <- as.character(nodes[[nodes_name_idx]])
    nodes$label[nodes$label == ""] <- seq_along(nodes$label)[nodes$label == ""]

    # hack for tidygraph differences from igraph
    if (is.numeric(links$from) & is.numeric(links$to)) {
      links$from <- as.character(nodes$label[links$from])
      links$to <- as.character(nodes$label[links$to])
    }

    links <- as_sankey_data_links(links)
    nodes <- as_sankey_data_nodes(nodes)

    return(list(nodes = nodes, links = links))
  }


#' @describeIn as_sankey_data
#' @export

as_sankey_data.hclust <-
  function(.data, ...) {
    # convert to a data frame
    clustparents <-
      sapply(seq_along(.data$height), function(i) {
        parent <- which(i == .data$merge)
        parent <- ifelse(parent > nrow(.data$merge),
                         parent - nrow(.data$merge), parent)
        as.integer(ifelse(length(parent) == 0L, NA_integer_, parent))
      })

    leaveparents <-
      sapply(seq_along(.data$labels), function(i) {
        parent <- which(i * -1 == .data$merge)
        parent <- ifelse(parent > nrow(.data$merge), parent -
                           nrow(.data$merge), parent)
        as.integer(ifelse(length(parent) == 0L, NA, parent))
      })

    .data <-
      data.frame(
        source = as.character(c(clustparents, leaveparents)),
        target = c(1:length(.data$height), .data$labels),
        height = c(.data$height, rep(0L, length(.data$labels)))
      )

    return(as_sankey_data(.data))
  }


#' @describeIn as_sankey_data
#' @export

as_sankey_data.dendrogram <-
  function(.data, ...) {
    # convert to hclust
    .data <- stats::as.hclust(.data)

    return(as_sankey_data(.data))
  }


#' @describeIn as_sankey_data
#' @export

as_sankey_data.list <-
  function(.data, ...) {
    if (length(.data) == 1L) {
      return(as_sankey_data(.data[[1L]]))
    }

    if (length(.data) == 2L) {
      # find the 'links' data, otherwise assume it's the first element
      links_names <- c('links', 'edges', 'link', 'edge')
      links_idx <- first_found_in(tolower(names(.data)), links_names, default = 1L)
      links <- as_sankey_data_links(.data[[links_idx]])

      # find the 'nodes' data, otherwise assume it's the second element
      nodes_names <- c('nodes', 'vertices', 'node', 'vertex')
      nodes_idx <- first_found_in(tolower(names(.data)), nodes_names, default = 2L)
      nodes <- as_sankey_data_nodes(.data[[nodes_idx]], ...)

      return(list(nodes = nodes, links = links))
    }

    .data <- list_to_dataframe(.data)
    return(as_sankey_data(.data))
  }
