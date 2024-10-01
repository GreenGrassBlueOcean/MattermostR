library(testthat)
library(mockery)
library(httr2)

# Function to create a mock response object
create_mock_response <- function(content_type, body_content, status_code = 200) {
  # Convert body content to raw format
  body_raw <- charToRaw(body_content)

  list(
    cache = new.env(),  # Create an environment for the cache
    headers = list(`content-type` = content_type),
    status_code = status_code,
    body = body_raw,  # Store the body as a raw vector
    # Define methods to mimic the actual response object
    resp_content_type = function() content_type,
    resp_body_json = function(...) {
      jsonlite::fromJSON(rawToChar(body_raw), simplifyVector = TRUE)  # Use body_raw here
    },
    resp_body_string = function() rawToChar(body_raw)  # Convert raw to char for plain text
  )
}

# Define the function to be tested
handle_response_content <- function(response, verbose) {
  content_type <- response$resp_content_type()

  # Check if the response is JSON
  if (grepl("application/json", content_type)) {
    if (verbose) {
      message("Response Body:")
      print(response$resp_body_json())
    }
    return(response$resp_body_json())

    # If content type is not JSON, handle plain text or other types gracefully
  } else if (grepl("text/plain", content_type)) {
    if (verbose) {
      message("Response Body (Plain Text):")
      print(response$resp_body_string())
    }
    return(response$resp_body_string())
  } else {
    message(sprintf("Unexpected content type '%s' received.", content_type))
    message("Response Body:")
    print(response$resp_body_string())
    warning("Received unexpected content type from server.")
    return(NULL)
  }
}

# Unit tests
test_that("handle_response_content processes responses correctly", {

  # Test case 1: JSON response
  response_json <- create_mock_response("application/json", '{"id": "1", "name": "test"}')
  result <- handle_response_content(response_json, verbose = FALSE)
  expect_equal(result$id, "1")
  expect_equal(result$name, "test")

  # Test case 2: Plain text response
  response_text <- create_mock_response("text/plain", "This is plain text response")
  result <- handle_response_content(response_text, verbose = FALSE)
  expect_equal(result, "This is plain text response")

  # Test case 3: Unexpected content type
  response_other <- create_mock_response("application/xml", "<note><body>XML Response</body></note>")

  # Expect a warning and a NULL result
  expect_warning(result <- handle_response_content(response_other, verbose = TRUE),
                 "Received unexpected content type from server.")
  expect_null(result)
})

test_that("handle_response_content verbose output works correctly", {

  # Mocking the message function to capture output
  mock_message <- mockery::mock()
  mockery::stub(handle_response_content, "message", mock_message)

  # Test case for JSON response with verbose output
  response_json <- create_mock_response("application/json", '{"id": "1", "name": "test"}')

  result <- handle_response_content(response_json, verbose = TRUE)

  # Verify that messages were printed
  #mockery::expect_called(mock_message, 2)
  expect_equal(mockery::mock_args(mock_message)[[1]][[1]], "Response Body:")
})

