# --- Username/password login tests ---
# These stub perform_login_request(), the internal helper that sends the
# POST /api/v4/users/login request and returns the raw httr2 response.

test_that("authenticate_mattermost handles login failure with invalid username/password", {
  withr::local_options(mattermost.token = NULL)
  withr::local_envvar(MATTERMOST_TOKEN = NA)

  mock_401 <- httr2::response(
    status_code = 401,
    headers = list(`Content-Type` = "application/json"),
    body = charToRaw('{"message": "Login failed"}')
  )
  stub(authenticate_mattermost, "perform_login_request", function(...) mock_401)

  expect_error(
    authenticate_mattermost(base_url = "https://mock.mattermost.com",
                            username = "invalid_user",
                            password = "invalid_pass"),
    "Login failed. Please check your username and password."
  )
})

test_that("authenticate_mattermost succeeds with valid username/password", {
  withr::local_options(mattermost.token = NULL)
  withr::local_envvar(MATTERMOST_TOKEN = NA)

  mock_200 <- httr2::response(
    status_code = 200,
    headers = list(Token = "mock_token", `Content-Type` = "application/json"),
    body = charToRaw('{"id":"user123"}')
  )
  stub(authenticate_mattermost, "perform_login_request", function(...) mock_200)

  auth <- authenticate_mattermost(base_url = "https://mock.mattermost.com",
                                  username = "valid_user",
                                  password = "valid_pass")

  expect_equal(auth$headers, "Bearer mock_token")
  expect_s3_class(auth, "mattermost_auth")
})

test_that("authenticate_mattermost fails when login returns 200 but no Token header", {
  withr::local_options(mattermost.token = NULL)
  withr::local_envvar(MATTERMOST_TOKEN = NA)

  mock_200_no_token <- httr2::response(
    status_code = 200,
    headers = list(`Content-Type` = "application/json"),
    body = charToRaw('{"id":"user123"}')
  )
  stub(authenticate_mattermost, "perform_login_request", function(...) mock_200_no_token)

  expect_error(
    authenticate_mattermost(base_url = "https://mock.mattermost.com",
                            username = "valid_user",
                            password = "valid_pass"),
    "Login succeeded but no token was returned in the response headers."
  )
})

# --- Direct tests for perform_login_request() ---

test_that("perform_login_request builds correct URL and returns raw httr2 response", {
  captured_req <- NULL
  mock_response <- httr2::response(
    status_code = 200,
    headers = list(Token = "test_token_abc", `Content-Type` = "application/json"),
    body = charToRaw('{"id":"user456"}')
  )

  stub(perform_login_request, "httr2::req_perform", function(req) {
    captured_req <<- req
    mock_response
  })

  result <- perform_login_request(
    base_url = "https://my.mattermost.server",
    username = "testuser",
    password = "testpass"
  )

  # Returns the raw httr2 response (not parsed JSON)
  expect_s3_class(result, "httr2_response")
  expect_equal(httr2::resp_status(result), 200)
  expect_equal(httr2::resp_header(result, "Token"), "test_token_abc")

  # Verify the request was built with the correct URL
  expect_true(grepl("https://my.mattermost.server/api/v4/users/login", captured_req$url))
})

test_that("perform_login_request does not throw on HTTP error status codes", {
  # req_error(is_error = ...) should prevent httr2 from throwing on 401/500
  mock_500 <- httr2::response(
    status_code = 500,
    headers = list(`Content-Type` = "application/json"),
    body = charToRaw('{"message":"Internal Server Error"}')
  )
  stub(perform_login_request, "httr2::req_perform", function(req) mock_500)

  # Should return the response, not throw
  result <- perform_login_request("https://example.com", "user", "pass")
  expect_s3_class(result, "httr2_response")
  expect_equal(httr2::resp_status(result), 500)
})

# --- Token-based auth tests ---

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
  withr::local_options(mattermost.token = "option_token")

  auth <- authenticate_mattermost(base_url = "working-url", token = "passed_token", test_connection = FALSE)

  expect_equal(auth$headers, "Bearer passed_token")
})

test_that("authenticate_mattermost handles test_connection = TRUE with a valid token", {
  # Stub the check_mattermost_status function to simulate a successful connection test
  stub(authenticate_mattermost, "check_mattermost_status", function(verbose, auth) TRUE)

  auth <- authenticate_mattermost(base_url = "working-url", token = "valid_token", test_connection = TRUE)

  expect_s3_class(auth, "mattermost_auth")
  expect_equal(auth$headers, "Bearer valid_token")
})

