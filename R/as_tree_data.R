#' Convert one of numerous data types to tree_network's 'native' treenetdf form
#'
#' @param data a tree network description in one of numerous forms (see
#' details).
#' @param ... other arguments that will be passed on to as_tree_data
#'
#' @description
#' The `tree_network` function uses a 'native' data format that consists of a data
#' frame with minimally 2 vectors/columns, one named `'nodeId'` and one named
#' `'parentId'`. Other columns in the data frame are also passed on to the
#' JavaScript code and attached to the elements in the D3 visualization so that
#' they can potentially be accessed by other JavaScript functions. This is an
#' advantageous format because:
#' - it's an easy to use and understand R-like format
#' - a hierarchical network can be succinctly defined by a list of each unique
#' node and its parent node
#' - since each row defines a unique node, additional columns can be added to
#' add node-specific properties
#' - in a hierarchical network, every link/edge can be uniquely identified by
#' the node which it leads to, therefore each link/edge can also be specifically
#' addressed by adding columns for formatting of the incoming link
#'
#' `as_tree_data` can convert from any of the following data types:
#' - `leafpathdf` (table)--`parent|parent|node`--`data.frame`
#' - hierarchical nested list (JSON)
#' - `hclust`
#' - `data.tree` Node
#' - igraph
#' - ape `phylo`
#'
#' @examples
#' links <- read.csv(header = TRUE, stringsAsFactors = FALSE, text = '
#'                    source,target,name
#'                    1,,one
#'                    2,1,two
#'                    3,1,three
#'                    4,1,four
#'                    5,2,five
#'                    6,2,six
#'                    7,2,seven
#'                    8,6,eight')
#'
#'  # Convert data
#'  as_tree_data(links, cols = c(nodeId = 'source', parentId = 'target'))
#'
#' @md
#' @export

as_tree_data <- function(data, ...) {
  UseMethod("as_tree_data")
}


#########################################################################
#' @describeIn as_tree_data Convert JSON from URL to \code{treenetdf}
#' @export

as_tree_data.character <- function(data, ...) {
  if (is_url(data)) {
    return(as_tree_data(jsonlite::fromJSON(data, simplifyVector = FALSE)))
  }

  stop("`data` must be an object or valid URL to a JSON file", call. = FALSE)
}


#########################################################################
#' @describeIn as_tree_data Convert hclust objects to \code{treenetdf}
#' @export

as_tree_data.hclust <- function(data, ...) {
  clustparents <-
    unlist(sapply(seq_along(data$height), function(i) {
      parent <- which(i == data$merge)
      parent <- ifelse(parent > nrow(data$merge),
                       parent - nrow(data$merge), parent)
      as.integer(ifelse(length(parent) == 0, NA_integer_, parent))
    }))

  leaveparents <-
    unlist(sapply(seq_along(data$labels), function(i) {
      parent <- which(i * -1 == data$merge)
      parent <- ifelse(parent > nrow(data$merge), parent -
                         nrow(data$merge), parent)
      as.integer(ifelse(length(parent) == 0, NA, parent))
    }))

  df <-
    data.frame(
      nodeId = 1:(length(data$height) + length(data$labels)),
      parentId = c(clustparents, leaveparents),
      name = c(rep('', length(data$height)), data$labels),
      height = c(data$height, rep(0, length(data$labels)))
    )

  if (requireNamespace("tibble", quietly = TRUE)) {
    return(tibble::as_tibble(df))
  }
  return(df)
}


#########################################################################
#' @describeIn as_tree_data Convert a nested list to \code{treenetdf}
#' @param children_name character specifying the name used for the list element
#' that contains the childeren elements.
#' @param node_name character specifying the name used for the list element that
#' contains the name of the node
#' @export

