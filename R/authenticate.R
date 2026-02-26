#' Authenticate with Mattermost API
#'
#' Creates a \code{mattermost_auth} object for use with all MattermostR functions.
#'
#' @section Credential Resolution:
#' When \code{token} or \code{base_url} are not supplied as arguments, the
#' function looks for them in two places, in order:
#' \enumerate{
#'   \item \strong{Environment variables} — \code{MATTERMOST_TOKEN} and
#'         \code{MATTERMOST_URL}.
#'   \item \strong{R options} — \code{mattermost.token} and
#'         \code{mattermost.base_url}.
#' }
#' Environment variables are the recommended approach in shared or production
#' environments (e.g. RStudio Server, Posit Workbench) because they are not
#' visible to other code running in the same R session.
#'
#' @section Security:
#' By default (\code{cache_credentials = TRUE}), the resolved token and URL are
#' stored in R \code{options()} for convenience. In shared environments, set
#' \code{cache_credentials = FALSE} and pass the returned auth object explicitly,
#' or use \code{\link{clear_mattermost_credentials}()} when done.
#'
#' @param base_url The base URL of the Mattermost server. Do not add the team name here so really only  "https://yourmattermost.stackhero-network.com/"
#' @param token Optional. The Bearer token for authentication. If NULL, resolved
#'   from \code{MATTERMOST_TOKEN} env var, then \code{options("mattermost.token")}.
#' @param username Optional. The username for login if not using a token.
#' @param password Optional. The password for login if not using a token.
#' @param test_connection Boolean. If `TRUE`, the function will check the connection status with Mattermost.
#' @param cache_credentials Boolean. If `TRUE` (default), stores the token and
#'   base URL in R \code{options()} so that subsequent calls can use
#'   \code{get_default_auth()}. Set to \code{FALSE} in shared environments to
#'   avoid exposing the token in session state.
#'
#' @return A `mattermost_auth` object containing `base_url` and `headers` for further API calls.
#' @export
#' @examples
#' \dontrun{
#' # Token-based (caches by default)
#' authenticate_mattermost(base_url = "https://mattermost.stackhero-network.com"
#' , token = "your token", test_connection = TRUE)
#'
#' # Secure: don't cache in options, rely on env vars for subsequent calls
#' auth <- authenticate_mattermost(
#'   base_url = "https://mm.example.com",
#'   token = Sys.getenv("MATTERMOST_TOKEN"),
#'   cache_credentials = FALSE
#' )
#' }
authenticate_mattermost <- function(base_url, token = NULL, username = NULL, password = NULL,
                                    test_connection = FALSE, cache_credentials = TRUE) {

  # 1. Resolve token: argument > env var > options
  if (is.null(token)) {
    token <- resolve_credential("MATTERMOST_TOKEN", "mattermost.token")
  }

  # 2. If token is still NULL, attempt to authenticate with username and password
  if (is.null(token)) {
    if (is.null(username) || is.null(password)) {
      stop("Please supply the Bearer token or both username and password.")
    }

    # Login uses httr2 directly — we don't have a Bearer token yet,
    # and we need the raw response to extract the Token header.
    response <- perform_login_request(base_url, username, password)

    if (httr2::resp_status(response) == 200) {
      token <- httr2::resp_header(response, "Token")
      if (is.null(token) || !nzchar(token)) {
        stop("Login succeeded but no token was returned in the response headers.")
      }
    } else {
      stop("Login failed. Please check your username and password.")
    }
  }

  # 3. Optionally cache credentials in options (default TRUE for backward compat)
  if (cache_credentials) {
    options(mattermost.token = token)
  }

  # 4. Resolve base_url: argument > env var > options
  if (missing(base_url) || !nzchar(base_url)) {
    base_url <- resolve_credential("MATTERMOST_URL", "mattermost.base_url")
    if (is.null(base_url)) {
      stop("Please provide a valid 'base_url'.")
    }
  } else if (cache_credentials) {
    options(mattermost.base_url = base_url)
  }

  # 5. Prepare the authentication list
  auth <- list(base_url = base_url, headers = paste("Bearer", token))

  # Assign the class to the auth object
  class(auth) <- "mattermost_auth"

  # 6. Test connection if required
  if (test_connection) {
    response <- check_mattermost_status(verbose = FALSE, auth = auth)
    if (response != TRUE) {
      stop("Connection to Mattermost failed.")
    }
  }

  return(auth)
}

