# File: tests/testthat/test-get_user_info.R

library(testthat)
library(mockery)

# Test suite for get_user_info
test_that("get_user_info() works as expected", {

  # 1. Test case: user_id is NULL
  expect_error(get_user_info(user_id = NULL),
               "user_id cannot be empty or NULL")

  # 2. Test case: user_id is an empty string
  expect_error(get_user_info(user_id = ""),
               "user_id cannot be empty or NULL")

  # 3. Test case: Missing or invalid authentication object
  expect_error(get_user_info(user_id = "123", auth = NULL),
               "The provided object is not a valid 'mattermost_auth' object.")

  # 4. Test case: Successful API request
  mock_response <- list(id = "123", username = "testuser", email = "test@example.com")

  # Mock check_mattermost_auth to do nothing (auth is assumed valid)
  mockery::stub(get_user_info, 'check_mattermost_auth', function(auth) {})

  # Mock mattermost_api_request to simulate a successful API response
  mockery::stub(get_user_info, 'mattermost_api_request', function(auth, endpoint, method) {
    mock_response
  })

  result <- get_user_info(user_id = "123", auth = mock_auth)
  expect_equal(result, mock_response)

  # 5. Test case: Invalid user_id (simulating a failed API request)
  mockery::stub(get_user_info, 'mattermost_api_request', function(auth, endpoint, method) {
    stop("User not found")
  })

  expect_error(get_user_info(user_id = "invalid-user", auth = mock_auth), "User not found")
})