as_tree_data.list <- function(data, children_name = 'children',
                              node_name = 'name', ...) {
  makelistofdfs <- function(data) {
    children <- data[[children_name]]
    children <-
      lapply(children, function(child) {
        if ('parentId' %in% names(data)) {
          child$parentId <- paste0(data$parentId, ':', data[[node_name]])
        } else {
          child$parentId <- data[[node_name]]
        }
        if ('nodeId' %in% names(data)) {
          child$nodeId <- paste0(data$nodeId, ':', child[[node_name]])
        } else {
          child$nodeId <- paste0(data[[node_name]], ':',
                                 child[[node_name]])
        }
        return(child)
      })

    if (length(children) == 0)
      return(list(data[names(data)[!names(data) %in% children_name]]))

    c(list(data[names(data)[!names(data) %in% children_name]]),
      unlist(recursive = FALSE, lapply(children, makelistofdfs)))
  }

  listoflists <- makelistofdfs(data)
  col_names <- unique(unlist(sapply(listoflists, names)))
  matrix <-
    sapply(col_names, function(col_name) {
      unlist(
        sapply(listoflists, function(x) {
          ifelse(col_name %in% names(x),
                 x[col_name],
                 list(col_name = NA))
        })
      )
    })

  df <- data.frame(matrix, stringsAsFactors = F)
  df$nodeId[is.na(df$nodeId)] <- df[[node_name]][is.na(df$nodeId)]

  if (requireNamespace("tibble", quietly = TRUE)) {
    return(tibble::as_tibble(df))
  }
  return(df)
}


#########################################################################
#' @describeIn as_tree_data data.tree to \code{treenetdf}
#' @export

as_tree_data.Node <-  function(data, ...) {
  if (!requireNamespace("data.tree", quietly = TRUE)) {
    stop('The "data.tree" package is needed for as_tree_data.Node() to work', call. = FALSE)
  }
  df <- do.call(data.tree::ToDataFrameNetwork,
                c(data, direction = 'descend', data$attributesAll))
  names(df)[1:2] <- c('nodeId', 'parentId')
  rootId <- unique(df$parentId[! df$parentId %in% df$nodeId])
  df <- rbind(c(nodeId = rootId, parentId = NA, rep(NA, ncol(df) - 2)), df)
  df$name <- df$nodeId

  if (requireNamespace("tibble", quietly = TRUE)) {
    return(tibble::as_tibble(df))
  }
  return(df)
}


#########################################################################
#' @describeIn as_tree_data Phylo tree to \code{treenetdf}
#' @export

as_tree_data.phylo <- function(data, ...) {
  df <- data.frame(nodeId = data$edge[, 2],
                   parentId = data$edge[, 1],
                   name = data$tip.label[data$edge[, 2]],
                   edge.length = data$edge.length,
                   depth = NA,
                   stringsAsFactors = FALSE)

  rootId <- unique(df$parentId[! df$parentId %in% df$nodeId])

  calc_height <- function(parentId) {
    childIdxs <- df$parentId == parentId
    childIds <- df$nodeId[childIdxs]

    parentHeight <- df$depth[df$nodeId == parentId]
    if (length(parentHeight) == 0) { parentHeight <- 0 }
    df$depth[childIdxs] <<- df$edge.length[childIdxs] + parentHeight

    if (length(childIds) > 0) { lapply(childIds, calc_height) }
    invisible(df)
  }
  df <- calc_height(rootId)

  df$height <- max(df$depth) - df$depth
  df <- rbind(c(nodeId = rootId, parentId = NA, name = NA, edge.length = 0,
                depth = 0, height = max(df$depth)), df)

  if (requireNamespace("tibble", quietly = TRUE)) {
    return(tibble::as_tibble(df))
  }
  return(df)
}


#########################################################################
#' @describeIn as_tree_data tbl_graph_to_treenetdf
#' @export

as_tree_data.tbl_graph <- function(data, ...) {
  as_tree_data.igraph(data)
}


#########################################################################
#' @describeIn as_tree_data Convert igraph tree to \code{treenetdf}
#' @param root character specifying the string that should be used to name the
#' root node
#' @export

as_tree_data.igraph <- function(data, root = 'root', ...) {
  if (!requireNamespace("igraph", quietly = TRUE)) {
    stop('The "igraph," package is needed for as_tree_data.igraph() to work', call. = FALSE)
  }
  df <- igraph::as_data_frame(data)
  names(df)[1:2] <- c('nodeId', 'parentId')
  rootId <- unique(df$parentId[! df$parentId %in% df$nodeId])
  if (length(rootId) > 1) {
    rootdf <- Reduce(function(x, y) {
      rbind(x, c(nodeId = y, parentId = root,
                 stats::setNames(rep(NA, length(names(df)) - 2), names(df)[-(1:2)])))
    }, rootId, c(nodeId = root, parentId = NA,
                 stats::setNames(rep(NA, length(names(df)) - 2),
                          names(df)[-(1:2)])))
    df <- rbind(rootdf, df, stringsAsFactors = F, make.row.names = FALSE)
    df$name <- df$nodeId
    df$name[1] <- NA
  } else {
    rootdf <- c(nodeId = rootId, parentId = NA, rep(NA, ncol(df) - 2))
    df <- rbind(rootdf, df, stringsAsFactors = F, make.row.names = FALSE)
    df$name <- df$nodeId
  }

  if (requireNamespace("tibble", quietly = TRUE)) {
    return(tibble::as_tibble(df))
  }
  return(df)
}


