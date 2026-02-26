
#' Get all known Mattermost users
#'
#' Retrieves a list of user IDs for users known to the authenticated user's
#' server. The exact format depends on the Mattermost API version; typically
#' a character vector of user IDs.
#'
#' @param verbose (Logical) If `TRUE`, detailed information about the request
#'   and response will be printed. Default is `FALSE`.
#' @param auth The authentication object created by [authenticate_mattermost()].
#'
#' @return A character vector of user IDs, or a list depending on the
#'   Mattermost API response.
#' @export
#' @examples
#' \dontrun{
#'   get_all_users()
#' }
get_all_users <- function(verbose = FALSE, auth = get_default_auth()) {

  # Check required input for completeness
  check_mattermost_auth(auth)

  endpoint <- paste0("/api/v4/users/known")

  # Send the request using mattermost_api_request
  response <- mattermost_api_request(
    auth = auth,
    endpoint = endpoint,
    method = "GET"
  )

  return(response)
}

#' Get information about a specific Mattermost user
#'
#' Retrieves detailed information about a user, such as their username, email,
#' roles, and ID. Use the special string `"me"` as `user_id` to retrieve
#' information about the currently authenticated user.
#'
#' @param user_id A character string containing the Mattermost user ID, or
#'   `"me"` for the authenticated user.
#' @param verbose (Logical) If `TRUE`, detailed information about the request
#'   and response will be printed. Default is `FALSE`.
#' @param auth The authentication object created by [authenticate_mattermost()].
#'
#' @return A named list with user fields returned by the Mattermost API
#'   (e.g. `id`, `username`, `email`, `roles`).
#' @export
#' @examples
#' \dontrun{
#'   # Get info about a specific user by ID
#'   user <- get_user("xb123abc456...")
#'
#'   # Get info about the current authenticated user
#'   myself <- get_user("me")
#'   print(myself$username)
#'
#'   # Iterate over all known users
#'   users <- get_all_users()
#'   userinfo <- lapply(users, get_user)
#' }
get_user <- function(user_id = NULL, verbose = FALSE, auth = get_default_auth()) {

  # Check required input for completeness
  check_not_null(user_id, "user_id")
  check_mattermost_auth(auth)

  endpoint <- paste0("/api/v4/users/", user_id)

  # Send the request using mattermost_api_request
  response <- mattermost_api_request(
    auth = auth,
    endpoint = endpoint,
    method = "GET",
    verbose = verbose
  )

  return(response)
}



#' Get information about which user is belonging to bearer key,
#'
#' @param verbose (Logical) If `TRUE`, detailed information about the request and response will be printed.
#' @param auth The authentication object created by `authenticate_mattermost()`.
#'
#'
#' @return a list with user information for the authentication key
#' @export
#'
#' @examples
#' \dontrun{
#'  get_me()
#' }
get_me <- function(verbose = FALSE, auth = get_default_auth()){

  # Check required input for completeness
  check_mattermost_auth(auth)


  endpoint <- paste0("/api/v4/users/me")

  # Send the request using mattermost_api_request
  response <- mattermost_api_request(
    auth = auth,
    endpoint = endpoint,
    method = "GET",
    verbose = verbose
  )

  return(response)
}
