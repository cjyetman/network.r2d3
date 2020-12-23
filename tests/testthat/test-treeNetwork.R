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


test_default_characteristics <-
  function(.data) {
    script_line <- grep("^[/][*] R2D3 Source File: ", strsplit(.data$x$script, "\n")[[1]], value = TRUE)
    expect_s3_class(.data, "r2d3")
    expect_s3_class(.data, "htmlwidget")
    expect_true(grepl("treeNetwork[.]js", script_line))
  }


test_that("treeNetwork() svg output", {
  example <- data.frame(source = c(NA, rep(1L, 3L)),
                        target = 1L:4L,
                        name = LETTERS[1L:4L])
  d3 <- treeNetwork(example)

  expect_true(test_against_baseline_svg(d3, "example-data/basic_tree_svg.txt"))
})


test_that("treeNetwork() outputs an htmlwidget using treeNetwork.js and with the original data from a data frame", {
  example_df <- data.frame(source = c(NA, rep(1L, 2L)),
                           target = 1L:3L,
                           name = LETTERS[1L:3L])
  tn <- treeNetwork(example_df)
  exported_data <- jsonlite::fromJSON(tn$x$data)
  test_default_characteristics(tn)
  expect_equal(exported_data$nodeId, example_df$target)
  expect_equal(exported_data$parentId, example_df$source)
})


test_that("treeNetwork() outputs an htmlwidget using treeNetwork.js and with the original data from a list", {
  treelist <- list(name = "a", children = list(list(name = "b"), list(name = "c")))
  tn <- treeNetwork(treelist)
  exported_data <- jsonlite::fromJSON(tn$x$data)
  test_default_characteristics(tn)
  expect_equal(exported_data$nodeId, c("a", "a:b", "a:c"))
  expect_equal(exported_data$parentId, c(NA, "a", "a"))
})
