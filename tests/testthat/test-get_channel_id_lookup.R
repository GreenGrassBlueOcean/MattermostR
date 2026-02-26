#library(testthat)

# Sample data frame for testing
channels <- data.frame(
  id = c("gy91r1kjnbnkdfu6jjoxzcm5ge", "utbtjouxkirniyh9u84oym6mnh", "abc12345xyz", "xyz56789abc"),
  display_name = c("Off-Topic", "Town Square", "Off-Topic", "Random"),
  name = c("off-topic", "town-square", "off-topic-team", "random"),
  stringsAsFactors = FALSE
)

# Test: check rejects wrong input
test_that("Lookup by display_name returns correct channel ID", {
  expect_error(get_channel_id_lookup(channels = list(), display_name = "Town Square")
               , "Input must be a data frame containing 'id', 'display_name', and 'name' columns.")
})

# Test: Successful lookup by display_name
test_that("Lookup by display_name returns correct channel ID", {
  expect_equal(get_channel_id_lookup(channels, display_name = "Town Square")
               , "utbtjouxkirniyh9u84oym6mnh")
})

# Test: Successful lookup by name
test_that("Lookup by name returns correct channel ID", {
  expect_equal(get_channel_id_lookup(channels, name = "town-square"), "utbtjouxkirniyh9u84oym6mnh")
})

# Test: Successful lookup with both display_name and name to disambiguate
test_that("Lookup with both display_name and name to disambiguate returns correct channel ID", {
  expect_equal(get_channel_id_lookup(channels, display_name = "Off-Topic", name = "off-topic-team"), "abc12345xyz")
})

# Test: Error when both display_name and name are not provided
test_that("Error when neither display_name nor name is provided", {
  expect_error(get_channel_id_lookup(channels), "Either 'display_name' or 'name' must be provided.")
})

# Test: Error when no channel matches the provided display_name
test_that("Error when no channel matches the provided display_name", {
  expect_error(get_channel_id_lookup(channels, display_name = "Non-Existent"), "No channel found with the specified display_name or name.")
})

# Test: Error when no channel matches the provided name
test_that("Error when no channel matches the provided name", {
  expect_error(get_channel_id_lookup(channels, name = "non-existent-name"), "No channel found with the specified display_name or name.")
})

# Test: Error when multiple channels have the same display_name without name provided to disambiguate
test_that("Error when multiple channels have the same display_name and name not provided", {
  expect_error(get_channel_id_lookup(channels, display_name = "Off-Topic"), "Multiple channels found with the same display_name. Please provide the 'name' for disambiguation.")
})
