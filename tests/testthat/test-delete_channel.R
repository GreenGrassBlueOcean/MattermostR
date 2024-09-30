# Start tests for delete_channel
test_that("delete_channel() works as expected", {

  # 1. Test case: channel_id is NULL
  expect_error(delete_channel(channel_id = NULL, team_id = "team123"),
               "channel_id cannot be empty or NULL")

  # 2. Test case: team_id is NULL
  expect_error(delete_channel(channel_id = "channel123", team_id = NULL),
               "team_id cannot be empty or NULL")

  # 3. Test case: Channel doesn't exist in team
  # Mock the `get_team_channels` function to return a list of channels without "channel123"
  mockery::stub(delete_channel, 'get_team_channels', function(team_id, auth) {
    list(id = c("channel456", "channel789"))
  })

  expect_error(delete_channel(channel_id = "channel123", team_id = "team123"),
               "Channel with ID 'channel123' does not exist.")

  # 4. Test case: Channel exists and delete is successful
  # Mock the `get_team_channels` to return a list with "channel123"
  mockery::stub(delete_channel, 'get_team_channels', function(team_id, auth) {
    list(id = c("channel123", "channel456"))
  })

  # Mock the `mattermost_api_request` to simulate a successful delete response
  mockery::stub(delete_channel, 'mattermost_api_request', function(auth, endpoint, method, verbose) {
    list(success = TRUE, message = "Channel deleted successfully.")
  })

  # Run the function and check for correct output
  result <- delete_channel(channel_id = "channel123", team_id = "team123")

  expect_true(result$success)
  expect_equal(result$message, "Channel deleted successfully.")

})

