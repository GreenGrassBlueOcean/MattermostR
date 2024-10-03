# File: tests/testthat/test-http_error_handler.R

library(testthat)
library(httr2)

# Mock function to simulate different HTTP error responses
mock_error_response <- function(status_code, body) {
  structure(
    list(
      response = structure(
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
          cache = new.env()
        ),
        class = "httr2_response"
      ),
      message = paste("HTTP", status_code, "error")
    ),
    class = c("httr2_http_error", "error")
  )
}

test_that("handle_http_error correctly handles httr2_http_error with response", {
  # Simulate a 400 error
  error_400 <- mock_error_response(400, '{"id":"store.sql_channel.save_channel.exists.app_error","message":"A channel with that name already exists on the same team.","status_code":400}')

  # Expect messages to be printed for status code and response body
  expect_message(handle_http_error(error_400), "HTTP error occurred: HTTP 400 error")
  expect_message(handle_http_error(error_400), "Status Code: 400")

  # Escape curly braces
  expect_message(
    handle_http_error(error_400),
    "Response Body: \\{\"id\":\"store\\.sql_channel\\.save_channel\\.exists\\.app_error\",\"message\":\"A channel with that name already exists on the same team\\.\"",
    fixed = FALSE
  )
})


test_that("handle_http_error correctly handles legacy error structure", {
  # Simulate a legacy error structure
  legacy_error <- structure(
    list(
      resp = structure(
        list(
          method = "POST",
          url = "https://fakeurl.com/api/v4/channels",
          status_code = 500,
          headers = structure(
            list(
              Server = "nginx",
              Date = "Wed, 02 Oct 2024 20:59:40 GMT",
              `Content-Type` = "application/json",
              `Content-Length` = "100",
              Connection = "keep-alive"
            ),
            class = "httr2_headers"
          ),
          body = as.raw(charToRaw('{"id":"store.sql_channel.save_channel.legacy_error","message":"A legacy error occurred.","status_code":500}')),
          cache = new.env()
        ),
        class = "httr2_response"
      ),
      message = "Legacy error occurred"
    ),
    class = "error"
  )

  expect_message(handle_http_error(legacy_error), "HTTP error occurred: Legacy error occurred")
  expect_message(handle_http_error(legacy_error), "Status Code: 500")
  expect_message(handle_http_error(legacy_error), "A legacy error occurred")
})

test_that("handle_http_error handles general HTTP error message properly", {
  # Simulate a general error without specific response
  general_error <- structure(
    list(message = "General HTTP error"),
    class = c("httr2_http_error", "error")
  )

  expect_message(handle_http_error(general_error), "HTTP error occurred: General HTTP error")
})

test_that("handle_http_error handles errors with undecodable response body", {
  # Mock an error response with an unreadable body (invalid raw content)
  error_unreadable_body <- structure(
    list(
      response = structure(
        list(
          method = "POST",
          url = "https://fakeurl.com/api/v4/channels",
          status_code = 500,
          headers = structure(
            list(
              Server = "nginx",
              Date = "Wed, 02 Oct 2024 20:59:40 GMT",
              `Content-Type` = "application/json",
              `Content-Length` = "20",
              Connection = "keep-alive"
            ),
            class = "httr2_headers"
          ),
          # Use invalid raw data to simulate an unreadable body
          body = as.raw(c(0xFF, 0xFE, 0xFD)),  # Invalid UTF-8 sequence
          cache = new.env()
        ),
        class = "httr2_response"
      ),
      message = "Unreadable body error"
    ),
    class = c("httr2_http_error", "error")
  )

  # Mock `resp_body_string` to throw an error when called
  expect_message(
    with_mocked_bindings(
      resp_body_string = function(...) stop("Failed to decode response body"),
      {
        handle_http_error(error_unreadable_body)
      },
      .package = "httr2"
    ),
    regexp = "<Unable to decode response body>"
  )
})


