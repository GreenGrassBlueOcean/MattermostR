# Test suite for create_channel
test_that("create_channel() works as expected", {

  # 1. Test case: team_id is NULL
  expect_error(create_channel(team_id = NULL, name = "newchannel", display_name = "New Channel"),
               "team_id cannot be empty or NULL")

  # 2. Test case: name is NULL
  expect_error(create_channel(team_id = "123", name = NULL, display_name = "New Channel"),
               "name cannot be empty or NULL")

  # 3. Test case: display_name is NULL
  expect_error(create_channel(team_id = "123", name = "newchannel", display_name = NULL),
               "display_name cannot be empty or NULL")

  # 4. Test case: Missing or invalid authentication object
  expect_error(create_channel(team_id = "123", name = "newchannel", display_name = "New Channel", auth = NULL),
               "The provided object is not a valid 'mattermost_auth' object.")

  # Mock check_mattermost_auth to do nothing (auth is assumed valid)
  mockery::stub(create_channel, 'check_mattermost_auth', function(auth) {})

  # 5. Test case: Channel with the same name already exists
  mockery::stub(create_channel, 'get_team_channels', function(team_id, verbose, auth) {
    return(data.frame(name = c("newchannel", "existingchannel")))
  })
  expect_error(create_channel(team_id = "123", name = "newchannel", display_name = "New Channel"),
               "A channel with the name 'newchannel' already exists.")

  # 6. Test case: Invalid channel type
  expect_error(create_channel(team_id = "123", name = "newchannelxx", display_name = "New Channel xx", type = "invalid"),
               "Channel type must be either 'O' for open or 'P' for private.")

  # 7. Test case: Successful channel creation
  mock_response <- list(id = "channel123", name = "newchannel", display_name = "New Channel", type = "O")

  # Mock mattermost_api_request to simulate a successful API response
  mockery::stub(create_channel, 'mattermost_api_request', function(auth, endpoint, method, body, verbose) {
    mock_response
  })

  result <- create_channel(team_id = "123", name = "newchannel zz", display_name = "New Channel zz", auth = mock_auth)
  expect_equal(result, mock_response)
})
