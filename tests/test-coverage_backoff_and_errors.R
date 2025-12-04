library(testthat)
library(mockery)
library(httr2)

mock_auth <- list(base_url = "https://test.com", headers = "token")

test_that("mattermost_api_request() defines correct backoff logic (Line 64)", {
  # We stub 'req_retry' to capture and test the 'backoff' function passed to it.

  stub(MattermostR::mattermost_api_request, "httr2::req_retry", function(req, max_tries, backoff, ...) {
    # 1. Test the logic of Line 64 explicitly
    # Formula: 0.5 * 2^(attempt - 1)
    expect_equal(backoff(1), 0.5)  # 0.5 * 2^0 = 0.5
    expect_equal(backoff(2), 1.0)  # 0.5 * 2^1 = 1.0
    expect_equal(backoff(3), 2.0)  # 0.5 * 2^2 = 2.0

    # Return the request object so the main function continues
    return(req)
  })

  # Stub req_perform to prevent actual HTTP
  # FIX: Provide a complete response object with Content-Type to avoid warnings
  stub(MattermostR::mattermost_api_request, "req_perform", function(req) {
    structure(
      list(
        status_code = 200,
        headers = structure(list(`Content-Type` = "application/json"), class = "httr2_headers"),
        body = raw(0)
      ),
      class = "httr2_response"
    )
  })

  # Execute function to trigger the definition and our stub check
  MattermostR::mattermost_api_request(auth = mock_auth, endpoint = "/test")
})

test_that("mattermost_api_request() triggers error handler on connection failure (Line 76)", {
  # 1. Stub 'req_perform' to simulate a connection error
  stub(MattermostR::mattermost_api_request, "req_perform", function(req) {
    stop("Simulated connection failure")
  })

  # 2. Stub 'handle_http_error' to verify it gets called.
  stub(MattermostR::mattermost_api_request, "handle_http_error", function(e) {
    stop("Caught by handle_http_error: ", e$message)
  })

  # 3. Expect the error we threw from our mock handle_http_error
  expect_error(
    MattermostR::mattermost_api_request(auth = mock_auth, endpoint = "/test"),
    "Caught by handle_http_error: Simulated connection failure"
  )
})
