# File: tests/testthat/test-get_all_users.R

library(testthat)
library(mockery)

# Test suite for get_all_users
test_that("get_all_users() works as expected", {

  # 1. Test case: Missing or invalid authentication object
  expect_error(get_all_users(auth = NULL),
               "The provided object is not a valid 'mattermost_auth' object.")

  # 2. Test case: Successful API request
  mock_response <- list(user_ids = c("user1", "user2", "user3"))

  # Mock check_mattermost_auth to do nothing (auth is assumed valid)
  mockery::stub(get_all_users, 'check_mattermost_auth', function(auth) {})

  # Mock mattermost_api_request to simulate a successful API response
  mockery::stub(get_all_users, 'mattermost_api_request', function(auth, endpoint, method) {
    mock_response
  })

  result <- get_all_users(auth = mock_auth)
  expect_equal(result, mock_response)

  # 3. Test case: Simulating a failed API request
  mockery::stub(get_all_users, 'mattermost_api_request', function(auth, endpoint, method) {
    stop("Failed to retrieve users")
  })

  expect_error(get_all_users(auth = mock_auth), "Failed to retrieve users")
})
