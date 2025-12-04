#' Get information about a specific Mattermost user
#'
#' Retrieve detailed information about a user, such as their username, email,
#' roles, and ID.
#'
#' @param user_id A character string containing the Mattermost user ID.
#'                You can also use the special string **"me"** to retrieve information
#'                about the currently authenticated user (the bot/user associated with the token).
#' @param auth The authentication object created by `authenticate_mattermost()`.
#'
#' @return Parsed JSON response with user information (list).
#' @export
#' @examples
#' \dontrun{
#'   # Get info about a specific user by ID
#'   user <- get_user_info("xb123abc456...")
#'
#'   # Get info about the current authenticated bot/user
#'   myself <- get_user_info("me")
#'   print(myself$id)
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
