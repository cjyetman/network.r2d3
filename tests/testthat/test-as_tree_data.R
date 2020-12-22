test_default_characteristics <-
  function(.data) {
    expect_s3_class(.data, "data.frame")
    expect_s3_class(.data, "tbl")
    expect_gte(ncol(.data), 2L)
    expect_true(all(c("nodeId", "parentId") %in% names(.data)))
    # expect_identical(c("nodeId", "parentId"), names(.data)[1:2])
    expect_true(all(vapply(.data, is.atomic, logical(1))))
    # expect_type(.data[[1L]], "integer")
    # expect_type(.data[[2L]], "integer")
  }


test_that("as_tree_data() can properly process an hclust object", {
  hc <- hclust(dist(USArrests), "ave")
  result <- as_tree_data(hc)
  test_default_characteristics(result)
  expect_true(all(c("name", "height") %in% names(result)))
  expect_type(result$name, "character")
  expect_type(result$height, "double")
})


test_that("as_tree_data() can properly process a nested list", {
  example <- list(name = "A", children = list(list(name = "B"), list(name = "C")))
  result <- as_tree_data(example)
  test_default_characteristics(result)
})


test_that("as_tree_data() can properly process a data.tree::Node object", {
  root <- data.tree::Node$new("myroot", myname = "I'm the root")
  root$AddChild("child1", myname = "I'm the favorite child")
  child2 <- root$AddChild("child2", myname = "I'm just another child")
  child3 <- child2$AddChild("child3", myname = "Grandson of a root!")
  result <- as_tree_data(root)
  test_default_characteristics(result)
})


test_that("as_tree_data() can properly process a data.tree::Node object", {
  s <- "owls(((Strix_aluco:4.2,Asio_otus:4.2):3.1,Athene_noctua:7.3):6.3,Tyto_alba:13.5);"
  tree.owls <- ape::read.tree(text = s)
  result <- as_tree_data(tree.owls)
  test_default_characteristics(result)
})


test_that("as_tree_data() can properly process a tbl_graph object", {
  karate <- igraph::make_graph("Zachary")
  karate <- tidygraph::as_tbl_graph(karate)
  result <- as_tree_data(karate)
  test_default_characteristics(result)
})


test_that("as_tree_data() can properly process an igraph object", {
  karate <- igraph::make_graph("Zachary")
  result <- as_tree_data(karate)
  test_default_characteristics(result)
})


test_that("as_tree_data() can properly process a data.frame object in a treenetdf form", {
  example <- data.frame(nodeId = 1L:4L,
                        parentId = c(NA, rep(1L, 3L)),
                        name = LETTERS[1L:4L])
  result <- as_tree_data(example)
  test_default_characteristics(result)
})


test_that("as_tree_data() can properly process a data.frame object in a treenetdf form but with different names and order", {
  example <- data.frame(source = c(NA, rep(1L, 3L)),
                        target = 1L:4L,
                        name = LETTERS[1L:4L])
  result <- as_tree_data(example)
  test_default_characteristics(result)
})


test_that("as_tree_data() can properly process a data.frame object in a treenetdf form with custom names", {
  example <- data.frame(start = c(NA, rep(1L, 3L)),
                        end = 1L:4L,
                        name = LETTERS[1L:4L])
  result <- as_tree_data(example, cols = c(nodeId = "end", parentId = "start"))
  test_default_characteristics(result)
})
