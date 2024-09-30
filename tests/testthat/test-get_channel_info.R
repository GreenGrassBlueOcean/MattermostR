# Start tests for get_channel_info
test_that("get_channel_info() works as expected", {

  # 1. Test case: channel_id is NULL
  expect_error(get_channel_info(channel_id = NULL),
               "channel_id cannot be empty or NULL")

  # 2. Test case: Invalid auth object (missing or invalid token)
  # Mock the check_mattermost_auth to throw an error
  mockery::stub(get_channel_info, 'check_mattermost_auth', function(auth) {
    stop("Invalid authentication object.")
  })

  expect_error(get_channel_info(channel_id = "channel123", auth = list(base_url = "invalid_url")),
               "Invalid authentication object.")

  # 3. Test case: Successful retrieval of channel info
  # Mock the check_mattermost_auth to do nothing (auth is assumed valid)
  mockery::stub(get_channel_info, 'check_mattermost_auth', function(auth) {})

  # Mock the mattermost_api_request to simulate a successful API response
  mockery::stub(get_channel_info, 'mattermost_api_request', function(auth, endpoint, method, verbose) {
    list(id = "channel123", name = "Test Channel", display_name = "Test Channel Display")
  })

  # Run the function and check if the result matches expected output
  result <- get_channel_info(channel_id = "channel123")

  expect_equal(result$id, "channel123")
  expect_equal(result$name, "Test Channel")
  expect_equal(result$display_name, "Test Channel Display")

  # 4. Test case: Failure in API request (non-existing channel)
  # Mock the mattermost_api_request to return a failure response
  mockery::stub(get_channel_info, 'mattermost_api_request', function(auth, endpoint, method, verbose) {
    stop("Channel not found.")
  })

  expect_error(get_channel_info(channel_id = "non_existing_channel"),
               "Channel not found.")

})
