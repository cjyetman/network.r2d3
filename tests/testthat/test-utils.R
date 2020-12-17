test_that("add_tbl_class() adds 'tbl' class to a data frame or returns an object unmodified", {
  expect_true("tbl" %in% class(add_tbl_class(data.frame(a = 1))))
  expect_equal(list("a"), add_tbl_class(list("a")))
})

test_that("format_force_data_link_data_frame() works as expected", {
  expect_error(format_force_data_link_data_frame(list(a = 1:2)))
  expect_error(format_force_data_link_data_frame(data.frame(a = 1:2)))

  result <- format_force_data_link_data_frame(data.frame(source = 1:2, target = 3:4))
  expect_s3_class(result, "data.frame")
  expect_s3_class(result, "tbl")
  expect_gte(ncol(result), 2L)
  expect_identical(c("source", "target"), names(result)[1:2])
  expect_true(all(vapply(result, is.atomic, logical(1))))
  expect_type(result[[1]], "character")
  expect_type(result[[2]], "character")

  result <- format_force_data_link_data_frame(data.frame(target = 3:4, source = 1:2))
  expect_s3_class(result, "data.frame")
  expect_s3_class(result, "tbl")
  expect_gte(ncol(result), 2L)
  expect_identical(c("source", "target"), names(result)[1:2])
  expect_true(all(vapply(result, is.atomic, logical(1))))
  expect_type(result[[1]], "character")
  expect_type(result[[2]], "character")
})
