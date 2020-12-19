test_deafult_characteristics <-
  function(.data) {
    expect_s3_class(.data, "data.frame")
    expect_s3_class(.data, "tbl")

    expect_gte(ncol(.data), 2L)
    expect_identical(c("source", "target"), names(.data)[1L:2L])

    expect_true(all(vapply(.data, is.atomic, logical(1L))))

    expect_type(.data[[1L]], "character")
    expect_type(.data[[2L]], "character")
  }


test_that("as_force_data_links() handles a data frame", {
  example <- data.frame(a = 0L:1L, b = 2L:3L)
  result <- as_force_data_links(example)
  test_deafult_characteristics(result)
  expect_identical(result[[1L]], c("0", "1"))
  expect_identical(result[[2L]], c("2", "3"))
})

test_that("as_force_data_links() handles a list", {
  example <- list(list(source = 0L, target = 2L), list(source = 1L, target = 3L))
  result <- as_force_data_links(example)
  test_deafult_characteristics(result)
  expect_identical(result[[1L]], c("0", "1"))
  expect_identical(result[[2L]], c("2", "3"))
})

test_that("as_force_data_links() handles a data frame with columns 'from' and 'to'", {
  example <- data.frame(from = 0L:1L, to = 2L:3L)
  result <- as_force_data_links(example)
  test_deafult_characteristics(result)
  expect_identical(result[[1L]], c("0", "1"))
  expect_identical(result[[2L]], c("2", "3"))
})

test_that("as_force_data_links() handles a data frame with properly named columns in a different order", {
  example <- data.frame(target = 2L:3L, source = 0L:1L)
  result <- as_force_data_links(example)
  test_deafult_characteristics(result)
  expect_identical(result[[1L]], c("0", "1"))
  expect_identical(result[[2L]], c("2", "3"))
})
