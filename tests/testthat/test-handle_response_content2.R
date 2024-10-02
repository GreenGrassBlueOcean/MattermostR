test_that("handle_response_content() handles JSON content correctly", {
  # Mock a JSON response
  mock_response <- httr2::response(
    method = "GET",
    url = "https://mock.mattermost.com/api/v4/endpoint",
    status_code = 200,
    headers = list("Content-Type" = "application/json"),
    body = charToRaw('{"key": "value"}')
  )

  # Test without verbose
  result <- handle_response_content(mock_response, verbose = FALSE)
  expect_equal(result$key, "value")

  # Test verbose output with adjusted expectations
  expect_output(handle_response_content(mock_response, verbose = TRUE), "Content-Type: application/json")
  expect_output(handle_response_content(mock_response, verbose = TRUE), "\\$key")
  expect_output(handle_response_content(mock_response, verbose = TRUE), "\\[1\\] \"value\"")
})

test_that("handle_response_content() handles plain text content correctly", {
  # Mock a plain text response
  mock_response <- httr2::response(
    method = "GET",
    url = "https://mock.mattermost.com/api/v4/endpoint",
    status_code = 200,
    headers = list("Content-Type" = "text/plain"),
    body = charToRaw("Plain text content")
  )

  # Test without verbose
  result <- handle_response_content(mock_response, verbose = FALSE)
  expect_equal(result, "Plain text content")

  # Test verbose output
  expect_output(handle_response_content(mock_response, verbose = TRUE), "Content-Type: text/plain")
  expect_output(handle_response_content(mock_response, verbose = TRUE), "Plain text content")
})

test_that("handle_response_content() handles unexpected content type correctly", {
  # Mock a response with an unexpected content type
  mock_response <- httr2::response(
    method = "GET",
    url = "https://mock.mattermost.com/api/v4/endpoint",
    status_code = 200,
    headers = list("Content-Type" = "application/octet-stream"),
    body = charToRaw("Binary data here")
  )

  # Test without verbose, suppressing warnings
  result <- suppressWarnings(handle_response_content(mock_response, verbose = FALSE))
  expect_null(result)

  # Test verbose output, focusing on key parts of the response
  expect_output(suppressWarnings(handle_response_content(mock_response, verbose = TRUE)), "Content-Type: application/octet-stream", fixed = TRUE)
  expect_output(suppressWarnings(handle_response_content(mock_response, verbose = TRUE)), "[1] \"Binary data here\"", fixed = TRUE)
  expect_warning(handle_response_content(mock_response, verbose = TRUE), "Unexpected content type")
})


test_that("handle_response_content() handles empty response body", {
  # Mock a response with an empty body
  mock_response <- httr2::response(
    method = "GET",
    url = "https://mock.mattermost.com/api/v4/endpoint",
    status_code = 200,
    headers = list("Content-Type" = "application/json"),
    body = raw(0)  # Empty body
  )

  # Test without verbose
  result <- handle_response_content(mock_response, verbose = FALSE)
  expect_null(result)

  # Test verbose output
  result <- handle_response_content(mock_response, verbose = TRUE)
  expect_null(result)
})


test_that("handle_response_content() handles JSON parsing error gracefully", {
  # Mock a response with malformed JSON
  mock_response <- httr2::response(
    method = "GET",
    url = "https://mock.mattermost.com/api/v4/endpoint",
    status_code = 200,
    headers = list("Content-Type" = "application/json"),
    body = charToRaw('{"key": "value", "invalid_json": }')  # Malformed JSON
  )

  # Expect warning for parsing error and return NULL
  expect_warning(
    result <- handle_response_content(mock_response, verbose = FALSE),
    "Failed to parse JSON content"
  )
  expect_null(result)

  # Test verbose output includes parsing error
  expect_warning(
    handle_response_content(mock_response, verbose = TRUE),
    "Failed to parse JSON content"
  )
})

test_that("handle_response_content() handles error in content type retrieval", {
  # Mock a response with missing content type header
  mock_response <- httr2::response(
    method = "GET",
    url = "https://mock.mattermost.com/api/v4/endpoint",
    status_code = 200,
    headers = list(),  # Missing content-type header
    body = charToRaw("Some body content")
  )

  # Test that the function returns NULL and throws a warning
  expect_warning(result <- handle_response_content(mock_response, verbose = FALSE), "Content type is NA")
  expect_null(result)
})

test_that("handle_response_content() handles error in content type retrieval", {

  # Test that the function returns NULL and throws a warning
  expect_warning(expect_warning(resultx <- handle_response_content(NULL, verbose = TRUE)
                ,"Failed to retrieve content type: `resp` must be an HTTP response object, not `NULL`.")
                ,"Content type is NA; cannot process response.")
  expect_null(resultx)
})


