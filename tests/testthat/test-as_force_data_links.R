test_deafult_characteristics <-
  function(.data) {
    expect_s3_class(.data, "data.frame")
    expect_s3_class(.data, "tbl")

    expect_gte(ncol(.data), 2L)
    expect_identical(c("source", "target"), names(.data)[1:2])

    expect_true(all(vapply(.data, is.atomic, logical(1))))

    expect_type(.data[[1]], "character")
    expect_type(.data[[2]], "character")
  }


test_that("as_force_data_links() handles a data frame", {
  example <- data.frame(a = 0:1, b = 2:3)
  result <- as_force_data_links(example)
  test_deafult_characteristics(result)
  expect_true(result[[1]] == 0:1 && result[[2]] == 2:3)
})

test_that("as_force_data_links() handles a list", {
  example <- list(list(source = 0, target = 2), list(source = 1, target = 3))
  result <- as_force_data_links(example)
  test_deafult_characteristics(result)
  expect_true(result[[1]] == 0:1 && result[[2]] == 2:3)
})

test_that("as_force_data_links() handles a data frame with columns 'from' and 'to'", {
  example <- data.frame(from = 0:1, to = 2:3)
  result <- as_force_data_links(example)
  test_deafult_characteristics(result)
  expect_true(result[[1]] == 0:1 && result[[2]] == 2:3)
})

test_that("as_force_data_links() handles a data frame with properly named columns in a different order", {
  example <- data.frame(target = 2:3, source = 0:1)
  result <- as_force_data_links(example)
  test_deafult_characteristics(result)
  expect_true(result[[1]] == 0:1 && result[[2]] == 2:3)
})

test_that("as_force_data_links() handles a data frame with properly named columns in a different order", {
  example <- data.frame(target = 2:3, source = 0:1)
  result <- as_force_data_links(example)
  test_deafult_characteristics(result)
  expect_true(result[[1]] == 0:1 && result[[2]] == 2:3)
})
