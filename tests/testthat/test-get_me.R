# Test suite for get_me
test_that("get_me() works as expected", {

  # 1. Test case: Missing or invalid authentication object
  expect_error(get_me(auth = NULL),
               "The provided object is not a valid 'mattermost_auth' object.")

  # 2. Test case: Successful API request
  mock_response <- list(id = "user123", username = "testuser", email = "test@example.com")

  # Mock check_mattermost_auth to do nothing (auth is assumed valid)
  mockery::stub(get_me, 'check_mattermost_auth', function(auth) {})

  # Mock mattermost_api_request to simulate a successful API response
  mockery::stub(get_me, 'mattermost_api_request', function(auth, endpoint, method, verbose) {
    mock_response
  })

  result <- get_me(auth = mock_auth)
  expect_equal(result, mock_response)

  # 3. Test case: Verbose flag is respected
  verbose_result <- get_me(verbose = TRUE, auth = mock_auth)
  expect_equal(verbose_result, mock_response)

  # 4. Test case: Successful API request with verbose
  mockery::stub(get_me, 'mattermost_api_request', function(auth, endpoint, method, verbose) {
    expect_true(verbose)  # Check if verbose flag is passed correctly
    mock_response
  })

  result_verbose <- get_me(verbose = TRUE, auth = mock_auth)
  expect_equal(result_verbose, mock_response)
})
