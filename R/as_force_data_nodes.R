as_force_data_nodes <-
  function(.data, ...) {
    if (inherits(.data, "list")) {
      .data <- as_force_data_nodes.list(.data, ...)
    } else if (inherits(.data, "data.frame")) {
      .data <- as_force_data_nodes.data.frame(.data, ...)
    }
    .data
  }


as_force_data_nodes.data.frame <-
  function(.data, ...) {
    # must be a data frame
    if (!inherits(.data, "data.frame")) {
      stop("the data passed to as_force_data_nodes.data.frame must be a data frame")
    }

    # save any optional arguments
    optional_args <- list(...)

    # find an "id" column, otherwise assume it's the first column
    id_names <- c("id",
                  "names",
                  "nodes",
                  "labels",
                  "vertices",
                  "name",
                  "node",
                  "label",
                  "vertex")

    id_idx <- index_of_first_found_in(tolower(names(.data)), domain = id_names, default = 1L)

    # set the name of the node id variable to "id"
    names(.data)[id_idx] <- "id"

    # find a "group" column, otherwise make one
    if ("group" %in% names(optional_args) && optional_args$group %in% names(.data)) {
      group_idx <- which(names(.data) == optional_args$group)
    } else {
      group_names <- c("group", "groups")
      group_idx <- index_of_first_found_in(tolower(names(.data)), domain = group_names)
    }

    if (is.na(group_idx)) {
      group_idx <- ncol(.data) + 1
      .data$group <- 1
    } else {
      names(.data)[group_idx] <- "group"
    }

    resort_idxs <- c(id_idx, group_idx, setdiff(seq_along(.data), c(id_idx, group_idx)))
    .data <- .data[resort_idxs]

    # convert "id" and "group" columns to character
    .data$id <- as.character(.data$id)
    .data$group <- as.character(.data$group)

    .data$id[is.na(.data$id)] <- "NA"
    .data$group[is.na(.data$group)] <- "NA"

    .data <- add_tbl_class(.data)

    .data
  }


as_force_data_nodes.list <-
  function(.data, ...) {
    .data <- list_to_dataframe(.data)
    .data <- as_force_data_nodes.data.frame(.data, ...)
    .data
  }
