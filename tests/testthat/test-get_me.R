# Test suite for get_me

test_that("get_me() rejects invalid auth", {
  expect_error(get_me(auth = NULL),
               "The provided object is not a valid 'mattermost_auth' object.")
})

test_that("get_me() returns user info on success", {
  mock_response <- list(id = "user123", username = "testuser", email = "test@example.com")

  mockery::stub(get_me, "check_mattermost_auth", function(auth) {})
  mockery::stub(get_me, "mattermost_api_request", function(auth, endpoint, method, verbose) {
    mock_response
  })

  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com", headers = "Bearer mock_token"),
    class = "mattermost_auth"
  )

  result <- get_me(auth = mock_auth)
  expect_equal(result, mock_response)
})

test_that("get_me() defaults to verbose = FALSE", {
  mock_response <- list(id = "user123", username = "testuser")

  captured_verbose <- NULL
  mockery::stub(get_me, "check_mattermost_auth", function(auth) {})
  mockery::stub(get_me, "mattermost_api_request", function(auth, endpoint, method, verbose) {
    captured_verbose <<- verbose
    mock_response
  })

  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com", headers = "Bearer mock_token"),
    class = "mattermost_auth"
  )

  get_me(auth = mock_auth)
  expect_false(captured_verbose)
})

test_that("get_me() passes verbose = TRUE when requested", {
  mock_response <- list(id = "user123", username = "testuser")

  captured_verbose <- NULL
  mockery::stub(get_me, "check_mattermost_auth", function(auth) {})
  mockery::stub(get_me, "mattermost_api_request", function(auth, endpoint, method, verbose) {
    captured_verbose <<- verbose
    mock_response
  })

  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com", headers = "Bearer mock_token"),
    class = "mattermost_auth"
  )

  get_me(verbose = TRUE, auth = mock_auth)
  expect_true(captured_verbose)
})
