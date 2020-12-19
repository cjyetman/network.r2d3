test_deafult_characteristics <-
  function(.data) {
    expect_type(.data, "list")
    expect_equal(length(.data), 2L)

    nodes <- .data[[1]]
    expect_s3_class(nodes, "data.frame")
    expect_gte(ncol(nodes), 2L)
    expect_identical(c("id", "group"), names(nodes)[1:2])
    expect_true(all(vapply(nodes, is.atomic, logical(1))))
    expect_type(nodes[[1]], "character")

    links <- .data[[2]]
    expect_s3_class(links, "data.frame")
    expect_s3_class(links, "tbl")
    expect_gte(ncol(links), 2L)
    expect_identical(c("source", "target"), names(links)[1:2])
    expect_true(all(vapply(links, is.atomic, logical(1))))
    expect_type(links[[1]], "character")
    expect_type(links[[2]], "character")
  }


test_that("as_force_data() can process a list of lists", {
  data_list <- jsonlite::read_json('example-data/miserables.json')
  result <- as_force_data(data_list)

  test_deafult_characteristics(result)
})


test_that("as_force_data() can process a list of data frames", {
  data_list_df <- jsonlite::read_json('example-data/miserables.json', simplifyVector = TRUE)
  result <- as_force_data(data_list_df)

  test_deafult_characteristics(result)
})


test_that("as_force_data() can process a list of links data", {
  data_list <- jsonlite::read_json('example-data/miserables.json')
  links_list <- data_list$links
  result <- as_force_data(links_list)

  test_deafult_characteristics(result)
})


test_that("as_force_data() can process a data frame of links data", {
  data_list_df <- jsonlite::read_json('example-data/miserables.json', simplifyVector = TRUE)
  links_df <- data_list_df$links
  result <- as_force_data(links_df)

  test_deafult_characteristics(result)
})


test_that("as_force_data() can process an hclust", {
  hc <- hclust(dist(USArrests), "ave")
  result <- as_force_data(hc)

  test_deafult_characteristics(result)
})


test_that("as_force_data() can process an dendogram", {
  hc <- hclust(dist(USArrests), "ave")
  dhc <- as.dendrogram(hc)
  result <- as_force_data(dhc)

  test_deafult_characteristics(result)
})


test_that("as_force_data() can process an igraph object", {
  data_list_df <- jsonlite::read_json('example-data/miserables.json', simplifyVector = TRUE)
  links_df <- data_list_df$links
  igraph_obj <- igraph::graph_from_data_frame(links_df)
  result <- as_force_data(igraph_obj)

  test_deafult_characteristics(result)
})


test_that("as_force_data() can process an igraph object with group information", {
  data_list_df <- jsonlite::read_json('example-data/miserables.json', simplifyVector = TRUE)
  links_df <- data_list_df$links
  nodes_df <- data_list_df$nodes
  igraph_obj <- igraph::graph_from_data_frame(links_df, vertices = nodes_df)
  result <- as_force_data(igraph_obj, group = "group")

  test_deafult_characteristics(result)
  expect_gt(length(unique(result$nodes$group)), 1L)
})


test_that("as_force_data() can process an tidygraph object", {
  data_list_df <- jsonlite::read_json('example-data/miserables.json', simplifyVector = TRUE)
  links_df <- data_list_df$links
  tidygraph_obj <- tidygraph::as_tbl_graph(links_df)
  result <- as_force_data(tidygraph_obj)

  test_deafult_characteristics(result)
})


test_that("as_force_data() can process an tidygraph object with group information", {
  data_list_df <- jsonlite::read_json('example-data/miserables.json', simplifyVector = TRUE)
  links_df <- data_list_df$links
  nodes_df <- data_list_df$nodes
  tidygraph_obj <- tidygraph::tbl_graph(nodes = nodes_df, edges = links_df)
  result <- as_force_data(tidygraph_obj)

  test_deafult_characteristics(result)
  expect_gt(length(unique(result$nodes$group)), 1L)
})


test_that("as_force_data() can process an tidygraph object made from an hclust object", {
  hc <- hclust(dist(USArrests), "ave")
  tidygraph_obj <- tidygraph::as_tbl_graph(hc)
  result <- as_force_data(tidygraph_obj)

  test_deafult_characteristics(result)
})
