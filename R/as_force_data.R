as_force_data <- function(.data, ...) {
  if (inherits(.data, "list")) {
    .data <- as_force_data.list(.data, ...)
  } else if (inherits(.data, "data.frame")) {
    .data <- as_force_data.data.frame(.data)
  } else if (inherits(.data, "hclust")) {
    .data <- as_force_data.hclust(.data)
  } else if (inherits(.data, "dendrogram")) {
    .data <- as_force_data.dendrogram(.data)
  } else if (inherits(.data, "igraph")) {
    .data <- as_force_data.igraph(.data)
  }
  .data
}


as_force_data.data.frame <-
  function(.data) {
    # convert links data frame
    .data <- as_force_data_links(.data)

    # build nodes data frame
    nodes <- data.frame(id = unique(c(.data$source, .data$target)), group = 1L)

    return(list(nodes = nodes, links = .data))
  }


as_force_data.igraph <-
  function(.data) {
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

    links <- as_force_data_links(links)
    nodes <- as_force_data_nodes(nodes)

    return(list(nodes = nodes, links = links))
  }


as_force_data.hclust <-
  function(.data) {
    # convert to a data frame
    clustparents <-
      sapply(seq_along(.data$height), function(i) {
        parent <- which(i == .data$merge)
        parent <- ifelse(parent > nrow(.data$merge),
                         parent - nrow(.data$merge), parent)
        as.integer(ifelse(length(parent) == 0, NA_integer_, parent))
      })

    leaveparents <-
      sapply(seq_along(.data$labels), function(i) {
        parent <- which(i * -1 == .data$merge)
        parent <- ifelse(parent > nrow(.data$merge), parent -
                           nrow(.data$merge), parent)
        as.integer(ifelse(length(parent) == 0, NA, parent))
      })

    .data <-
      data.frame(
        source = as.character(c(clustparents, leaveparents)),
        target = c(1:length(.data$height), .data$labels),
        height = c(.data$height, rep(0, length(.data$labels)))
      )

    return(as_force_data(.data))
  }


as_force_data.dendrogram <-
  function(.data) {
    # convert to hclust
    .data <- stats::as.hclust(.data)

    return(as_force_data(.data))
  }


as_force_data.list <-
  function(.data, ...) {
    if (length(.data) == 1) {
      return(as_force_data(.data[[1]]))
    }

    if (length(.data) == 2) {
      # find the 'links' data, otherwise assume it's the first element
      links_names <- c('links', 'edges', 'link', 'edge')
      links_idx <- first_found_in(tolower(names(.data)), links_names, default = 1L)
      links <- as_force_data_links(.data[[links_idx]])

      # find the 'nodes' data, otherwise assume it's the second element
      nodes_names <- c('nodes', 'vertices', 'node', 'vertex')
      nodes_idx <- first_found_in(tolower(names(.data)), nodes_names, default = 2L)
      nodes <- as_force_data_nodes(.data[[nodes_idx]], ...)

      return(list(nodes = nodes, links = links))
    }

    .data <- list_to_dataframe(.data)
    return(as_force_data(.data))
  }
