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

   # 6. Test case: Valid priority is normalized
  expect_equal(normalize_priority("normal"), "Normal")
  expect_equal(normalize_priority("HIGH"), "High")
  expect_equal(normalize_priority("lOw"), "Low")

  # 7. Test case: Invalid priority normalization
  expect_error(normalize_priority("invalid"), "Invalid priority: 'invalid'. Must be one of: Normal, High, Low")
})

test_that("Successful message sending with file", {
  # Define the mock response for send_mattermost_file
  file_response <- list(file_infos = list("file123"))

  # Mock check_mattermost_auth to do nothing (auth is assumed valid)
  mockery::stub(send_mattermost_message, 'check_mattermost_auth', function(auth) {})

  # Mock the send_mattermost_file function to simulate a successful file upload
  mockery::stub(send_mattermost_message, 'send_mattermost_file', function(channel_id, file_path, comment, auth, verbose) {
    expect_true(file.exists(file_path))  # Check if the provided file exists
    return(file_response)
  })

  # Create a temporary file to simulate file upload
  temp_file <- tempfile(fileext = ".txt")
  writeLines("This is a test file for Mattermost upload", temp_file)

  # Define a mock response for successful message sending
  mock_response <- list(status = "OK", id = "post123")

  # Mock the mattermost_api_request function to simulate a successful message posting
  mockery::stub(send_mattermost_message, 'mattermost_api_request', function(auth, endpoint, method, body, verbose) {
    expect_equal(body$file_ids, "file123")  # Check that the correct file ID is being sent in the body
    return(mock_response)
  })

  # Call the function under test with the temporary file
  result_with_file <- send_mattermost_message(
    channel_id = "123",
    message = "Hello",
    file_path = temp_file,
    auth = list(base_url = "https://mattermost.example.com", headers = "Bearer fake_token")
  )

  # Verify the result matches the expected mock response
  expect_equal(result_with_file, mock_response)

  # Clean up the temporary file
  unlink(temp_file)
})


test_that("Successful message sending with multiple files", {
  # Define mock responses for send_mattermost_file, one for each file
  file_responses <- list(
    list(file_infos = list("file123")),
    list(file_infos = list("file456"))
  )

  # Create two temporary files to simulate multiple file uploads
  temp_file1 <- tempfile(fileext = ".txt")
  writeLines("This is the first test file for Mattermost upload", temp_file1)

  temp_file2 <- tempfile(fileext = ".txt")
  writeLines("This is the second test file for Mattermost upload", temp_file2)

  # Mock check_mattermost_auth to do nothing (auth is assumed valid)
  mockery::stub(send_mattermost_message, 'check_mattermost_auth', function(auth) {})


  # Mock the send_mattermost_file function to simulate successful file uploads
  mockery::stub(send_mattermost_message, 'send_mattermost_file', function(channel_id, file_path, comment, auth, verbose) {
    expect_true(file.exists(file_path))  # Check if the provided file exists
    # Return corresponding mock response for each file
    if (file_path == temp_file1) {
      return(file_responses[[1]])
    } else if (file_path == temp_file2) {
      return(file_responses[[2]])
    } else {
      stop("Unexpected file path in mock")
    }
  })

  # Define a mock response for successful message sending
  mock_response <- list(status = "OK", id = "post123")

  # Mock the mattermost_api_request function to simulate successful message posting
  mockery::stub(send_mattermost_message, 'mattermost_api_request', function(auth, endpoint, method, body, verbose) {
    expect_equal(body$file_ids, c("file123", "file456"))  # Check that both file IDs are being sent in the body
    return(mock_response)
  })

  # Call the function under test with the multiple temporary files
  result_with_files <- send_mattermost_message(
    channel_id = "123",
    message = "Hello with multiple files",
    file_path = c(temp_file1, temp_file2),
    auth = list(base_url = "https://mattermost.example.com", headers = "Bearer fake_token")
  )

  # Verify the result matches the expected mock response
  expect_equal(result_with_files, mock_response)

  # Clean up the temporary files
  unlink(temp_file1)
  unlink(temp_file2)
})

test_that("Successful message sending with verbose enabled", {
  # Mock check_mattermost_auth to do nothing (auth is assumed valid)
  mockery::stub(send_mattermost_message, 'check_mattermost_auth', function(auth) {})

  # Create a temporary file to simulate file upload
  temp_file <- tempfile(fileext = ".txt")
  writeLines("This is a test file for Mattermost upload", temp_file)

  # Mock response for file upload
  file_response <- list(file_infos = list("file123"))

  # Mock send_mattermost_file
  mockery::stub(send_mattermost_message, 'send_mattermost_file', function(channel_id, file_path, comment, auth, verbose) {
    expect_true(file.exists(file_path))  # Check if the provided file exists
    return(file_response)
  })

  # Mock response for message sending
  mock_response <- list(status = "OK", id = "post123")

  # Mock the mattermost_api_request function
  mockery::stub(send_mattermost_message, 'mattermost_api_request', function(auth, endpoint, method, body, verbose) {
    expect_equal(body$file_ids, "file123")  # Ensure correct file ID is sent in the body
    return(mock_response)
  })

  # Test verbose output
  expect_output(
    send_mattermost_message(
      channel_id = "123",
      message = "Hello",
      file_path = temp_file,
      verbose = TRUE,
      auth = list(base_url = "https://mattermost.example.com", headers = "Bearer fake_token")
    ),
    "Request Body:"
  )

  # Clean up the temporary file
  unlink(temp_file)
})

test_that("Priority setting is correctly handled", {
  # Mock check_mattermost_auth to do nothing (auth is assumed valid)
  mockery::stub(send_mattermost_message, 'check_mattermost_auth', function(auth) {})

  # Mock response for message sending without a file
  mock_response <- list(status = "OK", id = "post123")

  # Mock the mattermost_api_request function to verify priority settings in the body
  mockery::stub(send_mattermost_message, 'mattermost_api_request', function(auth, endpoint, method, body, verbose) {
    # Check priority settings based on the test case
    if (body$message == "Priority High") {
      expect_true(!is.null(body$props))
      expect_equal(body$props$priority$priority, "High")
    } else if (body$message == "Priority Normal") {
      expect_true(is.null(body$props))  # No priority props should be included
    } else if (body$message == "Priority Low") {
      expect_true(!is.null(body$props))
      expect_equal(body$props$priority$priority, "Low")
    }
    return(mock_response)
  })

  # Test case: Priority set to "High"
  result_high <- send_mattermost_message(
    channel_id = "123",
    message = "Priority High",
    priority = "High",
    auth = list(base_url = "https://mattermost.example.com", headers = "Bearer fake_token")
  )
  expect_equal(result_high, mock_response)

  # Test case: Priority is "Normal" (should not set props)
  result_normal <- send_mattermost_message(
    channel_id = "123",
    message = "Priority Normal",
    priority = "Normal",
    auth = list(base_url = "https://mattermost.example.com", headers = "Bearer fake_token")
  )
  expect_equal(result_normal, mock_response)

  # Test case: Priority set to "Low"
  result_low <- send_mattermost_message(
    channel_id = "123",
    message = "Priority Low",
    priority = "Low",
    auth = list(base_url = "https://mattermost.example.com", headers = "Bearer fake_token")
  )
  expect_equal(result_low, mock_response)
})
