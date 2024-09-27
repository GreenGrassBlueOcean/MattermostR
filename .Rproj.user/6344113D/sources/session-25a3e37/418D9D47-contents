
test_that("valid priorities are normalized correctly", {
  expect_equal(normalize_priority("Normal"), "Normal")
  expect_equal(normalize_priority("normal"), "Normal")
  expect_equal(normalize_priority("HIGH"), "High")
  expect_equal(normalize_priority("High"), "High")
  expect_equal(normalize_priority("low"), "Low")
  expect_equal(normalize_priority("LOW"), "Low")
})

test_that("invalid priority raises an error", {
  expect_error(normalize_priority(""), "Invalid priority: ''")
  expect_error(normalize_priority("medium"), "Invalid priority: 'medium'")
  expect_error(normalize_priority("urgent"), "Invalid priority: 'urgent'")
  expect_error(normalize_priority("LowHigh"), "Invalid priority: 'LowHigh'. Must be one of: Normal, High, Low")
})

test_that("mixed case priorities are normalized correctly", {
  expect_equal(normalize_priority("LoW"), "Low")
  expect_equal(normalize_priority("hIGh"), "High")
  expect_equal(normalize_priority("NORmal"), "Normal")
})
