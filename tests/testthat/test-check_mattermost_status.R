test_that("check_mattermost_status() works as expected", {

  # 1. Test case: Missing or invalid authentication object
  expect_error(check_mattermost_status(auth = NULL),
               "The provided object is not a valid 'mattermost_auth' object.")

  # 2. Test case: Server is online

  # Mock check_mattermost_auth to do nothing (auth is assumed valid)
  mockery::stub(check_mattermost_status, 'check_mattermost_auth', function(auth) {})

  # Mock mattermost_api_request to simulate a successful server status response
  mockery::stub(check_mattermost_status, 'mattermost_api_request', function(auth, endpoint, method, verbose) {
    list(status = "OK")
  })

  result <- check_mattermost_status(auth = mock_auth_helper())
  expect_true(result)

  # 3. Test case: Server is offline (non-OK status)
  mockery::stub(check_mattermost_status, 'mattermost_api_request', function(auth, endpoint, method, verbose) {
    list(status = "ERROR")
  })

  result_offline <- check_mattermost_status(auth = mock_auth_helper())
  expect_false(result_offline)

  # 4. Test case: Verbose output
  result_verbose <- check_mattermost_status(verbose = TRUE, auth = mock_auth_helper())
  expect_false(result_verbose)  # Based on the previous mock (ERROR)

  # 5. Test case: API request returns NULL (simulating a failed request)
  mockery::stub(check_mattermost_status, 'mattermost_api_request', function(auth, endpoint, method, verbose) {
    NULL
  })

  result_null <- check_mattermost_status(auth = mock_auth_helper())
  expect_false(result_null)
})
