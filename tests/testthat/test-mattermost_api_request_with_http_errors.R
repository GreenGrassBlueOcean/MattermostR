# File: tests/testthat/test-mattermost_api_request_with_http_errors.R

test_that("mattermost_api_request() handles errors correctly", {
  library(httptest2)
  library(testthat)

  # Mock authentication object
  mock_auth <- list(
    base_url = "https://mock.mattermost.com",
    headers = "Bearer mock_token"
  )

  # Updated mock HTTP response generator
  mock_error_response <- function(status_code, content) {
    function(req) {
      httr2::response(
        method = req$method,
        url = req$url,
        status_code = status_code,
        headers = list("Content-Type" = "application/json"),
        body = charToRaw(content)
      )
    }
  }

  # Test Case: HTTP 400 Bad Request
  expect_message(
    with_mocked_bindings(
      req_perform = mock_error_response(400, '{"id":"api.context.400","message":"Bad Request","status_code":400}'),
      {
        result_400 <- mattermost_api_request(
          auth = mock_auth,
          endpoint = "/api/v4/invalid_endpoint",
          method = "GET"
        )
        expect_null(result_400)
      }
    ),
    regexp = "HTTP error occurred: 400 Bad Request"
  )

  # Test Case: HTTP 401 Unauthorized
  expect_message(
    with_mocked_bindings(
      req_perform = mock_error_response(401, '{"id":"api.context.401","message":"Unauthorized","status_code":401}'),
      {
        result_401 <- mattermost_api_request(
          auth = list(base_url = mock_auth$base_url, headers = "Bearer invalid_token"),
          endpoint = "/api/v4/teams",
          method = "GET"
        )
        expect_null(result_401)
      }
    ),
    regexp = "HTTP error occurred: 401 Unauthorized"
  )

  # Test Case: HTTP 403 Forbidden
  expect_message(
    with_mocked_bindings(
      req_perform = mock_error_response(403, '{"id":"api.context.403","message":"Forbidden","status_code":403}'),
      {
        result_403 <- mattermost_api_request(
          auth = mock_auth,
          endpoint = "/api/v4/teams/forbidden_team/channels",
          method = "GET"
        )
        expect_null(result_403)
      }
    ),
    regexp = "HTTP error occurred: 403 Forbidden"
  )

  # Test Case: HTTP 404 Not Found
  expect_message(
    with_mocked_bindings(
      req_perform = mock_error_response(404, '{"id":"api.context.404","message":"Not Found","status_code":404}'),
      {
        result_404 <- mattermost_api_request(
          auth = mock_auth,
          endpoint = "/api/v4/teams/nonexistent_team/channels",
          method = "GET"
        )
        expect_null(result_404)
      }
    ),
    regexp = "HTTP error occurred: 404 Not Found"
  )

  # Test Case: HTTP 500 Internal Server Error
  expect_message(
    with_mocked_bindings(
      req_perform = mock_error_response(500, '{"id":"api.context.500","message":"Internal Server Error","status_code":500}'),
      {
        result_500 <- mattermost_api_request(
          auth = mock_auth,
          endpoint = "/api/v4/teams",
          method = "POST",
          body = list(invalid_field = "test")
        )
        expect_null(result_500)
      }
    ),
    regexp = "HTTP error occurred: 500 Internal Server Error"
  )
})