#########################################################################
#' @describeIn as_tree_data Convert a data.frame to a \code{treenetdf}
#' @param cols named character vector specifying the names of columns to be
#' converted to the standard \code{treenetdf} names.
#' @param df_type character specifying which type of data frame to convert. Can
#' be \code{treenetdf} or
#' \code{leafpathdf}.
#' @param subset character vector specifying the names of the columns (in order)
#' that should be used to define the hierarchy.
#' @param root root name.
#' @export

as_tree_data.data.frame <- function(data,
                                    cols = NULL,
                                    df_type = 'treenetdf',
                                    subset = names(data),
                                    root, ...) {
  if (df_type == 'treenetdf') {
    if (!is.null(cols)) {
      stopifnot(all(cols %in% names(data)))

      nodeId_idx <- which(names(data) == cols[["nodeId"]])
      names(data)[nodeId_idx] <- "nodeId"
      data <- data[c(nodeId_idx, setdiff(1L:length(data), nodeId_idx))]

      parentId_idx <- which(names(data) == cols[["parentId"]])
      names(data)[parentId_idx] <- "parentId"
      data <- data[c(1, parentId_idx, setdiff(2L:length(data), parentId_idx))]
    } else {
      nodeId_names <- c("nodeId", "target")
      nodeId_idx <- index_of_first_found_in(names(data), domain = nodeId_names, default = 1L)
      names(data)[nodeId_idx] <- "nodeId"
      data <- data[c(nodeId_idx, setdiff(1L:length(data), nodeId_idx))]

      parentId_names <- c("parentId", "source")
      parentId_idx <- index_of_first_found_in(names(data), domain = parentId_names, default = 2L)
      names(data)[parentId_idx] <- "parentId"
      data <- data[c(1, parentId_idx, setdiff(2L:length(data), parentId_idx))]
    }

    if (any(is.na(data[-1, ]))) # assumes root is in first row
      warning("Missing values found in data. May cause graph to fail.",
              call. = FALSE)

    if (requireNamespace("tibble", quietly = TRUE)) {
      return(tibble::as_tibble(data))
    }
    return(data)

  } else if (df_type == 'leafpathdf') {
    # get root name from name of passed data.frame, even if it was subset in the
    # argument, unless explicitly set
    if (missing(root)) {
      root <- all.names(substitute(data))
      if (length(root) > 1) {
        root <- root[2]
      }
    }

    # subset the data by cols (default, same as it is)
    data <- data[, subset]

    # add a root col if necessary, otherwise reset root from the data
    if (length(unique(data[[1]])) != 1) {
      data <- data.frame(root, data, stringsAsFactors = F)
    } else {
      root <- unique(data[[1]])
    }

    nodelist <-
      c(stats::setNames(root, root),
        unlist(
          sapply(2:ncol(data), function(i) {
            subdf <- unique(data[, 1:i])
            sapply(1:nrow(subdf), function(i)
              stats::setNames(paste(subdf[i, ], collapse = '::'),
                       rev(subdf[i, ])[1]))
          })
        )
      )

    nodeId <- seq_along(nodelist)
    name <- names(nodelist)
    parentId <-
      c(NA_integer_,
        match(
          sapply(nodelist[-1], function(x) {
            elms <- strsplit(x, '::')[[1]]
            paste(elms[1:max(length(elms) - 1)], collapse = '::')
          }),
          nodelist
        )
      )

    if (requireNamespace("tibble", quietly = TRUE)) {
      return(tibble::tibble(nodeId = nodeId, parentId = parentId, name = name))
    }
    return(data.frame(nodeId = nodeId, parentId = parentId, name = name,
                      stringsAsFactors = F))
  }
}
