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
  req <- req |>
    httr2::req_headers(!!!headers)

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
  req <- req |>
    httr2::req_retry(
      max_tries = 5,
      backoff = function(attempt) { 0.5 * 2^(attempt - 1) } # Exponential backoff
    )

  # Perform the request and handle errors
  response <- tryCatch(
    {
      if (verbose) {
        req <- req |> httr2::req_verbose()
      }
      httr2::req_perform(req)
    },
    httr2_error = function(e) {
      message("HTTP error occurred: ", conditionMessage(e))
      return(NULL)  # Return NULL to indicate the request failed
    }
  )

  # If the response is NULL, stop further processing
  if (is.null(response)) {
    message("No valid response received. Stopping further processing.")
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
handle_response_content <- function(response, verbose) {
  content_type <- httr2::resp_content_type(response)

  if (grepl("application/json", content_type)) {
    if (verbose) {
      message("Response Body:")
      print(httr2::resp_headers(response))
      print(httr2::resp_body_json(response, simplifyVector = TRUE))
    }
    return(httr2::resp_body_json(response, simplifyVector = TRUE))
  } else {
    message(sprintf("Unexpected content type '%s' received.", content_type))
    message("Response Body:")
    print(httr2::resp_headers(response))
    print(httr2::resp_body_string(response))
    warning("Received unexpected content type from server.")
    return(NULL)
  }
}
