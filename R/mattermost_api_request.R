#' Make a Mattermost API Request
#'
#' This function sends an HTTP request to the Mattermost API using authentication details,
#' endpoint, and method provided. It handles retries with exponential backoff for
#' failed requests and supports both regular JSON requests and multipart file uploads.
#'
#' @section Rate Limiting:
#' Requests are proactively throttled via \code{httr2::req_throttle()} at a rate
#' controlled by \code{getOption("MattermostR.rate_limit", 10)} requests per second.
#' Set to \code{Inf} to disable throttling. The default of 10 matches
#' Mattermost's out-of-the-box server setting (configurable in System Console).
#'
#' If the server returns HTTP 429 (Too Many Requests), the retry logic reads the
#' \code{X-Ratelimit-Reset} header to wait exactly the right number of seconds
#' before retrying.
#'
#' @section Error Handling:
#' By default, HTTP errors and connection failures raise a \code{mattermost_error}
#' condition (an S3 error class) that can be caught with
#' \code{tryCatch(..., mattermost_error = function(e) ...)}.
#'
#' Set \code{options(MattermostR.on_error = "message")} to revert to the legacy
#' behaviour where errors are emitted via \code{message()} and the function
#' returns \code{NULL}.
#'
#' @param auth A list containing the `base_url` and `headers` (which includes the authentication token).
#' @param endpoint A string specifying the API endpoint (e.g., `"/api/v4/teams"`).
#' @param method A string specifying the HTTP method to use. Options include `"GET"`, `"POST"`, `"PUT"`, and `"DELETE"`.
#' @param body (Optional) A list or object representing the body of the request (e.g., for `POST` or `PUT` requests).
#' @param multipart (Logical) Set to `TRUE` if the request includes multipart data (e.g., file upload).
#' @param verbose (Logical) If `TRUE`, detailed information about the request and response will be printed.
#'
#' @importFrom httr2 req_perform
#'
#' @return The content of the response, usually parsed as JSON. On error, raises a
#'   \code{mattermost_error} condition (default) or returns \code{NULL} (legacy mode).
#' @export
mattermost_api_request <- function(auth, endpoint, method = "GET", body = NULL, multipart = FALSE, verbose = FALSE) {
  # Validate the base_url and headers in the auth object
  if (is.null(auth$base_url) || is.null(auth$headers)) {
    stop("Authentication details are incomplete. Please provide a valid base_url and Authorization token.")
  }

  # Build the request URL
  url <- paste0(auth$base_url, endpoint)

  # Create the request with the base URL
  req <- httr2::request(url)

  # Construct headers
  headers <- list(
    Authorization = auth$headers,
    `Content-Type` = "application/json",
    Accept = "application/json"
  )

  # Add headers
  req <- httr2::req_headers(req, !!!headers)

  # Set the request method
  req <- switch(method,
                "GET" = httr2::req_method(req, "GET"),
                "POST" = httr2::req_method(req, "POST"),
                "PUT" = httr2::req_method(req, "PUT"),
                "DELETE" = httr2::req_method(req, "DELETE"),
                stop("Unsupported HTTP method.")
  )

  # Add the body if provided
  if (!is.null(body)) {
    if (multipart) {
      # Use do.call to splice the body list into named arguments for req_body_multipart
      # This effectively does: req_body_multipart(req, file = "path", ...)
      req <- do.call(httr2::req_body_multipart, c(list(.req = req), body))
    } else {
      req <- httr2::req_body_json(req, body)
    }
  }

  # Proactive rate limiting — throttle requests to stay under the server's limit.
  # Default: 10 req/s (Mattermost's out-of-the-box setting).
  # Set options(MattermostR.rate_limit = Inf) to disable throttling.
  rate_limit <- getOption("MattermostR.rate_limit", default = 10)
  if (is.numeric(rate_limit) && length(rate_limit) == 1 && is.finite(rate_limit) && rate_limit > 0) {
    req <- httr2::req_throttle(req, rate = rate_limit)
  }

  # Reactive retry logic with exponential backoff.
  # On 429 (Too Many Requests), mm_after() reads X-Ratelimit-Reset for
  # precise wait timing; for other transient errors, backoff applies.
  req <- httr2::req_retry(
    req,
    max_tries    = 5,
    is_transient = mm_is_transient,
    after        = mm_after,
    backoff      = function(attempt) { 0.5 * 2^(attempt - 1) }
  )

  # Perform the request and handle errors
  response <- tryCatch(
    {
      if (verbose) {
        req <- httr2::req_verbose(req)
      }
      req_perform(req)
    },
    error = function(e) {
      handle_http_error(e, endpoint = endpoint, method = method)
    }
  )


  # If the response is NULL (only reachable in "message" mode), stop further processing
  if (is.null(response)) {
    message("No valid response received. Stopping further processing.")
    return(NULL)
  }

  # Check for HTTP errors
  status_code <- httr2::resp_status(response)
  if (status_code >= 400) {
    # Extract error details from the response
    error_content <- httr2::resp_body_string(response)
    content_type <- httr2::resp_content_type(response)

    # Build a descriptive error message
    detail_msg <- ""
    if (grepl("application/json", content_type)) {
      error_info <- httr2::resp_body_json(response, simplifyVector = TRUE)
      detail_msg <- jsonlite::toJSON(error_info, auto_unbox = TRUE, pretty = TRUE)
    } else {
      detail_msg <- error_content
    }

    full_msg <- paste0(
      "HTTP error occurred: ", status_code, " ", httr2::resp_status_desc(response),
      "\nError details: ", detail_msg
    )

    return(raise_mattermost_error(
      msg           = full_msg,
      status_code   = status_code,
      response_body = error_content,
      endpoint      = endpoint,
      method        = method
    ))
  }


  # Handle the response content
  result <- handle_response_content(response, verbose = verbose)

  return(result)
}

