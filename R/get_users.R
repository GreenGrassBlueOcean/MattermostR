# File: R/get_users.R

#' Get information about a specific Mattermost user
#'
#' @param auth The authentication object created by `authenticate_mattermost()`.
#' @param verbose (Logical) If `TRUE`, detailed information about the request and response will be printed.
#'
#' @return a vector user_ids
#' @export
#' @examples
#' \dontrun{
#'  get_all_users()
#' }
#'
get_all_users <- function(verbose = FALSE, auth = authenticate_mattermost()){

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
#' @param user_id The ID of the post to delete.
#' @param verbose (Logical) If `TRUE`, detailed information about the request and response will be printed.
#' @param auth The authentication object created by `authenticate_mattermost()`.
#'
#'
#' @return a vector user_ids
#' @export
#' @examples
#' \dontrun{
#'  users <- get_all_users()
#'  userinfo <- lapply(users, get_user)
#' }
#'
get_user <- function(user_id = NULL, verbose = FALSE,auth = authenticate_mattermost()){

  # Check required input for completeness
  check_not_null(user_id, "user_id")
  check_mattermost_auth(auth)

  endpoint <- paste0("/api/v4/users/", user_id)

  # Send the request using mattermost_api_request
  response <- mattermost_api_request(
    auth = auth,
    endpoint = endpoint,
    method = "GET"
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
get_me <- function(verbose = TRUE, auth = authenticate_mattermost()){

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
