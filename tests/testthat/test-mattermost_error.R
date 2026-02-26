# Tests for the mattermost_error condition class, raise_mattermost_error(),
# and the MattermostR.on_error option toggle.

# =============================================================================
# mattermost_error condition structure
# =============================================================================

test_that("mattermost_error creates a proper S3 condition", {
  cond <- mattermost_error(
    message       = "test error",
    status_code   = 404L,
    response_body = '{"message":"Not Found"}',
    endpoint      = "/api/v4/teams",
    method        = "GET"
  )

  expect_s3_class(cond, "mattermost_error")
  expect_s3_class(cond, "error")
  expect_s3_class(cond, "condition")
  expect_equal(cond$message, "test error")
  expect_equal(cond$status_code, 404L)
  expect_equal(cond$response_body, '{"message":"Not Found"}')
  expect_equal(cond$endpoint, "/api/v4/teams")
  expect_equal(cond$method, "GET")
})

# =============================================================================
# raise_mattermost_error — "stop" mode (default)
# =============================================================================

test_that("raise_mattermost_error stops with mattermost_error in stop mode", {
  withr::local_options(MattermostR.on_error = "stop")

  err <- tryCatch(
    raise_mattermost_error("bad request", status_code = 400L, endpoint = "/test"),
    mattermost_error = function(e) e
  )

  expect_s3_class(err, "mattermost_error")
  expect_equal(err$status_code, 400L)
  expect_match(err$message, "bad request")
})

test_that("raise_mattermost_error is the default when option is not set", {
  withr::local_options(MattermostR.on_error = NULL)

  expect_error(
    raise_mattermost_error("server error", status_code = 500L),
    class = "mattermost_error"
  )
})

test_that("mattermost_error can be caught with tryCatch", {
  withr::local_options(MattermostR.on_error = "stop")

  result <- tryCatch(
    raise_mattermost_error("unauthorized", status_code = 401L, endpoint = "/api/v4/users"),
    mattermost_error = function(e) {
      list(caught = TRUE, status = e$status_code, endpoint = e$endpoint)
    }
  )

  expect_true(result$caught)
  expect_equal(result$status, 401L)
  expect_equal(result$endpoint, "/api/v4/users")
})

# =============================================================================
# raise_mattermost_error — "message" mode (legacy)
# =============================================================================

test_that("raise_mattermost_error messages and returns NULL in message mode", {
  withr::local_options(MattermostR.on_error = "message")

  expect_message(
    result <- raise_mattermost_error("something failed", status_code = 500L),
    "something failed"
  )
  expect_null(result)
})

# =============================================================================
# mattermost_api_request — stop mode integration
# =============================================================================

test_that("mattermost_api_request raises mattermost_error on HTTP 400 (stop mode)", {
  withr::local_options(MattermostR.on_error = "stop")
  mock_auth <- list(base_url = "https://test.com", headers = "Bearer tok")

  mock_perform <- function(...) {
    structure(
      list(
        method = "POST",
        url = "https://test.com/api/v4/channels",
        status_code = 400L,
        headers = structure(list(`Content-Type` = "application/json"), class = "httr2_headers"),
        body = charToRaw('{"id":"err","message":"Channel exists","status_code":400}'),
        cache = new.env()
      ),
      class = "httr2_response"
    )
  }

  mockery::stub(mattermost_api_request, "req_perform", mock_perform)

  err <- tryCatch(
    mattermost_api_request(auth = mock_auth, endpoint = "/api/v4/channels", method = "POST",
                           body = list(name = "test")),
    mattermost_error = function(e) e
  )

  expect_s3_class(err, "mattermost_error")
  expect_equal(err$status_code, 400L)
  expect_match(err$message, "400 Bad Request")
  expect_match(err$response_body, "Channel exists")
  expect_equal(err$endpoint, "/api/v4/channels")
})

test_that("mattermost_api_request raises mattermost_error on connection failure (stop mode)", {
  withr::local_options(MattermostR.on_error = "stop")
  mock_auth <- list(base_url = "https://test.com", headers = "Bearer tok")

  mockery::stub(mattermost_api_request, "req_perform", function(...) {
    stop("Could not resolve host: test.com")
  })

  expect_error(
    mattermost_api_request(auth = mock_auth, endpoint = "/api/v4/teams"),
    class = "mattermost_error"
  )
})

test_that("mattermost_api_request includes endpoint and method in error", {
  withr::local_options(MattermostR.on_error = "stop")
  mock_auth <- list(base_url = "https://test.com", headers = "Bearer tok")

  mockery::stub(mattermost_api_request, "req_perform", function(...) {
    stop("connection refused")
  })

  err <- tryCatch(
    mattermost_api_request(auth = mock_auth, endpoint = "/api/v4/posts", method = "DELETE"),
    mattermost_error = function(e) e
  )

  expect_equal(err$endpoint, "/api/v4/posts")
  expect_equal(err$method, "DELETE")
})
