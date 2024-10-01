# Test suite for send_mattermost_file
test_that("send_mattermost_file() works as expected", {

  # Define the actual file path to use in tests
  test_file_path <- testthat::test_path("testdata/output.txt") # <- Replace this with the path to your test file

  # Mock authentication object
  mock_auth <- list(
    base_url = "https://mock.mattermost.com",
    headers = "Bearer mock_token"
  )

  # 1. Test case: channel_id is NULL
  expect_error(
    send_mattermost_file(channel_id = NULL, file_path = test_file_path, auth = mock_auth),
    "channel_id cannot be empty or NULL"
  )

  # 2. Test case: file_path is NULL
  expect_error(
    send_mattermost_file(channel_id = "123", file_path = NULL, auth = mock_auth),
    "file_path cannot be empty or NULL"
  )

  # 3. Test case: Missing or invalid authentication object
  expect_error(
    send_mattermost_file(channel_id = "123", file_path = test_file_path, auth = NULL),
    "The provided object is not a valid 'mattermost_auth' object."
  )

  # 4. Test case: Successful file send
  mock_response <- list(id = "file123", channel_id = "123", comment = "File uploaded successfully.")

  # Mock check_mattermost_auth to do nothing (auth is assumed valid)
  mockery::stub(send_mattermost_file, 'check_mattermost_auth', function(auth) {})

  # Mock httr2::req_perform to simulate a successful file send
  mockery::stub(send_mattermost_file, 'httr2::req_perform', function(req) {
    # Simulate a response object with necessary content
    response <- list(
      status_code = 200,
      body = charToRaw(jsonlite::toJSON(mock_response))
    )
    class(response) <- "httr2_response"
    return(response)
  })

  # Mock handle_response_content to return the parsed mock response
  mockery::stub(send_mattermost_file, 'handle_response_content', function(response, verbose = FALSE) {
    return(jsonlite::fromJSON(rawToChar(response$body)))
  })

  result <- send_mattermost_file(channel_id = "123", file_path = test_file_path, auth = mock_auth)
  expect_equal(result, mock_response)

  # 5. Test case: Failed file send (simulating a failed API request)
  # Mock httr2::req_perform to simulate a failed file send
  mockery::stub(send_mattermost_file, 'httr2::req_perform', function(req) {
    response <- list(
      status_code = 400,
      body = charToRaw('{"error": "Failed to upload file"}')
    )
    class(response) <- "httr2_response"
    return(response)
  })

  # Mock handle_response_content to handle error responses
  mockery::stub(send_mattermost_file, 'handle_response_content', function(response, verbose = FALSE) {
    if (response$status_code != 200) {
      error_message <- jsonlite::fromJSON(rawToChar(response$body))$error
      stop(error_message)
    }
    return(jsonlite::fromJSON(rawToChar(response$body)))
  })

  expect_error(
    send_mattermost_file(channel_id = "123", file_path = test_file_path, auth = mock_auth),
    "Failed to upload file"
  )

  # 6. Test case: Verbose output
  # Test that verbose = TRUE doesn't cause any errors
  mockery::stub(send_mattermost_file, 'httr2::req_perform', function(req) {
    response <- list(
      status_code = 200,
      body = charToRaw(jsonlite::toJSON(mock_response))
    )
    class(response) <- "httr2_response"
    return(response)
  })

  result_verbose <- send_mattermost_file(channel_id = "123", file_path = test_file_path, auth = mock_auth, verbose = TRUE)
  expect_equal(result_verbose, mock_response)

  # 7. Test case: Sending a file with a comment
  result_with_comment <- send_mattermost_file(channel_id = "123", file_path = test_file_path, comment = "Test comment", auth = mock_auth)
  expect_equal(result_with_comment, mock_response)

  # 8. Test case: Invalid channel_id (simulate API error)
  mockery::stub(send_mattermost_file, 'httr2::req_perform', function(req) {
    response <- list(
      status_code = 404,
      body = charToRaw('{"error": "Channel not found"}')
    )
    class(response) <- "httr2_response"
    return(response)
  })

  expect_error(
    send_mattermost_file(channel_id = "invalid_channel", file_path = test_file_path, auth = mock_auth),
    "Channel not found"
  )

  # 9. Test case: Non-existent file path
  non_existent_path <- tempfile()  # Generates a unique, non-existent file path
  expect_error(
    send_mattermost_file(channel_id = "123", file_path = non_existent_path, auth = mock_auth),
    "The file specified by 'file_path' does not exist."
  )
})
