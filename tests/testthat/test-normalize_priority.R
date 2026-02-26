
test_that("valid priorities are normalized correctly", {
  expect_equal(normalize_priority("Normal"), "Normal")
  expect_equal(normalize_priority("normal"), "Normal")
  expect_equal(normalize_priority("IMPORTANT"), "Important")
  expect_equal(normalize_priority("Important"), "Important")
  expect_equal(normalize_priority("urgent"), "Urgent")
  expect_equal(normalize_priority("URGENT"), "Urgent")
})

test_that("invalid priority raises an error", {
  expect_error(normalize_priority(""), "Invalid priority: ''")
  expect_error(normalize_priority("medium"), "Invalid priority: 'medium'")
  expect_error(normalize_priority("minor"), "Invalid priority: 'minor'")
  expect_error(normalize_priority("LowHigh"), "Invalid priority: 'LowHigh'. Must be one of: Normal, Important, Urgent")
  # Old values "High" and "Low" are no longer valid
  expect_error(normalize_priority("High"), "Invalid priority: 'High'. Must be one of: Normal, Important, Urgent")
  expect_error(normalize_priority("Low"), "Invalid priority: 'Low'. Must be one of: Normal, Important, Urgent")
})

test_that("mixed case priorities are normalized correctly", {
  expect_equal(normalize_priority("uRgEnT"), "Urgent")
  expect_equal(normalize_priority("iMpOrTaNt"), "Important")
  expect_equal(normalize_priority("NORmal"), "Normal")
})
