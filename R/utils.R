add_tbl_class <-
  function(.data) {
    if (inherits(x = .data, what = "data.frame")) {
      class(.data) <- c("tbl", class(.data))
    }
    .data
  }

format_force_data_link_data_frame <-
  function(.data) {
    stopifnot(inherits(x = .data, what = "data.frame"))

    needed_names <- c("source", "target")
    .data_names <- names(.data)

    stopifnot(all(needed_names %in% .data_names))

    .out_names <- c(needed_names, .data_names[!.data_names %in% needed_names])
    .data <- .data[, .out_names]

    .data$source <- as.character(.data$source)
    .data$target <- as.character(.data$target)

    .data <- add_tbl_class(.data)

    .data
  }
