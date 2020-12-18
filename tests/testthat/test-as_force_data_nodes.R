test_deafult_characteristics <-
  function(.data) {
    expect_s3_class(.data, "data.frame")
    expect_s3_class(.data, "tbl")

    expect_gte(ncol(.data), 2L)
    expect_identical(c("id", "group"), names(.data)[1:2])

    expect_true(all(vapply(.data, is.atomic, logical(1))))

    expect_type(.data[[1L]], "character")
    expect_type(.data[[2L]], "character")
  }


test_that("as_force_data_nodes() handles a data frame with only an id column", {
  example <- data.frame(id = c("a", "b"))
  result <- as_force_data_nodes(example)
  test_deafult_characteristics(result)
  expect_identical(result[[1L]], c("a", "b"))
  expect_identical(result[[2L]], c("1", "1"))
})


test_that("as_force_data_nodes() handles a data frame with only an name column", {
  example <- data.frame(name = c("a", "b"))
  result <- as_force_data_nodes(example)
  test_deafult_characteristics(result)
  expect_identical(result[[1L]], c("a", "b"))
  expect_identical(result[[2L]], c("1", "1"))
})


test_that("as_force_data_nodes() handles a data frame with a name and 1 extra column", {
  example <- data.frame(name = c("a", "b"), other = 1L)
  result <- as_force_data_nodes(example)
  test_deafult_characteristics(result)
  expect_identical(result[[1L]], c("a", "b"))
  expect_identical(result[[2L]], c("1", "1"))
})


test_that("as_force_data_nodes() handles a data frame with a name and group column", {
  example <- data.frame(name = c("a", "b"), group = 1L)
  result <- as_force_data_nodes(example)
  test_deafult_characteristics(result)
  expect_identical(result[[1L]], c("a", "b"))
  expect_identical(result[[2L]], c("1", "1"))
})


test_that("as_force_data_nodes() handles a list with only an id column", {
  example <- list(list(id = "a"), list(id = "b"))
  result <- as_force_data_nodes(example)
  test_deafult_characteristics(result)
  expect_identical(result[[1L]], c("a", "b"))
  expect_identical(result[[2L]], c("1", "1"))
})


test_that("as_force_data_nodes() handles a list with an id and group column", {
  example <- list(list(id = "a", group = 1L), list(id = "b", group = 1L))
  result <- as_force_data_nodes(example)
  test_deafult_characteristics(result)
  expect_identical(result[[1L]], c("a", "b"))
  expect_identical(result[[2L]], c("1", "1"))
})


test_that("as_force_data_nodes() handles a list with an id and an extra column", {
  example <- list(list(id = "a", other = 1L), list(id = "b", other = 1L))
  result <- as_force_data_nodes(example)
  test_deafult_characteristics(result)
  expect_identical(result[[1L]], c("a", "b"))
  expect_identical(result[[2L]], c("1", "1"))
})


test_that("as_force_data_nodes() handles a list with mixed columns", {
  example <- list(list(id = "a", other = 1L), list(id = "b", group = 1L))
  result <- as_force_data_nodes(example)
  test_deafult_characteristics(result)
  expect_identical(result[[1L]], c("a", "b"))
  expect_identical(result[[2L]], c("NA", "1"))
})
