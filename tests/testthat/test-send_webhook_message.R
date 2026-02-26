# Test suite for send_webhook_message

# Helper to build proper httr2 response objects for mocking
mock_webhook_response <- function(status_code = 200L, body = "ok") {
  httr2::response(
    status_code = status_code,
    headers = list(`Content-Type` = "text/plain"),
    body = charToRaw(body)
  )
}

test_that("send_webhook_message() validates webhook_url", {
  # NULL webhook_url
  expect_error(
    send_webhook_message(webhook_url = NULL, text = "hi"),
    "webhook_url cannot be empty or NULL"
  )

  # Empty string webhook_url
  expect_error(
    send_webhook_message(webhook_url = "", text = "hi"),
    "webhook_url cannot be empty or NULL"
  )
})

test_that("send_webhook_message() requires text or attachments", {
  expect_error(
    send_webhook_message(webhook_url = "https://example.com/hooks/abc"),
    "At least one of 'text' or 'attachments' must be provided."
  )

  # Both NULL explicitly
  expect_error(
    send_webhook_message(webhook_url = "https://example.com/hooks/abc",
                         text = NULL, attachments = NULL),
    "At least one of 'text' or 'attachments' must be provided."
  )
})

test_that("send_webhook_message() sends text-only message successfully", {
  mockery::stub(send_webhook_message, "httr2::req_perform",
                mock_webhook_response())

  result <- send_webhook_message(
    webhook_url = "https://example.com/hooks/abc",
    text = "Hello from R!"
  )

  expect_s3_class(result, "httr2_response")
})

test_that("send_webhook_message() sends attachments-only message successfully", {
  mockery::stub(send_webhook_message, "httr2::req_perform",
                mock_webhook_response())

  result <- send_webhook_message(
    webhook_url = "https://example.com/hooks/abc",
    attachments = list(list(title = "Alert", text = "Something happened"))
  )

  expect_s3_class(result, "httr2_response")
})

test_that("send_webhook_message() stops on HTTP error", {
  mockery::stub(send_webhook_message, "httr2::req_perform",
                mock_webhook_response(status_code = 400L, body = "Invalid webhook"))

  expect_error(
    send_webhook_message(
      webhook_url = "https://example.com/hooks/bad",
      text = "test"
    ),
    "Webhook request failed with HTTP 400"
  )
})

test_that("send_webhook_message() stops on server error", {
  mockery::stub(send_webhook_message, "httr2::req_perform",
                mock_webhook_response(status_code = 500L, body = "Internal Server Error"))

  expect_error(
    send_webhook_message(
      webhook_url = "https://example.com/hooks/bad",
      text = "test"
    ),
    "Webhook request failed with HTTP 500"
  )
})

test_that("send_webhook_message() includes all optional parameters in body", {
  captured_req <- NULL
  mock_perform <- function(req) {
    captured_req <<- req
    mock_webhook_response()
  }

  mockery::stub(send_webhook_message, "httr2::req_perform", mock_perform)

  result <- send_webhook_message(
    webhook_url = "https://example.com/hooks/abc",
    text = "hello",
    channel = "town-square",
    username = "TestBot",
    icon_url = "https://example.com/icon.png",
    icon_emoji = ":robot:",
    attachments = list(list(title = "A")),
    props = list(card = "Extra info"),
    priority = list(priority = "important")
  )

  expect_s3_class(result, "httr2_response")
})

test_that("send_webhook_message() returns response invisibly", {
  mockery::stub(send_webhook_message, "httr2::req_perform",
                mock_webhook_response())

  expect_invisible(
    send_webhook_message(
      webhook_url = "https://example.com/hooks/abc",
      text = "silent"
    )
  )
})
