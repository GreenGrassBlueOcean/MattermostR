# File: tests/testthat/test-send_message.R

# Test suite for send_mattermost_message
test_that("send_mattermost_message() works as expected", {


  # 1. Test case: Missing or invalid authentication object
  expect_error(send_mattermost_message(channel_id = "123", message = "Hello", auth = NULL),
               "The provided object is not a valid 'mattermost_auth' object.")


  # 2. Test case: Successful message sending without file
  mock_response <- list(id = "post123", message = "Hello", channel_id = "123")

  # Mock check_mattermost_auth to do nothing (auth is assumed valid)
  mockery::stub(send_mattermost_message, 'check_mattermost_auth', function(auth) {})

  # Mock mattermost_api_request to simulate a successful API response
  mockery::stub(send_mattermost_message, 'mattermost_api_request', function(auth, endpoint, method, body, verbose) {
    mock_response
  })


  # 3. Test case: channel_id is NULL
  expect_error(send_mattermost_message(channel_id = NULL, message = "Hello"),
               "channel_id cannot be empty or NULL")

  # 4. Test case: message is NULL
  expect_error(send_mattermost_message(channel_id = "123", message = NULL),
               "message cannot be empty or NULL")

  # 5. Test case: Invalid priority input
  expect_error(send_mattermost_message(channel_id = "123", message = "Hello", priority = "invalid"),
               "Invalid priority: 'invalid'. Must be one of: Normal, High, Low")


  result <- send_mattermost_message(channel_id = "123", message = "Hello", auth = mock_auth)
  expect_equal(result, mock_response)

  # 6. Test case: Successful message sending with file
  file_response <- list(file_infos = list(list(id = "file123")))

  # Mock send_mattermost_file to simulate a successful file upload
  mockery::stub(send_mattermost_message, 'send_mattermost_file', function(channel_id, file_path, comment, auth, verbose) {
    file_response
  })

  result_with_file <- send_mattermost_message(channel_id = "123", message = "Hello", file_path = "path/to/file", auth = mock_auth)
  expect_equal(result_with_file, mock_response)

  # 7. Test case: Valid priority is normalized
  expect_equal(normalize_priority("normal"), "Normal")
  expect_equal(normalize_priority("HIGH"), "High")
  expect_equal(normalize_priority("lOw"), "Low")

  # 8. Test case: Invalid priority normalization
  expect_error(normalize_priority("invalid"), "Invalid priority: 'invalid'. Must be one of: Normal, High, Low")
})
