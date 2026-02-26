
#' Get information about a Mattermost channel
#'
#' @param channel_id A character string containing the Mattermost channel ID.
#' @param verbose (Logical) If `TRUE`, detailed information about the request
#'   and response will be printed. Default is `FALSE`.
#' @param auth The authentication object created by [authenticate_mattermost()].
#'
#' @return A named list with channel fields returned by the Mattermost API
#'   (e.g. `id`, `display_name`, `name`, `type`, `team_id`).
#' @export
#' @examples
#' \dontrun{
#'  get_channel_info(channel_id = "newchannel2", verbose = TRUE)
#'}
get_channel_info <- function(channel_id, verbose = FALSE, auth = get_default_auth()) {

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
