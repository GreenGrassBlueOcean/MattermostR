test_that("check_not_null() rejects NULL", {
  expect_error(check_not_null(NULL, "x"), "x cannot be empty or NULL")
})

test_that("check_not_null() rejects empty string", {
  expect_error(check_not_null("", "x"), "x cannot be empty or NULL")
})

test_that("check_not_null() rejects length-zero input", {
  expect_error(check_not_null(character(0), "x"), "x cannot be empty or NULL")
  expect_error(check_not_null(integer(0), "x"), "x cannot be empty or NULL")
})

test_that("check_not_null() accepts valid scalar string", {
  expect_silent(check_not_null("abc", "x"))
})

test_that("check_not_null() accepts valid numeric", {
  expect_silent(check_not_null(42, "x"))
})

test_that("check_not_null() accepts character vector without warning", {
  # This is the bug 1.6 regression test — previously warned on length > 1
  expect_silent(check_not_null(c("a", "b"), "x"))
})

test_that("check_not_null() accepts logical TRUE", {
  expect_silent(check_not_null(TRUE, "x"))
})
