# File: R/get_channel_info.R

#' Get information about a Mattermost channel
#'
#' @param channel_id The Mattermost channel ID.
#' @param auth The authentication object created by `authenticate_mattermost()`.
#' @param verbose (Logical) If `TRUE`, detailed information about the request and response will be printed.
#'
#' @return Parsed JSON response with channel information.
#' @export
#' @examples
#'  get_channel_info(channel_id = "newchannel2", verbose = TRUE)
#'
get_channel_info <- function(channel_id, verbose = FALSE, auth = authenticate_mattermost()) {

  # Check required input for completeness
  check_not_null(channel_id, "channel_id")
  check_mattermost_auth(auth)


  endpoint <- paste0("/api/v4/channels/", channel_id)

  # Send the request using mattermost_api_request
  response <- mattermost_api_request(
    auth = auth,
    endpoint = endpoint,
    method = "GET",
    verbose = verbose
  )

  return(response)
}
