#' Delete Messages Older Than X Days in a Mattermost Channel
#'
#' This function deletes messages that are older than a specified number of days
#' in a given Mattermost channel. It auto-paginates through all posts in the
#' channel, filters by creation timestamp, and deletes the ones older than the
#' specified number of days.
#'
#' @param channel_id Character string. The ID of the Mattermost channel from which
#'   messages should be deleted.
#' @param days Numeric. The age in days of the messages to be deleted.
#' @param auth The authentication object created by `authenticate_mattermost()`.
#'
#'
#' @return A data frame with columns `message_id` and `delete_status`, or an
#'   empty data frame if no messages were deleted.
#' @export
#' @examples
#' \dontrun{
#'   teams <- get_all_teams()
#'   team_channels <- get_team_channels(team_id = teams$id[1])
#'   channel_id <- get_channel_id_lookup(team_channels, name = "off-topic")
#'   posts <- delete_old_messages(channel_id, 0)
#'
#' }
delete_old_messages <- function(channel_id, days, auth = get_default_auth()) {

  # Check required input for completeness
  check_not_null(channel_id, "channel_id")
  check_mattermost_auth(auth)

  # Calculate the cutoff timestamp
  cutoff_time <- as.POSIXct(as.numeric(Sys.time() - (days * 86400)), origin = "1970-01-01", tz = "UTC") # 86400 seconds in a day

  # Fetch all posts by auto-paginating (200 per page, the API maximum)
  messages <- get_all_channel_posts(channel_id = channel_id, auth = auth)

  # Filter to messages older than the cutoff
  messages_to_delete <- messages[as.numeric(messages$create_at) < as.numeric(cutoff_time), , drop = FALSE]

  # Check if there are messages to delete
  if (nrow(messages_to_delete) == 0) {
    message("No messages older than ", days, " days found in channel ", channel_id)
    return(data.frame())
  }

  # Delete each old message
  deleted_message_status <- character(length = length(messages_to_delete$id))
  for ( i in 1:length(messages_to_delete$id)) {
    msg <- delete_post(post_id = messages_to_delete$id[i])
    deleted_message_status[i] <- msg[[1]]
  }

  # Summarize response
  result <- data.frame(message_id = messages_to_delete$id,
                       delete_status = deleted_message_status)

  return(result)
}

#' Fetch all posts from a channel by auto-paginating
#'
#' Delegates to \code{\link{paginate_api}} with
#' \code{convert_mattermost_posts_to_dataframe} as the per-page transform.
#'
#' @param channel_id The Mattermost channel ID.
#' @param auth The authentication object.
#' @return A data frame of all posts in the channel, or an empty data frame.
#' @noRd
get_all_channel_posts <- function(channel_id, auth) {
  endpoint <- paste0("/api/v4/channels/", channel_id, "/posts")
  paginate_api(auth, endpoint, per_page = 200,
               transform = convert_mattermost_posts_to_dataframe)
}