test_that("authenticate_mattermost fails if neither token nor username/password is provided", {
  withr::local_options(mattermost.token = NULL)
  withr::local_envvar(MATTERMOST_TOKEN = NA)

  expect_error(authenticate_mattermost(base_url = "working-url"),
               "Please supply the Bearer token or both username and password.")
})

test_that("authenticate_mattermost fails if base_url is missing and not set as option", {
  withr::local_options(mattermost.token = "Bearer valid_token", mattermost.base_url = NULL)
  withr::local_envvar(MATTERMOST_URL = NA)

  expect_error(authenticate_mattermost(),
               "Please provide a valid 'base_url'.")
})

test_that("authenticate_mattermost works with base_url set in options", {
  withr::local_options(mattermost.base_url = "working-url")

  auth <- authenticate_mattermost(token = "valid_token", test_connection = FALSE)

  expect_equal(auth$headers, "Bearer valid_token")
})


# --- get_default_auth() tests ---

test_that("get_default_auth() returns a valid mattermost_auth when options are set", {
  withr::local_options(mattermost.token = "my_token", mattermost.base_url = "https://mm.example.com")
  withr::local_envvar(MATTERMOST_TOKEN = NA, MATTERMOST_URL = NA)

  auth <- get_default_auth()
  expect_s3_class(auth, "mattermost_auth")
  expect_equal(auth$base_url, "https://mm.example.com")
  expect_equal(auth$headers, "Bearer my_token")
})

test_that("get_default_auth() errors clearly when token is missing", {
  withr::local_options(mattermost.token = NULL, mattermost.base_url = "https://mm.example.com")
  withr::local_envvar(MATTERMOST_TOKEN = NA, MATTERMOST_URL = NA)

  expect_error(get_default_auth(), "No Mattermost credentials found")
})

test_that("get_default_auth() errors clearly when base_url is missing", {
  withr::local_options(mattermost.token = "my_token", mattermost.base_url = NULL)
  withr::local_envvar(MATTERMOST_TOKEN = NA, MATTERMOST_URL = NA)

  expect_error(get_default_auth(), "No Mattermost credentials found")
})

test_that("get_default_auth() errors clearly when both are missing", {
  withr::local_options(mattermost.token = NULL, mattermost.base_url = NULL)
  withr::local_envvar(MATTERMOST_TOKEN = NA, MATTERMOST_URL = NA)

  expect_error(get_default_auth(), "No Mattermost credentials found")
  expect_error(get_default_auth(), "MATTERMOST_TOKEN")
})

test_that("get_default_auth() prefers env vars over options", {
  withr::local_options(mattermost.token = "option_token", mattermost.base_url = "https://option.example.com")
  withr::local_envvar(MATTERMOST_TOKEN = "env_token", MATTERMOST_URL = "https://env.example.com")

  auth <- get_default_auth()
  expect_equal(auth$headers, "Bearer env_token")
  expect_equal(auth$base_url, "https://env.example.com")
})

test_that("get_default_auth() falls back to options when env vars are unset", {
  withr::local_options(mattermost.token = "option_token", mattermost.base_url = "https://option.example.com")
  withr::local_envvar(MATTERMOST_TOKEN = NA, MATTERMOST_URL = NA)

  auth <- get_default_auth()
  expect_equal(auth$headers, "Bearer option_token")
  expect_equal(auth$base_url, "https://option.example.com")
})

test_that("get_default_auth() uses env token with option URL and vice versa", {
  withr::local_options(mattermost.token = NULL, mattermost.base_url = "https://option.example.com")
  withr::local_envvar(MATTERMOST_TOKEN = "env_token", MATTERMOST_URL = NA)

  auth <- get_default_auth()
  expect_equal(auth$headers, "Bearer env_token")
  expect_equal(auth$base_url, "https://option.example.com")
})


# --- resolve_credential() tests ---

test_that("resolve_credential() returns env var when set", {
  withr::local_envvar(MY_TEST_VAR = "env_value")
  withr::local_options(my.test.option = "option_value")

  expect_equal(resolve_credential("MY_TEST_VAR", "my.test.option"), "env_value")
})

test_that("resolve_credential() falls back to option when env var is unset", {
  withr::local_envvar(MY_TEST_VAR = NA)
  withr::local_options(my.test.option = "option_value")

  expect_equal(resolve_credential("MY_TEST_VAR", "my.test.option"), "option_value")
})

