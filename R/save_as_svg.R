#' Save a SVG screenshot of a htmlwidget
#'
#' @param widget a htmlwidget
#' @param filepath a filepath where to save the file
#' @param background the background color underneath/behind the htmlwidget
#' @param delay a delay (in seconds) to wait before taking the screenshot
#'
#' @description
#' The `save_as_svg` function takes a screenshot of a htmlwidget as a SVG image.
#'
#' @md
#' @export

save_as_svg <-
  function(widget, filepath, background = "white", delay = 0.5) {
    if (!requireNamespace("chromote", quietly = TRUE)) {
      stop("chromote package required for `save_as_svg()` function", call. = FALSE)
    }

    tmp_html <- tempfile(fileext = ".html")
    on.exit(unlink(tmp_html))
    r2d3::save_d3_html(widget, file = tmp_html, background = background)

    b <- chromote::ChromoteSession$new()
    b$Page$navigate(paste0("file://", normalizePath(tmp_html, winslash = "/")))
    Sys.sleep(delay)

    eval <-
      paste0(
        'var svg_node = document.querySelector("div#htmlwidget_container :first-child").shadowRoot.firstChild;\n',
        'new XMLSerializer().serializeToString(svg_node);'
      )
    svg <- b$Runtime$evaluate(eval)$result$value

    b$close()

    writeLines(svg, filepath)
    invisible(filepath)
  }
