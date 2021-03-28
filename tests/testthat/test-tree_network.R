test_default_characteristics <-
  function(data) {
    script_line <- grep("^[/][*] R2D3 Source File: ", strsplit(data$x$script, "\n")[[1]], value = TRUE)
    expect_s3_class(data, "r2d3")
    expect_s3_class(data, "htmlwidget")
    expect_true(grepl("tree_network[.]js", script_line))
  }


test_that("tree_network() svg output", {
  example <- data.frame(source = c(NA, rep(1L, 3L)),
                        target = 1L:4L,
                        name = LETTERS[1L:4L])
  d3 <- tree_network(example)
  svg_path <- save_as_svg(d3, filepath = tempfile(), delay = 1)
  expect_snapshot_file(svg_path, "test_tree.svg")
})


test_that("tree_network() outputs an htmlwidget using tree_network.js and with the original data from a data frame", {
  example_df <- data.frame(source = c(NA, rep(1L, 2L)),
                           target = 1L:3L,
                           name = LETTERS[1L:3L])
  tn <- tree_network(example_df)
  exported_data <- jsonlite::fromJSON(tn$x$data)
  test_default_characteristics(tn)
  expect_equal(exported_data$nodeId, example_df$target)
  expect_equal(exported_data$parentId, example_df$source)
})


test_that("tree_network() outputs an htmlwidget using tree_network.js and with the original data from a list", {
  treelist <- list(name = "a", children = list(list(name = "b"), list(name = "c")))
  tn <- tree_network(treelist)
  exported_data <- jsonlite::fromJSON(tn$x$data)
  test_default_characteristics(tn)
  expect_equal(exported_data$nodeId, c("a", "a:b", "a:c"))
  expect_equal(exported_data$parentId, c(NA, "a", "a"))
})