#' Print a mattermost_auth object
#'
#' Displays the server URL and a masked version of the bearer token to avoid
#' accidentally exposing credentials in console output or logs.
#'
#' @param x A \code{mattermost_auth} object.
#' @param ... Additional arguments (ignored).
#'
#' @return \code{x}, invisibly.
#' @export
print.mattermost_auth <- function(x, ...) {
  token_raw <- sub("^Bearer ", "", x$headers)
  n <- nchar(token_raw)
  if (n > 8) {
    masked <- paste0(substr(token_raw, 1, 4), "...", substr(token_raw, n - 3, n))
  } else {
    masked <- "****"
  }
  cat(sprintf("<mattermost_auth>\n  Server: %s\n  Token:  %s\n", x$base_url, masked))
  invisible(x)
}


#' Check if the object is a valid mattermost_auth object
#'
#' @param auth The object to check.
#'
#' @return NULL if the object is valid, otherwise throws an error.
#' @export
check_mattermost_auth <- function(auth) {
  if (!inherits(auth, "mattermost_auth")) {
    stop("The provided object is not a valid 'mattermost_auth' object.")
  }
}


#' Retrieve the default auth object from cached credentials
#'
#' Internal helper used as the default value for \code{auth} in all exported
#' functions.  Resolves credentials from environment variables first
#' (\code{MATTERMOST_TOKEN} and \code{MATTERMOST_URL}), then falls back to
#' R options (\code{mattermost.token} and \code{mattermost.base_url}).
#' If either is missing from all sources, stops with a clear error message.
#'
#' @return A \code{mattermost_auth} object.
#' @noRd
get_default_auth <- function() {
  token    <- resolve_credential("MATTERMOST_TOKEN", "mattermost.token")
  base_url <- resolve_credential("MATTERMOST_URL", "mattermost.base_url")

  if (is.null(token) || is.null(base_url)) {
    stop(
      "No Mattermost credentials found. ",
      "Set environment variables MATTERMOST_TOKEN and MATTERMOST_URL, ",
      "call authenticate_mattermost() first, or pass an 'auth' object explicitly.",
      call. = FALSE
    )
  }

  auth <- list(base_url = base_url, headers = paste("Bearer", token))
  class(auth) <- "mattermost_auth"
  auth
}


#' Perform the login HTTP request to Mattermost
#'
#' Internal helper that sends a POST to /api/v4/users/login and returns the
#' raw httr2 response object. Separated from authenticate_mattermost() to
#' allow stubbing in tests.
#'
#' @param base_url The base URL of the Mattermost server.
#' @param username The username for login.
#' @param password The password for login.
#' @return An httr2 response object.
#' @noRd
perform_login_request <- function(base_url, username, password) {
  url <- paste0(base_url, "/api/v4/users/login")
  body <- list(login_id = username, password = password)

  req <- httr2::request(url) |>
    httr2::req_method("POST") |>
    httr2::req_headers(
      `Content-Type` = "application/json",
      Accept = "application/json"
    ) |>
    httr2::req_body_json(body) |>
    httr2::req_error(is_error = function(resp) FALSE)

  httr2::req_perform(req)
}


#' Resolve a credential from environment variable or R option
#'
#' Checks the environment variable first, then falls back to the R option.
#' Returns \code{NULL} if neither source provides a non-empty value.
#'
#' @param env_var Character. Name of the environment variable (e.g. \code{"MATTERMOST_TOKEN"}).
#' @param option_name Character. Name of the R option (e.g. \code{"mattermost.token"}).
#' @return The credential value as a string, or \code{NULL}.
#' @noRd
resolve_credential <- function(env_var, option_name) {
  val <- Sys.getenv(env_var, unset = "")
  if (nzchar(val)) return(val)

  val <- getOption(option_name, NULL)
  if (!is.null(val) && nzchar(val)) return(val)

  NULL
}


#' Clear cached Mattermost credentials from R options
#'
#' Removes \code{mattermost.token} and \code{mattermost.base_url} from the
#' current session's R options. Useful in shared environments where you want
#' to ensure the bearer token is not accessible after use.
#'
#' This does not affect environment variables, which should be managed at the
#' OS or container level.
#'
#' @return \code{NULL}, invisibly.
#' @export
#' @examples
#' \dontrun{
#' auth <- authenticate_mattermost(base_url = "https://mm.example.com", token = "secret")
#' # ... use auth ...
#' clear_mattermost_credentials()
#' }
clear_mattermost_credentials <- function() {
  options(mattermost.token = NULL, mattermost.base_url = NULL)
  invisible(NULL)
}
