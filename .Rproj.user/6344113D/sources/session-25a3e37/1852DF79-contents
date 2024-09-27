# File: tests/testthat/test-delete_channel.R

# Mock the mattermost_api_request function
mock_mattermost_api_request <- function(auth, endpoint, method, verbose) {
  if (method == "DELETE" && grepl("/api/v4/channels/", endpoint)) {
    return(list(success = TRUE, message = "Channel deleted successfully."))
  }

  # Mocking the retrieval of existing channels
  if (endpoint == "/api/v4/teams/team_id/channels") {
    return(data.frame(id = c("channel1", "channel2"), name = c("channel-one", "channel-two"), stringsAsFactors = FALSE))
  } else if (endpoint == "/api/v4/teams/non_existent_team/channels") {
    return(data.frame())  # Simulate no channels found
  }

  stop("Unknown endpoint.")
}

# Test: Successful channel deletion
test_that("delete_channel successfully deletes an existing channel", {
  mock_api_request <- mockery::mock(mock_mattermost_api_request)
  mockery::stub(delete_channel, "mattermost_api_request", mock_api_request)

  auth <- list(base_url = "http://example.com", headers = list(Authorization = "Bearer token"))
  expect_message(delete_channel(channel_id = "channel1", team_id = "team_id", auth = auth), "Channel deleted successfully.")
})

# Test: Attempting to delete a non-existent channel
test_that("delete_channel throws an error for a non-existent channel", {
  mock_api_request <- mockery::mock(mock_mattermost_api_request)
  mockery::stub(delete_channel, "mattermost_api_request", mock_api_request)

  auth <- list(base_url = "http://example.com", headers = list(Authorization = "Bearer token"))
  expect_error(delete_channel(channel_id = "non_existent_channel", team_id = "team_id", auth = auth), "Channel with ID 'non_existent_channel' does not exist.")
})

# Test: Error when channel_id is NULL
test_that("delete_channel throws an error when channel_id is NULL", {
  expect_error(delete_channel(NULL, "team_id"), "channel_id cannot be empty or NULL")
})

# Test: Error when team_id is NULL
test_that("delete_channel throws an error when team_id is NULL", {
  expect_error(delete_channel("channel_id", NULL), "team_id cannot be empty or NULL")
})

# Test: Error when channel_id is empty
test_that("delete_channel throws an error when channel_id is empty", {
  expect_error(delete_channel("", "team_id"), "channel_id cannot be empty or NULL")
})

# Test: Error when team_id is empty
test_that("delete_channel throws an error when team_id is empty", {
  expect_error(delete_channel("channel_id", ""), "team_id cannot be empty or NULL")
})
