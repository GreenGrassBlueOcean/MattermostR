# File: tests/testthat/test-mattermost_api_request_with_http_errors.R

# Mock function to simulate different HTTP error responses
mock_error_response <- function(status_code, body) {
  function(...) {
    structure(
      list(
        method = "POST",
        url = "https://fakeurl.com/api/v4/channels",
        status_code = status_code,
        headers = structure(
          list(
            Server = "nginx",
            Date = "Wed, 02 Oct 2024 20:59:40 GMT",
            `Content-Type` = "application/json",
            `Content-Length` = as.character(nchar(body)),
            Connection = "keep-alive"
          ),
          class = "httr2_headers"
        ),
        body = as.raw(charToRaw(body)),
        # Provide a minimal environment to avoid NULL cache errors
        cache = new.env()
      ),
      class = "httr2_response"
    )
  }
}

test_that("mattermost_api_request handles specific error responses correctly", {
  # Mock auth details
  mock_auth <- list(base_url = "https://fakeurl.com", headers = "Bearer TOKEN")

  # Test Case 1: HTTP 400 Bad Request with real error message
  expect_message(
    with_mocked_bindings(
      req_perform = mock_error_response(400, '{"id":"store.sql_channel.save_channel.exists.app_error","message":"A channel with that name already exists on the same team.","status_code":400}'),
      {
        result_400 <- mattermost_api_request(
          auth = mock_auth,
          endpoint = "/api/v4/channels",
          method = "POST",
          body = list(name = "some-channel")
        )
        expect_null(result_400)
      }
    ),
    regexp = "HTTP error occurred: 400 Bad Request"
  )

  # Further assert that the detailed error message is correctly logged
  expect_message(
    with_mocked_bindings(
      req_perform = mock_error_response(400, '{"id":"store.sql_channel.save_channel.exists.app_error","message":"A channel with that name already exists on the same team.","status_code":400}'),
      {
        result_400 <- mattermost_api_request(
          auth = mock_auth,
          endpoint = "/api/v4/channels",
          method = "POST",
          body = list(name = "some-channel")
        )
        expect_null(result_400)
      }
    ),
    regexp = "A channel with that name already exists on the same team"
  )

  # Test Case 2: HTTP 401 Unauthorized - Simulate a common error scenario
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

  # Test Case 3: HTTP 403 Forbidden - Another realistic error case
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

  # Test Case 4: HTTP 404 Not Found - Simulate a case where a resource is missing
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

  # Test Case 5: HTTP 500 Internal Server Error - Simulate a server-side failure
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

# additional tests -->
# Mock function to simulate different HTTP error responses
mock_error_response <- function(status_code, body) {
  function(...) {
    structure(
      list(
        method = "POST",
        url = "https://fakeurl.com/api/v4/channels",
        status_code = status_code,
        headers = structure(
          list(
            Server = "nginx",
            Date = "Wed, 02 Oct 2024 20:59:40 GMT",
            `Content-Type` = "application/json",
            `Content-Length` = as.character(nchar(body)),
            Connection = "keep-alive"
          ),
          class = "httr2_headers"
        ),
        body = as.raw(charToRaw(body)),
        # Provide a minimal environment to avoid NULL cache errors
        cache = new.env()
      ),
      class = "httr2_response"
    )
  }
}

test_that("mattermost_api_request handles specific error responses correctly", {
  # Mock auth details
  mock_auth <- list(base_url = "https://fakeurl.com", headers = "Bearer TOKEN")

  # Test Case 1: HTTP 400 Bad Request with real error message
  expect_message(
    with_mocked_bindings(
      req_perform = mock_error_response(400, '{"id":"store.sql_channel.save_channel.exists.app_error","message":"A channel with that name already exists on the same team.","status_code":400}'),
      {
        result_400 <- mattermost_api_request(
          auth = mock_auth,
          endpoint = "/api/v4/channels",
          method = "POST",
          body = list(name = "some-channel")
        )
        expect_null(result_400)
      }
    ),
    regexp = "HTTP error occurred: 400 Bad Request"
  )

  # Further assert that the detailed error message is correctly logged
  expect_message(
    with_mocked_bindings(
      req_perform = mock_error_response(400, '{"id":"store.sql_channel.save_channel.exists.app_error","message":"A channel with that name already exists on the same team.","status_code":400}'),
      {
        result_400 <- mattermost_api_request(
          auth = mock_auth,
          endpoint = "/api/v4/channels",
          method = "POST",
          body = list(name = "some-channel")
        )
        expect_null(result_400)
      }
    ),
    regexp = "A channel with that name already exists on the same team"
  )

  # Test Case 2: HTTP 401 Unauthorized - Simulate a common error scenario
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

  # Test Case 3: HTTP 403 Forbidden - Another realistic error case
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

  # Test Case 4: HTTP 404 Not Found - Simulate a case where a resource is missing
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

  # Test Case 5: HTTP 500 Internal Server Error - Simulate a server-side failure
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
