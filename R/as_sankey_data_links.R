as_sankey_data_links <-
  function(.data) {
    if (inherits(.data, "list")) {
      .data <- as_sankey_data_links.list(.data)
    } else if (inherits(.data, "data.frame")) {
      .data <- as_sankey_data_links.data.frame(.data)
    }
    .data
  }


as_sankey_data_links.data.frame <-
  function(.data) {
    # must be a data frame
    if (!inherits(.data, "data.frame")) {
      stop("the data passed to as_sankey_data_links.data.frame must be a data frame")
    }

    # must have at least 2 columns
    if (ncol(.data) < 2) {
      stop("the data frame passed to as_sankey_data_links.data.frame must contain at least two columns")
    }

    # determine the "source" and "target" indices
    source_names <- c("source", "from", "sources", "start", "begin")
    target_names <- c("target", "to", "targets", "stop", "end")

    # find a "source" column, otherwise assume it's the first column
    source_idx <- index_of_first_found_in(tolower(names(.data)), domain = source_names, default = 1L)

    # find a "target" column, otherwise assume it's the second column
    target_idx <- index_of_first_found_in(tolower(names(.data)), domain = target_names, default = 2L)

    # set proper names for "source" and "target" columns
    names(.data)[source_idx] <- "source"
    names(.data)[target_idx] <- "target"

    .data$source[is.na(.data$source)] <- "NA"
    .data$target[is.na(.data$target)] <- "NA"

    format_sankey_data_link_data_frame(.data)
  }


as_sankey_data_links.list <-
  function(.data) {
    list_df <- list_to_dataframe(.data)
    format_sankey_data_link_data_frame(list_df)
  }
