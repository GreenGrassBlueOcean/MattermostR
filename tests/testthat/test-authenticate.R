# File: tests/testthat/test-authenticate.R

# Mock function to simulate Mattermost API requests with proper httr2 response objects
mock_api_request <- function(auth, endpoint, method = "GET", body = NULL) {
  # Create a response object
  response <- httr2::response()

  if (endpoint == "/api/v4/users/login") {
    if (!is.null(body) && body$login_id == "valid_user" && body$password == "valid_pass") {
      # Simulate successful login
      response$status_code <- 200
      response$headers <- list(Token = "mock_token")
    } else {
      # Simulate invalid login
      response$status_code <- 401
      response$body <- charToRaw('{"message": "Login failed"}')
    }
  } else if (endpoint == "/api/v4/system/ping") {
    # Simulate successful connection check
    response$status_code <- 200
    response$body <- charToRaw('{"status": "OK"}')
  } else {
    # Simulate other requests
    response$status_code <- 404
    response$body <- charToRaw('{"message": "Not Found"}')
  }

  return(response)
}

# Additional test suite for authenticate_mattermost

test_that("authenticate_mattermost handles login failure with invalid username/password", {
  # Stub the API request to return a failed login response
  stub(authenticate_mattermost, "mattermost_api_request", mock_api_request)

  expect_error(authenticate_mattermost(base_url = "working-url",
                                       username = "invalid_user",
                                       password = "invalid_pass"),
               "Login failed. Please check your username and password.")
})

test_that("authenticate_mattermost succeeds with valid username/password", {
  # Stub the API request to return a successful login response
  stub(authenticate_mattermost, "mattermost_api_request", mock_api_request)

  auth <- authenticate_mattermost(base_url = "working-url",
                                  username = "valid_user",
                                  password = "valid_pass")

  expect_equal(auth$headers, "Bearer mock_token")
})

test_that("authenticate_mattermost stores base_url and token in options", {
  auth <- authenticate_mattermost(base_url = "working-url", token = "valid_token")

  expect_equal(getOption("mattermost.base_url"), "working-url")
  expect_equal(getOption("mattermost.token"), "valid_token")
})

test_that("authenticate_mattermost tests connection successfully", {
  # Stub the check_mattermost_status function to simulate a successful connection test
  stub(authenticate_mattermost, "check_mattermost_status", function(verbose, auth) TRUE)

  auth <- authenticate_mattermost(base_url = "working-url", token = "valid_token", test_connection = TRUE)
  expect_s3_class(auth, "mattermost_auth")
})

test_that("authenticate_mattermost throws error on failed connection test", {
  # Mock a failed connection check
  stub(authenticate_mattermost, "check_mattermost_status", function(verbose, auth) FALSE)

  expect_error(authenticate_mattermost(base_url = "working-url", token = "valid_token", test_connection = TRUE),
               "Connection to Mattermost failed.")
})

test_that("authenticate_mattermost uses token provided as argument even if option is set", {
  options(mattermost.token = "option_token")

  auth <- authenticate_mattermost(base_url = "working-url", token = "passed_token", test_connection = FALSE)

  expect_equal(auth$headers, "Bearer passed_token")

  # Clean up
  options(mattermost.token = NULL)
})

test_that("authenticate_mattermost handles test_connection = TRUE with a valid token", {
  # Stub the check_mattermost_status function to simulate a successful connection test
  stub(authenticate_mattermost, "check_mattermost_status", function(verbose, auth) TRUE)

  auth <- authenticate_mattermost(base_url = "working-url", token = "valid_token", test_connection = TRUE)

  expect_s3_class(auth, "mattermost_auth")
  expect_equal(auth$headers, "Bearer valid_token")
})

# NEW TESTS

test_that("authenticate_mattermost fails if neither token nor username/password is provided", {
  # Clean up
  options(mattermost.token = NULL)

  # Attempt to authenticate without providing a token or username/password
  expect_error(authenticate_mattermost(base_url = "working-url"),
               "Please supply the Bearer token or both username and password.")
})

test_that("authenticate_mattermost fails if base_url is missing and not set as option", {

  # Clean up
  options(mattermost.token = "Bearer valid_token")

   # Ensure no base_url is set as an option
  options(mattermost.base_url = NULL)

  # Attempt to authenticate without providing a base_url
  expect_error(authenticate_mattermost(),
               "Please provide a valid 'base_url'.")
})

test_that("authenticate_mattermost works with base_url set in options", {
  # Set the base_url in options
  options(mattermost.base_url = "working-url")

  # Stub the API request to simulate a valid response
  stub(authenticate_mattermost, "mattermost_api_request", mock_api_request)

  auth <- authenticate_mattermost(token = "valid_token", test_connection = FALSE)

  expect_equal(auth$headers, "Bearer valid_token")

  # Clean up
  options(mattermost.base_url = NULL)
})
