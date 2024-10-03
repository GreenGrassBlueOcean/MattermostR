# File: R/mattermost_api_request.R

#' Make a Mattermost API Request
#'
#' This function sends an HTTP request to the Mattermost API using authentication details,
#' endpoint, and method provided. It handles retries with exponential backoff for
#' failed requests and supports both regular JSON requests and multipart file uploads.
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
#' @return The content of the response, usually parsed as JSON, or an error message if the request fails.
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
      req <- httr2::req_body_multipart(req, body)
    } else {
      req <- httr2::req_body_json(req, body)
    }
  }

  # Add retry logic with exponential backoff
  req <- httr2::req_retry(
    req,
    max_tries = 5,
    backoff = function(attempt) { 0.5 * 2^(attempt - 1) } # Exponential backoff
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
      handle_http_error(e)
    }
  )


  # If the response is NULL, stop further processing
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

    message("HTTP error occurred: ", status_code, " ", httr2::resp_status_desc(response))

    if (grepl("application/json", content_type)) {
      error_info <- httr2::resp_body_json(response, simplifyVector = TRUE)
      message("Error details: ", jsonlite::toJSON(error_info, auto_unbox = TRUE, pretty = TRUE))
    } else {
      message("Error content: ", error_content)
    }
    return(NULL)
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

