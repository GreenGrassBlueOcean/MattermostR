#' Authenticate with Mattermost API
#'
#' @param base_url The base URL of the Mattermost server. Do not add the team name here so really only  "https://yourmattermost.stackhero-network.com/"
#' @param token Optional. The Bearer token for authentication. If NULL, it will be retrieved from options().
#' @param username Optional. The username for login if not using a token.
#' @param password Optional. The password for login if not using a token.
#' @param test_connection Boolean. If `TRUE`, the function will check the connection status with Mattermost.
#'
#' @return A `mattermost_auth` object containing `base_url` and `headers` for further API calls.
#' @export
#' @examples
#' \dontrun{
#' authenticate_mattermost(base_url = "https://mattermost.stackhero-network.com"
#' , token = "your token", test_connection = TRUE)
#' }
authenticate_mattermost <- function(base_url, token = NULL, username = NULL, password = NULL, test_connection = FALSE) {

  # 1. Check and retrieve token if not provided
  if (is.null(token)) {
    token <- getOption("mattermost.token", NULL)
  }

  # 2. If token is still NULL, attempt to authenticate with username and password
  if (is.null(token)) {
    if (is.null(username) || is.null(password)) {
      stop("Please supply the Bearer token or both username and password.")
    }

    # Prepare the login request
    endpoint <- "/api/v4/users/login"
    body <- list(
      login_id = username,
      password = password
    )

    # Set headers for the login request
    headers <- list(
      "Content-Type" = "application/json",
      Accept = "application/json"
    )

    # Send the login request using the mattermost_api_request function
    response <- mattermost_api_request(
      auth = list(base_url = base_url, headers = headers),
      endpoint = endpoint,
      method = "POST",
      body = body
    )

    # Check if the response is successful and extract the token
    if (httr2::resp_status(response) == 200) {
      token <- httr2::resp_header(response, "Token")
    } else {
      stop("Login failed. Please check your username and password.")
    }
  }

  # 3. Store the Bearer token in options for future use
  options(mattermost.token = token)

  # 4. Store the base_url in options for future use
  if (missing(base_url) || !nzchar(base_url)) {
    base_url <- getOption("mattermost.base_url", NULL)
    if (is.null(base_url)) {
      stop("Please provide a valid 'base_url'.")
    }
  } else {
    options(mattermost.base_url = base_url)  # Store the base_url if provided
  }

  # 5. Prepare the authentication list
  auth <- list(base_url = base_url, headers = paste("Bearer", token))

  # Assign the class to the auth object
  class(auth) <- "mattermost_auth"

  # 6. Test connection if required
  if (test_connection) {
    response <- check_mattermost_status(verbose = FALSE, auth)
    if (response != TRUE) {
      stop("Connection to Mattermost failed.")
    }
  }

  return(auth)
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




#' Check Mattermost server status
#'
#' @param auth A list containing `base_url` and `headers` for authentication.
#'
#' @return The response object from the Mattermost API request.
check_mattermost_status <- function(auth) {
  endpoint <- "/api/v4/system/ping"
  response <- mattermost_api_request(auth, endpoint, method = "GET", verbose = TRUE)
  return(response)
}
