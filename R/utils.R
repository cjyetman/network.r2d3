add_tbl_class <-
  function(.data) {
    if (requireNamespace("tibble", quietly = TRUE) &&
        inherits(x = .data, what = "data.frame")) {
      return(tibble::as_tibble(.data))
    }
    .data
  }


first_found_in <-
  function(.x, domain, default = NA_character_) {
    .out <- domain[domain %in% .x][1L]
    if (is.na(.out)) { .out <- default }
    .out
  }


index_of_first_found_in <-
  function(.x, domain, default = NA_integer_) {
    .out <- first_found_in(.x, domain)
    if (is.na(.out)) { return(default) }
    which(.x == .out)
  }


list_to_dataframe <-
  function(.data) {
    .data <- jsonlite::toJSON(.data, auto_unbox = TRUE)
    jsonlite::fromJSON(.data)
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


format_sankey_data_link_data_frame <-
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

is_url <- function(path) {
  grepl("^((http|ftp)s?|sftp)://", path)
}

