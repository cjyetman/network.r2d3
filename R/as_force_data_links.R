as_force_data_links <-
  function(.data) {
    if (inherits(.data, "list")) {
      .data <- as_force_data_links.list(.data)
    } else if (inherits(.data, "data.frame")) {
      .data <- as_force_data_links.data.frame(.data)
    }
    .data
  }


as_force_data_links.data.frame <-
  function(.data) {
    # must be a data frame
    if (!inherits(.data, "data.frame")) {
      stop("the data passed to fix_force_links_data.frame must be a data frame")
    }

    # must have at least 2 columns
    if (ncol(.data) < 2) {
      stop("the data frame passed to fix_force_links_data.frame must contain at least two columns")
    }

    # determine the "source" and "target" indices
    source_names <- c("source", "from", "sources", "start", "begin")
    target_names <- c("target", "to", "targets", "stop", "end")

    # find a "source" column, otherwise assume it's the first column
    match_idxs <- match(source_names, tolower(names(.data)))
    source_idx <- match_idxs[!is.na(match_idxs)][1]
    if (is.na(source_idx)) { source_idx <- 1 }

    # find a "target" column, otherwise assume it's the second column
    match_idxs <- match(target_names, tolower(names(.data)))
    target_idx <- match_idxs[!is.na(match_idxs)][1]
    if (is.na(target_idx)) { target_idx <- 2 }

    # set proper names for "source" and "target" columns
    names(.data)[source_idx] <- "source"
    names(.data)[target_idx] <- "target"

    # convert "source" and "target" columns to character
    .data$source <- as.character(.data$source)
    .data$target <- as.character(.data$target)

    .data$source[is.na(.data$source)] <- "NA"
    .data$target[is.na(.data$target)] <- "NA"

    # .data <- jsonlite::fromJSON(jsonlite::toJSON(.data, pretty = TRUE), simplifyDataFrame = FALSE)

    format_force_data_link_data_frame(.data)
  }


as_force_data_links.list <-
  function(.data) {
    list_json <- jsonlite::toJSON(.data, auto_unbox = TRUE)
    list_df <- jsonlite::fromJSON(list_json)

    # convert "source" and "target" columns to character
    .data$source <- as.character(.data$source)
    .data$target <- as.character(.data$target)

    .data$source[is.na(.data$source)] <- "NA"
    .data$target[is.na(.data$target)] <- "NA"

    format_force_data_link_data_frame(list_df)
  }
