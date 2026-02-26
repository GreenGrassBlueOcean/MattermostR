test_that("mattermost_api_request() works as expected", {

  # Load necessary packages
  library(httptest2)

  # Mock authentication object (values don't matter during mocking)
  mock_auth <- list(
    base_url = "https://mock.mattermost.com",
    headers = "Bearer mock_token"
  )

  # Use with_mock_api() to use the captured responses from the default location
  httptest2::with_mock_api({

    # Test Case 1: Successful GET request to retrieve teams
    result_get_teams <- mattermost_api_request(auth = mock_auth, endpoint = "/api/v4/teams",verbose = TRUE)
    testthat::expect_true(length(result_get_teams) > 0)

    # Use the first team ID from the mocked response
    team_id <- result_get_teams$id

    # Test Case 2: Successful GET request to retrieve channels
    result_get_channels <- mattermost_api_request(auth = mock_auth, endpoint = paste0("/api/v4/teams/", team_id, "/channels"))
    testthat::expect_true(is.list(result_get_channels))

    # Test Case 3: Successful POST request to create a channel
    channel_data <- list(
      team_id = team_id,
      name = "test-channel-mattermost-unit-test",
      display_name = "Test Channel",
      type = "P"
    )

    result_post_channel <- mattermost_api_request(
      auth = mock_auth,
      endpoint = "/api/v4/channels",
      method = "POST",
      body = channel_data
    )
    testthat::expect_equal(result_post_channel$name, "test-channel-mattermost-unit-test")
    testthat::expect_equal(result_post_channel$display_name, "Test Channel")

    # Additional test cases...

  })

  # Other test cases that don't require HTTP mocking
  testthat::expect_error(
    mattermost_api_request(auth = list(base_url = NULL, headers = NULL), endpoint = "/api/v4/teams"),
    "Authentication details are incomplete. Please provide a valid base_url and Authorization token."
  )

  testthat::expect_error(
    mattermost_api_request(auth = mock_auth, endpoint = "/api/v4/teams", method = "PATCH"),
    "Unsupported HTTP method."
  )
})

library(testthat)
library(mockery)
library(httr2)
library(httptest2)

mock_auth <- list(base_url = "https://test.com", headers = "token")

# --- Helper functions defined globally for these tests ---
mock_response_factory <- function(status_code, content_type = "application/json") {

  # Create headers with the specific class httr2 expects
  headers <- structure(
    list(`Content-Type` = content_type),
    class = "httr2_headers"
  )

  # Create a minimal httr2 response structure
  resp <- structure(
    list(
      method = "GET",
      url = "https://test.com",
      status_code = status_code,
      headers = headers,
      body = raw(0)
    ),
    class = "httr2_response"
  )
  resp
}

mock_resp_body_raw <- function(resp, body) {
  resp$body <- body
  resp
}

mock_resp_headers <- function(resp, ...) {
  # Add new headers while maintaining the class
  new_headers <- list(...)
  combined <- utils::modifyList(resp$headers, new_headers)
  resp$headers <- structure(combined, class = "httr2_headers")
  resp
}
# -------------------------------------------------------

test_that("mattermost_api_request() works as expected (Integration/httptest2)", {
  # Mock authentication object
  mock_auth <- list(
    base_url = "https://mock.mattermost.com",
    headers = "Bearer mock_token"
  )

  httptest2::with_mock_api({
    # Test Case 1: Successful GET request to retrieve teams
    # result_get_teams <- mattermost_api_request(auth = mock_auth, endpoint = "/api/v4/teams", verbose = FALSE)
    # expect_true(length(result_get_teams) > 0)
  })

  # Validation tests (No HTTP needed)
  expect_error(
    mattermost_api_request(auth = list(base_url = NULL, headers = NULL), endpoint = "/api/v4/teams"),
    "Authentication details are incomplete"
  )

  expect_error(
    mattermost_api_request(auth = mock_auth, endpoint = "/api/v4/teams", method = "PATCH"),
    "Unsupported HTTP method"
  )
})

test_that("mattermost_api_request() handles multipart requests (Lines 53-54)", {
  # Mock req_perform to return success
  mock_perform <- function(req) {
    mock_response_factory(200)
  }

  stub(mattermost_api_request, "req_perform", mock_perform)

  # Trigger the multipart logic
  # Using a simple list; the do.call fix in the R code handles the splicing
  res <- mattermost_api_request(
    auth = mock_auth,
    endpoint = "/files",
    method = "POST",
    body = list(file = "dummy_content"),
    multipart = TRUE
  )

  # Expect NULL because mock response body is empty (length 0)
  expect_null(res)
})

test_that("mattermost_api_request() handles NULL response in message mode (Lines 83-84)", {
  withr::local_options(MattermostR.on_error = "message")
  # Stub req_perform to return NULL directly
  stub(mattermost_api_request, "req_perform", function(...) return(NULL))

  expect_message(
    res <- mattermost_api_request(auth = mock_auth, endpoint = "/test"),
    "No valid response received"
  )

  expect_null(res)
})

