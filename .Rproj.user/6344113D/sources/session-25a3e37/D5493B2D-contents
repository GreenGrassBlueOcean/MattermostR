# File: R/get_channel_posts.R

#' Get posts from a Mattermost channel
#'
#' @param channel_id The Mattermost channel ID.
#' @param verbose Boolean. If `TRUE`, the function will print request/response details for more information.
#' @param auth The authentication object created by `authenticate_mattermost()`.
#'
#' @return Parsed JSON response with posts from the channel.
#' @export
get_channel_posts <- function(channel_id, verbose = FALSE, auth = authenticate_mattermost()) {

  # Check required input for completeness
  check_not_null(channel_id, "channel_id")
  check_mattermost_auth(auth)

  endpoint <- paste0("/api/v4/channels/", channel_id, "/posts")

  # Send the request using mattermost_api_request
  response <- mattermost_api_request(
    auth = auth,
    endpoint = endpoint,
    method = "GET",
    verbose = verbose
  )

  return(response)
}