#' Handle the content of the response
#'
#' @param response The response object from the API request.
#' @param verbose Boolean. If `TRUE`, the function will print the response details for more information.
#'
#' @return The response object if the content type is JSON, or a warning if it's not.
handle_response_content <- function(response, verbose = FALSE) {

  # Safely retrieve content type with tryCatch
  content_type <- tryCatch({
    httr2::resp_content_type(response)
  }, error = function(e) {
    warning("Failed to retrieve content type: ", e$message)
    return(NA)
  })

  # If content type is NA, provide a warning and return NULL
  if (is.na(content_type)) {
    warning("Content type is NA; cannot process response.")
    return(NULL)
  }

  # Handle empty response bodies
  if (!httr2::resp_has_body(response) || length(httr2::resp_body_raw(response)) == 0) {
    if (verbose) {
      message("Empty response body.")
    }
    return(NULL)
  }

  # Function to print response details
  print_response_details <- function(response, body) {
    if (verbose) {
      message("Response Headers:")
      print(httr2::resp_headers(response))
      message("Response Body:")
      print(body)
    }
  }

  # Handle JSON content
  if (grepl("application/json", content_type)) {
    body_json <- tryCatch({
      httr2::resp_body_json(response, simplifyVector = TRUE)
    }, error = function(e) {
      warning("Failed to parse JSON content: ", e$message)
      return(NULL)
    })

    print_response_details(response, body_json)
    return(body_json)
  }

  # Handle plain text content
  if (grepl("text/plain", content_type)) {
    body_text <- httr2::resp_body_string(response)
    print_response_details(response, body_text)
    return(body_text)
  }

  # Handle other content types
  warning(sprintf("Unexpected content type '%s' received.", content_type))
  body_text <- httr2::resp_body_string(response)
  print_response_details(response, body_text)

  return(NULL)
}


#' Check if an HTTP response is a transient rate-limit error
#'
#' Used as the \code{is_transient} callback for \code{httr2::req_retry()}.
#' Returns \code{TRUE} for HTTP 429 (Too Many Requests).
#'
#' @param resp An httr2 response object.
#' @return Logical.
#' @noRd
mm_is_transient <- function(resp) {
  httr2::resp_status(resp) == 429
}


#' Extract retry delay from Mattermost rate-limit headers
#'
#' Used as the \code{after} callback for \code{httr2::req_retry()}.
#' Reads the \code{X-Ratelimit-Reset} response header, which Mattermost sets
#' to the number of seconds remaining before the rate-limit window resets.
#' Returns that value (plus a small buffer) so httr2 waits the precise amount.
#' Returns \code{NA} if the header is missing or not numeric, causing httr2
#' to fall back to the exponential backoff function.
#'
#' @param resp An httr2 response object.
#' @return Numeric seconds to wait, or \code{NA}.
#' @noRd
mm_after <- function(resp) {
  reset <- httr2::resp_header(resp, "X-Ratelimit-Reset")
  if (is.null(reset)) return(NA)
  val <- suppressWarnings(as.numeric(reset))
  if (is.na(val)) return(NA)
  # Add a small buffer to avoid racing the reset window boundary.
  max(val + 0.1, 0.1)
}