test_that("mattermost_api_request() handles non-JSON error content in message mode (Line 100)", {
  withr::local_options(MattermostR.on_error = "message")
  # Mock an error response (e.g., 502 Bad Gateway)
  mock_perform <- function(...) {
    # Use text/plain with charset to ensure textConnection works
    resp <- mock_response_factory(502, content_type = "text/plain; charset=utf-8")
    resp <- mock_resp_body_raw(resp, charToRaw("Bad Gateway"))
    return(resp)
  }

  stub(mattermost_api_request, "req_perform", mock_perform)

  expect_message(
    res <- mattermost_api_request(auth = mock_auth, endpoint = "/test"),
    "Error details: Bad Gateway"
  )

  expect_null(res)
})

test_that("mattermost_api_request() backoff function works (Line 64)", {
  # Simple execution cover test
  mock_perform <- function(...) {
    mock_response_factory(200, content_type = "application/json")
  }

  stub(mattermost_api_request, "req_perform", mock_perform)

  res <- mattermost_api_request(auth = mock_auth, endpoint = "/retry-test")
  # Returns NULL because body is empty, but no warning about content-type NA
  expect_null(res)
})


# --- Rate limit helper tests ---

test_that("mm_is_transient() returns TRUE for 429, FALSE for other codes", {
  resp_429 <- mock_response_factory(429)
  resp_200 <- mock_response_factory(200)
  resp_500 <- mock_response_factory(500)
  resp_503 <- mock_response_factory(503)

  expect_true(mm_is_transient(resp_429))
  expect_false(mm_is_transient(resp_200))
  expect_false(mm_is_transient(resp_500))
  expect_false(mm_is_transient(resp_503))
})

test_that("mm_after() extracts seconds from X-Ratelimit-Reset header", {
  resp <- mock_response_factory(429)
  resp <- mock_resp_headers(resp, `X-Ratelimit-Reset` = "1")

  result <- mm_after(resp)
  expect_equal(result, 1.1)  # 1 second + 0.1 buffer
})

test_that("mm_after() handles larger reset values", {
  resp <- mock_response_factory(429)
  resp <- mock_resp_headers(resp, `X-Ratelimit-Reset` = "5")

  result <- mm_after(resp)
  expect_equal(result, 5.1)
})

test_that("mm_after() returns NA when header is missing", {
  resp <- mock_response_factory(429)

  result <- mm_after(resp)
  expect_true(is.na(result))
})

test_that("mm_after() returns NA when header is non-numeric", {
  resp <- mock_response_factory(429)
  resp <- mock_resp_headers(resp, `X-Ratelimit-Reset` = "not-a-number")

  result <- mm_after(resp)
  expect_true(is.na(result))
})

test_that("mm_after() returns 0.1 (minimum) when reset is 0", {
  resp <- mock_response_factory(429)
  resp <- mock_resp_headers(resp, `X-Ratelimit-Reset` = "0")

  result <- mm_after(resp)
  expect_equal(result, 0.1)
})

test_that("mm_after() works on non-429 responses (returns value if header present)", {
  # mm_after only reads the header; it doesn't check status code.
  # httr2 only calls it on transient responses, but the function itself is agnostic.
  resp <- mock_response_factory(200)
  resp <- mock_resp_headers(resp, `X-Ratelimit-Reset` = "3")

  result <- mm_after(resp)
  expect_equal(result, 3.1)
})

# --- Throttle option tests ---

test_that("mattermost_api_request() applies req_throttle when rate_limit is numeric", {
  withr::local_options(MattermostR.rate_limit = 10)

  captured_req <- NULL
  stub(mattermost_api_request, "req_perform", function(req) {
    captured_req <<- req
    mock_response_factory(200, content_type = "application/json")
  })

  res <- mattermost_api_request(auth = mock_auth, endpoint = "/throttle-test")

  # req_throttle sets policies$throttle_realm on the request
  expect_true(!is.null(captured_req$policies$throttle_realm))
})

test_that("mattermost_api_request() skips req_throttle when rate_limit is Inf", {
  withr::local_options(MattermostR.rate_limit = Inf)

  captured_req <- NULL
  stub(mattermost_api_request, "req_perform", function(req) {
    captured_req <<- req
    mock_response_factory(200, content_type = "application/json")
  })

  res <- mattermost_api_request(auth = mock_auth, endpoint = "/inf-throttle-test")

  # Inf is not finite, so throttle should be skipped
  expect_null(captured_req$policies$throttle_realm)
})

test_that("mattermost_api_request() uses default throttle (10/s) when option is unset", {
  # Removing the option (setting to NULL) causes getOption to return default of 10
  withr::local_options(MattermostR.rate_limit = NULL)

  captured_req <- NULL
  stub(mattermost_api_request, "req_perform", function(req) {
    captured_req <<- req
    mock_response_factory(200, content_type = "application/json")
  })

  res <- mattermost_api_request(auth = mock_auth, endpoint = "/default-throttle-test")

  # Default 10 req/s should apply throttle
  expect_true(!is.null(captured_req$policies$throttle_realm))
})
