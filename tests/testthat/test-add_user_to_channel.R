library(testthat)
library(mockery)

# Define a mock 'mattermost_auth' object
mock_auth <- structure(
  list(
    base_url = "https://fake-mattermost.com",
    headers = "Bearer faketoken"
  ),
  class = "mattermost_auth"
)

test_that("add_user_to_channel() validates inputs", {
  expect_error(
    add_user_to_channel(channel_id = NULL, user_id = "user1", auth = mock_auth),
    "channel_id cannot be empty or NULL"
  )
})

test_that("add_user_to_channel() adds user and prints readable names", {
  stub(add_user_to_channel, "check_mattermost_auth", function(auth) {})

  # Stub get_user to return a mock username
  stub(add_user_to_channel, "get_user", function(user_id, auth) {
    return(list(username = "john_doe"))
  })

  # Stub get_channel_info to return a mock channel name
  stub(add_user_to_channel, "get_channel_info", function(channel_id, verbose, auth) {
    return(list(display_name = "Town Square"))
  })

  # Stub the main API request (adding the member)
  stub(add_user_to_channel, "mattermost_api_request", function(auth, endpoint, method, body, verbose) {
    return(list(user_id = "u1", channel_id = "c1"))
  })

  # Expect a message with the RESOLVED names, not the IDs
  expect_message(
    result <- add_user_to_channel("c1", "u1", auth = mock_auth),
    "Success: User 'john_doe' is now a member of channel 'Town Square'"
  )

  # Ensure the raw data is still returned
  expect_equal(result$user_id, "u1")
})

test_that("add_user_to_channel() with resolve_names = FALSE skips lookups", {
  stub(add_user_to_channel, "check_mattermost_auth", function(auth) {})

  api_mock <- mockery::mock(list(user_id = "u1", channel_id = "c1"))
  stub(add_user_to_channel, "mattermost_api_request", api_mock)

  # Should print IDs, not resolved names

  expect_message(
    result <- add_user_to_channel("c1", "u1", resolve_names = FALSE, auth = mock_auth),
    "Success: User 'u1' is now a member of channel 'c1'"
  )

  # Only 1 API call should have been made (no get_user / get_channel_info)
  expect_called(api_mock, 1)
  expect_equal(result$user_id, "u1")
})

test_that("add_user_to_channel() handles errors gracefully", {
  stub(add_user_to_channel, "check_mattermost_auth", function(auth) {})

  # Simulate API throwing an error (e.g., 403 Forbidden)
  stub(add_user_to_channel, "mattermost_api_request", function(...) {
    stop("You do not have the appropriate permissions")
  })

  expect_error(
    add_user_to_channel("chan1", "user1", auth = mock_auth),
    "You do not have the appropriate permissions"
  )
})
