test_that("add_tbl_class() adds 'tbl' class to a data frame or returns an object unmodified", {
  expect_true("tbl" %in% class(add_tbl_class(data.frame(a = 1L))))
  expect_equal(list("a"), add_tbl_class(list("a")))
})

test_that("format_force_data_link_data_frame() works as expected", {
  expect_error(format_force_data_link_data_frame(list(a = 1L:2L)))
  expect_error(format_force_data_link_data_frame(data.frame(a = 1L:2L)))

  result <- format_force_data_link_data_frame(data.frame(source = 1L:2L, target = 3L:4L))
  expect_s3_class(result, "data.frame")
  expect_s3_class(result, "tbl")
  expect_gte(ncol(result), 2L)
  expect_identical(c("source", "target"), names(result)[1L:2L])
  expect_true(all(vapply(result, is.atomic, logical(1L))))
  expect_type(result[[1L]], "character")
  expect_type(result[[2L]], "character")

  result <- format_force_data_link_data_frame(data.frame(target = 3L:4L, source = 1L:2L))
  expect_s3_class(result, "data.frame")
  expect_s3_class(result, "tbl")
  expect_gte(ncol(result), 2L)
  expect_identical(c("source", "target"), names(result)[1L:2L])
  expect_true(all(vapply(result, is.atomic, logical(1))))
  expect_type(result[[1L]], "character")
  expect_type(result[[2L]], "character")
})

test_that("first_found_in() works as expected", {
  # same order
  .x <- c("A", "B", "C")
  domain <- c("A", "C")
  expect_equal(first_found_in(.x, domain), "A")

  # out of order
  .x <- c("A", "B", "C")
  domain <- c("B", "A")
  expect_equal(first_found_in(.x, domain), "B")

  # `NA` if none found
  .x <- c("a", "b")
  domain <- c("source", "from", "sources", "start", "begin")
  expect_equal(first_found_in(.x, domain), NA_character_)
})

test_that("index_of_first_found_in() works as expected", {
  # same order
  .x <- c("A", "B", "C")
  domain <- c("A", "C")
  expect_equal(index_of_first_found_in(.x, domain), 1L)

  # out of order
  .x <- c("A", "B", "C")
  domain <- c("B", "A")
  expect_equal(index_of_first_found_in(.x, domain), 2L)

  # `NA` if none found
  .x <- c("a", "b")
  domain <- c("source", "from", "sources", "start", "begin")
  expect_equal(index_of_first_found_in(.x, domain), NA_integer_)
})
