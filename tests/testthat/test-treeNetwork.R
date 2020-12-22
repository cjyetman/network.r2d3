test_against_baseline_svg <-
  function(widget, example) {
    tmp_html <- tempfile(fileext = ".html")
    r2d3::save_d3_html(widget, file = tmp_html, background = "white")

    b <- chromote::ChromoteSession$new()
    b$Page$navigate(paste0("file://", normalizePath(tmp_html, winslash = "/")))
    eval <-
      paste0(
        "var el = document.getElementById('htmlwidget_container').firstElementChild;\n",
        "el.shadowRoot === null ? el.innerHTML : el.shadowRoot.innerHTML;"
      )
    Sys.sleep(1.5)
    svg <- b$Runtime$evaluate(eval)$result$value
    b$close()
    svg_check <- readLines(example)
    identical(svg, svg_check)
  }


test_that("treeNetwork() svg output", {
  example <- data.frame(source = c(NA, rep(1L, 3L)),
                        target = 1L:4L,
                        name = LETTERS[1L:4L])
  d3 <- treeNetwork(example)

  expect_true(test_against_baseline_svg(d3, "example-data/basic_tree_svg.txt"))
})
