# File: R/get_user_info.R

#' Get information about a specific Mattermost user
#'
#' @param auth The authentication object created by `authenticate_mattermost()`.
#' @param user_id The Mattermost user ID.
#'
#' @return Parsed JSON response with user information.
#' @export
#' @examples
#' \dontrun{
#' users <- get_all_users()
#' userinfo <- lapply(users, get_user_info)
#' }
get_user_info <- function(user_id = NULL,auth = authenticate_mattermost()) {

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
