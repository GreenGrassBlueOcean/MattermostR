
#' Construct a mattermost_error condition
#'
#' Creates an S3 condition object of class \code{mattermost_error} that can be
#' caught with \code{tryCatch(..., mattermost_error = function(e) ...)}.
#'
#' @param message Human-readable error description.
#' @param status_code HTTP status code (integer), or \code{NA} for connection errors.
#' @param response_body Response body string, or \code{NULL}.
#' @param endpoint The API endpoint that was called.
#' @param method The HTTP method used.
#' @param call The call to include in the condition (default: caller's caller).
#' @return A condition object — never returned, always signalled.
#' @noRd
mattermost_error <- function(message, status_code = NA_integer_, response_body = NULL,
                             endpoint = "", method = "", call = sys.call(-1)) {
  structure(
    class = c("mattermost_error", "error", "condition"),
    list(
      message       = message,
      status_code   = status_code,
      response_body = response_body,
      endpoint      = endpoint,
      method        = method,
      call          = call
    )
  )
}

#' Raise or message a Mattermost error depending on the on_error option
#'
#' Central error dispatch.
#' When \code{getOption("MattermostR.on_error", "stop")} is \code{"stop"},
#' stops with a \code{mattermost_error} condition.
#' When \code{"message"}, emits \code{message()} and returns \code{NULL}
#' (legacy behaviour).
#'
#' @param msg Human-readable error description.
#' @param status_code HTTP status code (integer), or \code{NA}.
#' @param response_body Response body string, or \code{NULL}.
#' @param endpoint The API endpoint.
#' @param method The HTTP method.
#' @return \code{NULL} (only reached in \code{"message"} mode).
#' @noRd
raise_mattermost_error <- function(msg, status_code = NA_integer_, response_body = NULL,
                                   endpoint = "", method = "") {
  on_error <- getOption("MattermostR.on_error", "stop")

  if (identical(on_error, "stop")) {
    cond <- mattermost_error(
      message       = msg,
      status_code   = status_code,
      response_body = response_body,
      endpoint      = endpoint,
      method        = method,
      call          = sys.call(-1)
    )
    stop(cond)
  }

  # Legacy "message" mode — emit message(s) and return NULL
  message(msg)
  return(NULL)
}

#' Handle HTTP Errors from httr2 Requests
#'
#' This function processes different types of HTTP errors that may arise during
#' API requests using the \code{httr2} package.  It extracts status codes and
#' response bodies where available and delegates to \code{raise_mattermost_error()}.
#'
#' @param e An error object returned from an \code{httr2} request.
#' @param endpoint The API endpoint (for context in the error).
#' @param method The HTTP method (for context in the error).
#' @noRd
handle_http_error <- function(e, endpoint = "", method = "") {
  error_message <- e$message

  # Extract status code and body from the httr2 error, if available
  resp <- e$response %||% e$resp
  status_code <- NA_integer_
  resp_body   <- NULL

  if (!is.null(resp)) {
    status_code <- tryCatch(httr2::resp_status(resp), error = function(err) NA_integer_)
    resp_body   <- tryCatch(httr2::resp_body_string(resp), error = function(err) "<Unable to decode response body>")
  }

  full_msg <- paste0("HTTP error occurred: ", error_message)
  if (!is.null(resp_body)) {
    full_msg <- paste0(full_msg, "\nStatus Code: ", status_code, "\nResponse Body: ", resp_body)
  }

  raise_mattermost_error(
    msg           = full_msg,
    status_code   = status_code,
    response_body = resp_body,
    endpoint      = endpoint,
    method        = method
  )
}
