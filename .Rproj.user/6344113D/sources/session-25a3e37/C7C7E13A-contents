# File: tests/testthat/test-get_channel_info.R

library(testthat)
library(mockery)

test_that("get_channel_info works correctly", {
  auth_mock <- list(base_url = "https://your-mattermost-url.com", headers = "Bearer token")
  channel_id <- "abc123"

  # Mock API response
  mock_response <- list(
    id = channel_id,
    name = "test-channel",
    display_name = "Test Channel",
    team_id = "team123"
  )

  # Mock mattermost_api_request call
  mock_request <- mock(mock_response)
  stub(get_channel_info, "mattermost_api_request", mock_request)

  result <- get_channel_info(auth = auth_mock, channel_id = channel_id)

  expect_equal(result$id, channel_id)
  expect_equal(result$name, "test-channel")
  expect_equal(result$display_name, "Test Channel")

  expect_called(mock_request, 1)
  expect_args(mock_request, 1, auth_mock, "/api/v4/channels/abc123", "GET", retries = 3, backoff = 1, timeout = 10)
})
