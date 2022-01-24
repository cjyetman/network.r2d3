#' Save a PNG screenshot of a htmlwidget
#'
#' @param widget a htmlwidget
#' @param filepath a filepath where to save the file
#' @param background the background color underneath/behind the htmlwidget
#' @param delay a delay (in seconds) to wait before taking the screenshot
#'
#' @description
#' The `save_as_png` function takes a screenshot of a htmlwidget as a PNG image.
#'
#' @md
#' @export

save_as_png <-
  function(widget, filepath, background = "white", delay = 0.5) {
    if (!requireNamespace("chromote", quietly = TRUE)) {
      stop("chromote package required for `save_as_png()` function", call. = FALSE)
    }

    tmp_html <- tempfile(fileext = ".html")
    on.exit(unlink(tmp_html))
    r2d3::save_d3_html(widget, file = tmp_html, background = background)

    b <- chromote::ChromoteSession$new()
    b$Page$navigate(paste0("file://", normalizePath(tmp_html, winslash = "/")))
    Sys.sleep(delay)

    b$screenshot(
      filename = filepath,
      selector = "div#htmlwidget_container :first-child",
      cliprect = NULL,
      region = c("content", "padding", "border", "margin"),
      expand = NULL,
      scale = 1,
      show = FALSE,
      wait_ = TRUE
    )

    b$close()

    invisible(filepath)
  }
