test_that("mattermost_api_request() works as expected", {

  # Load necessary packages
  library(httptest2)

  # Mock authentication object (values don't matter during mocking)
  mock_auth <- list(
    base_url = "https://mock.mattermost.com",
    headers = "Bearer mock_token"
  )

  # Use with_mock_api() to use the captured responses from the default location
  httptest2::with_mock_api({

    # Test Case 1: Successful GET request to retrieve teams
    result_get_teams <- mattermost_api_request(auth = mock_auth, endpoint = "/api/v4/teams",verbose = TRUE)
    testthat::expect_true(length(result_get_teams) > 0)

    # Use the first team ID from the mocked response
    team_id <- result_get_teams$id

    # Test Case 2: Successful GET request to retrieve channels
    result_get_channels <- mattermost_api_request(auth = mock_auth, endpoint = paste0("/api/v4/teams/", team_id, "/channels"))
    testthat::expect_true(is.list(result_get_channels))

    # Test Case 3: Successful POST request to create a channel
    channel_data <- list(
      team_id = team_id,
      name = "test-channel-mattermost-unit-test",
      display_name = "Test Channel",
      type = "P"
    )

    result_post_channel <- mattermost_api_request(
      auth = mock_auth,
      endpoint = "/api/v4/channels",
      method = "POST",
      body = channel_data
    )
    testthat::expect_equal(result_post_channel$name, "test-channel-mattermost-unit-test")
    testthat::expect_equal(result_post_channel$display_name, "Test Channel")

    # Additional test cases...

  })

  # Other test cases that don't require HTTP mocking
  testthat::expect_error(
    mattermost_api_request(auth = list(base_url = NULL, headers = NULL), endpoint = "/api/v4/teams"),
    "Authentication details are incomplete. Please provide a valid base_url and Authorization token."
  )

  testthat::expect_error(
    mattermost_api_request(auth = mock_auth, endpoint = "/api/v4/teams", method = "PATCH"),
    "Unsupported HTTP method."
  )
})

