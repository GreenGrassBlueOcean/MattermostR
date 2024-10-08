# File: R/delete_channel.R

#' Delete a Mattermost channel
#'
#' Archives a Mattermost channel.
#'
#' @details
#' Note on Channel Deletion
#'
#' When a channel is deleted online via the Mattermost API, it is not permanently removed but rather
#' archived. The archived channel can be restored manually through the Mattermost channel management
#' interface in the GUI. While the Mattermost REST API specification does include an option for
#' permanent deletion of channels, this functionality is currently not implemented in this package.
#'
#' @param channel_id The ID of the channel that will be deleted.
#' @param team_id The ID of the team to which the channel belongs.
#' @param verbose (Logical) If `TRUE`, detailed information about the request and response will be printed.
#' @param auth The authentication object created by `authenticate_mattermost()`.
#'
#' @return A list with details about the deletion status.
#' @export
#' @examples
#' \dontrun{
#' # First create a channel
#' teams <- get_all_teams()
#' new_channel <- create_channel(team_id = teams$id, name = "newchannel"
#' , display_name = "a new channel")
#'
#' # Now delete the channel
#' info <- delete_channel(channel_id = new_channel$id, team_id = teams$id)
#' }
delete_channel <- function(channel_id, team_id, verbose = FALSE, auth = authenticate_mattermost()) {
  # Check if channel_id is NULL or empty
  if (is.null(channel_id) || !nzchar(channel_id)) {
    stop("channel_id cannot be empty or NULL")
  }

  # Check if team_id is NULL or empty
  if (is.null(team_id) || !nzchar(team_id)) {
    stop("team_id cannot be empty or NULL")
  }

  # Check if the channel exists using get_team_channels
  existing_channels <- get_team_channels( team_id = team_id
                                        , auth =  auth
                                        , verbose = verbose)
  if (!any(existing_channels$id == channel_id)) {
    stop("Channel with ID '", channel_id, "' does not exist.")
  }

  endpoint <- paste0("/api/v4/channels/", channel_id)  # Complete endpoint to delete a specific channel

  # Send the DELETE request using mattermost_api_request
  response <- mattermost_api_request(
    auth = auth,
    endpoint = endpoint,
    method = "DELETE",
    verbose = verbose
  )

  # Check the response for errors (assuming API returns a list with a success key)
  if (!(response$status == "OK")) {
    stop(paste("deleting channel with channel_id:", channel_id, "failed"))
  }

  return(response)
}

