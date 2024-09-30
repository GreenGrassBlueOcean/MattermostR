# File: tests/testthat/test-get_team_channels.R

test_that("get_team_channels() works as expected", {

  # 1. Test case: team_id is NULL
  expect_error(get_team_channels(team_id = NULL),
               "team_id cannot be empty or NULL")

  # 2. Test case: team_id is an empty string
  expect_error(get_team_channels(team_id = ""),
               "team_id cannot be empty or NULL")

  # 3. Test case: Missing or invalid authentication object
  expect_error(get_team_channels(team_id = "team123", auth = NULL),
               "The provided object is not a valid 'mattermost_auth' object.")

  # 4. Test case: Successful API request

  # Mock check_mattermost_auth to do nothing (auth is assumed valid)
  mockery::stub(get_team_channels, 'check_mattermost_auth', function(auth) {})

  # Mock mattermost_api_request to simulate a successful API response
  mockery::stub(get_team_channels, 'mattermost_api_request', function(auth, endpoint, method, verbose) {
    data.frame(id = c("channel1", "channel2"), name = c("Channel One", "Channel Two"))
  })

  result <- get_team_channels(team_id = "team123", auth = mock_auth_helper())
  expect_equal(result, data.frame(id = c("channel1", "channel2"), name = c("Channel One", "Channel Two")))

  # 5. Test case: Verbose output
  result_verbose <- get_team_channels(team_id = "team123", verbose = TRUE, auth = mock_auth_helper())
  expect_equal(result_verbose, data.frame(id = c("channel1", "channel2"), name = c("Channel One", "Channel Two")))

  # 6. Test case: Invalid team_id (simulating a failed API request)
  mockery::stub(get_team_channels, 'mattermost_api_request', function(auth, endpoint, method, verbose) {
    stop("Team not found")
  })

  expect_error(get_team_channels(team_id = "invalid-team", auth = mock_auth_helper()), "Team not found")
})