test_that("resolve_credential() falls back to option when env var is empty string", {
  withr::local_envvar(MY_TEST_VAR = "")
  withr::local_options(my.test.option = "option_value")

  expect_equal(resolve_credential("MY_TEST_VAR", "my.test.option"), "option_value")
})

test_that("resolve_credential() returns NULL when neither source has a value", {
  withr::local_envvar(MY_TEST_VAR = NA)
  withr::local_options(my.test.option = NULL)

  expect_null(resolve_credential("MY_TEST_VAR", "my.test.option"))
})

test_that("resolve_credential() returns NULL when option is empty string", {
  withr::local_envvar(MY_TEST_VAR = NA)
  withr::local_options(my.test.option = "")

  expect_null(resolve_credential("MY_TEST_VAR", "my.test.option"))
})


# --- cache_credentials tests ---

test_that("authenticate_mattermost does NOT cache when cache_credentials = FALSE", {
  withr::local_options(mattermost.token = NULL, mattermost.base_url = NULL)

  auth <- authenticate_mattermost(base_url = "https://mm.example.com",
                                  token = "secret_token",
                                  cache_credentials = FALSE)

  expect_s3_class(auth, "mattermost_auth")
  expect_equal(auth$headers, "Bearer secret_token")
  expect_equal(auth$base_url, "https://mm.example.com")

  # Crucially: options should NOT have been set
  expect_null(getOption("mattermost.token"))
  expect_null(getOption("mattermost.base_url"))
})

test_that("authenticate_mattermost caches when cache_credentials = TRUE (default)", {
  withr::local_options(mattermost.token = NULL, mattermost.base_url = NULL)

  auth <- authenticate_mattermost(base_url = "https://mm.example.com",
                                  token = "cached_token")

  expect_equal(getOption("mattermost.token"), "cached_token")
  expect_equal(getOption("mattermost.base_url"), "https://mm.example.com")
})

test_that("authenticate_mattermost resolves token from env var", {
  withr::local_options(mattermost.token = NULL)
  withr::local_envvar(MATTERMOST_TOKEN = "env_secret")

  auth <- authenticate_mattermost(base_url = "https://mm.example.com",
                                  cache_credentials = FALSE)

  expect_equal(auth$headers, "Bearer env_secret")
})

test_that("authenticate_mattermost resolves base_url from env var when not passed", {
  withr::local_options(mattermost.base_url = NULL)
  withr::local_envvar(MATTERMOST_URL = "https://env.example.com")

  auth <- authenticate_mattermost(token = "my_token", cache_credentials = FALSE)

  expect_equal(auth$base_url, "https://env.example.com")
})


# --- clear_mattermost_credentials() tests ---

test_that("clear_mattermost_credentials() removes cached options", {
  withr::local_options(mattermost.token = "should_be_cleared",
                       mattermost.base_url = "https://should.be.cleared")

  result <- clear_mattermost_credentials()

  expect_null(getOption("mattermost.token"))
  expect_null(getOption("mattermost.base_url"))
  expect_null(result)
})

test_that("clear_mattermost_credentials() is safe to call when options are already NULL", {
  withr::local_options(mattermost.token = NULL, mattermost.base_url = NULL)

  expect_no_error(clear_mattermost_credentials())
  expect_null(getOption("mattermost.token"))
})


# --- print.mattermost_auth() tests ---

test_that("print.mattermost_auth() masks long tokens", {
  auth <- structure(
    list(base_url = "https://mm.example.com", headers = "Bearer abcdefghijklmnop"),
    class = "mattermost_auth"
  )

  output <- capture.output(print(auth))

  expect_match(output[1], "<mattermost_auth>")
  expect_match(output[2], "Server: https://mm.example.com")
  # Token should show first 4 and last 4 characters with "..." in between
  expect_match(output[3], "Token:  abcd\\.\\.\\.mnop")
})

test_that("print.mattermost_auth() masks short tokens with ****", {
  auth <- structure(
    list(base_url = "https://mm.example.com", headers = "Bearer abcd1234"),
    class = "mattermost_auth"
  )

  output <- capture.output(print(auth))

  expect_match(output[3], "Token:  \\*\\*\\*\\*")
})

test_that("print.mattermost_auth() returns the auth object invisibly", {
  auth <- structure(
    list(base_url = "https://mm.example.com", headers = "Bearer long_token_value_here"),
    class = "mattermost_auth"
  )

  result <- withVisible(capture.output(ret <- print(auth)))
  expect_identical(ret, auth)
})
