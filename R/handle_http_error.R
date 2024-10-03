# File: R/http_error_handler.R

#' Handle HTTP Errors from httr2 Requests
#'
#' This function processes different types of HTTP errors that may arise during
#' API requests using the `httr2` package.
#'
#' @param e An error object returned from an `httr2` request.
#' @noRd
handle_http_error <- function(e) {
  # Extract message from error object without using conditionMessage()
  error_message <- e$message

  # Check if it's an httr2 error with a response
  if (inherits(e, "httr2_http_error") && !is.null(e$response)) {
    # Extract response body safely
    resp_body <- tryCatch({
      httr2::resp_body_string(e$response)
    }, error = function(err) {
      "<Unable to decode response body>"
    })

    # Display status code and response body
    message("HTTP error occurred: ", error_message)
    message("Status Code: ", httr2::resp_status(e$response))
    message("Response Body: ", resp_body)
  } else if (!is.null(e$resp)) {
    # For older httr2 versions or alternative error structures
    resp_body <- tryCatch({
      httr2::resp_body_string(e$resp)
    }, error = function(err) {
      "<Unable to decode response body>"
    })

    message("HTTP error occurred: ", error_message)
    message("Status Code: ", httr2::resp_status(e$resp))
    message("Response Body: ", resp_body)
  } else {
    # General error case without a specific response
    message("HTTP error occurred: ", error_message)
  }

  return(NULL)  # Return NULL to indicate the request failed
}
