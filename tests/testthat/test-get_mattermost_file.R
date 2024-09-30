# Test suite for get_mattermost_file
test_that("get_mattermost_file() works as expected", {

  # 1. Test case: file_id is NULL
  expect_error(get_mattermost_file(file_id = NULL),
               "file_id cannot be empty or NULL")

  # 2. Test case: file_id is an empty string
  expect_error(get_mattermost_file(file_id = ""),
               "file_id cannot be empty or NULL")

  # 3. Test case: Missing or invalid authentication object
  expect_error(get_mattermost_file(file_id = "123", auth = NULL),
               "The provided object is not a valid 'mattermost_auth' object.")

  # 4. Test case: Successful API request
  mock_response <- list(id = "123", name = "Test File", content = "File content goes here")

  # Mock check_mattermost_auth to do nothing (auth is assumed valid)
  mockery::stub(get_mattermost_file, 'check_mattermost_auth', function(auth) {})

  # Mock mattermost_api_request to simulate a successful API response
  mockery::stub(get_mattermost_file, 'mattermost_api_request', function(auth, endpoint, method) {
    mock_response
  })

  result <- get_mattermost_file(file_id = "123", auth = mock_auth)
  expect_equal(result, mock_response)

  # 5. Test case: Invalid file_id (simulating a failed API request)
  mockery::stub(get_mattermost_file, 'mattermost_api_request', function(auth, endpoint, method) {
    stop("File not found")
  })

  expect_error(get_mattermost_file(file_id = "invalid-file", auth = mock_auth), "File not found")
})
