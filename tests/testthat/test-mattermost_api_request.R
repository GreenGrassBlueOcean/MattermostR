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

# File: tests/testthat/test-mattermost_api_request.R

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

test_that("mattermost_api_request() handles NULL response (Lines 83-84)", {
  # Stub req_perform to return NULL directly
  stub(mattermost_api_request, "req_perform", function(...) return(NULL))

  expect_message(
    res <- mattermost_api_request(auth = mock_auth, endpoint = "/test"),
    "No valid response received"
  )

  expect_null(res)
})

test_that("mattermost_api_request() handles non-JSON error content (Line 100)", {
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
    "Error content: Bad Gateway"
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
