#' Delete Messages Older Than X Days in a Mattermost Channel
#'
#' This function deletes messages that are older than a specified number of days
#' in a given Mattermost channel. It fetches the messages from the channel,
#' checks their timestamps, and deletes the ones that are older than the specified days.
#'
#' @param channel_id Character string. The ID of the Mattermost channel from which
#'   messages should be deleted.
#' @param days Numeric. The age in days of the messages to be deleted.
#' @param auth The authentication object created by `authenticate_mattermost()`.
#'
#'
#' @return A character vector of message IDs that were deleted.
#' @export
#' @examples
#' \dontrun{
#'   teams <- get_all_teams()
#'   team_channels <- get_team_channels(team_id = teams$id[1])
#'   channel_id <- get_channel_id_lookup(team_channels, name = "off-topic")
#'   posts <- delete_old_messages(channel_id, 0)
#'
#' }
delete_old_messages <- function(channel_id, days, auth = authenticate_mattermost()) {

  # Check required input for completeness
  check_not_null(channel_id, "channel_id")
  check_mattermost_auth(auth)

  # Calculate the cutoff timestamp
  cutoff_time <- as.POSIXct(as.numeric(Sys.time() - (days * 86400)), origin = "1970-01-01", tz = "UTC") # 86400 seconds in a day

  # Get messages from the channel
  messages <- get_channel_posts(channel_id = channel_id)

  # Extract the messages and their timestamps
  messages_to_delete <- subset(messages, as.numeric(create_at) < as.numeric(cutoff_time))

  # Check if there are messages to delete
  if (nrow(messages_to_delete) == 0) {
    message("No messages older than ", days, " days found in channel ", channel_id)
    return(data.frame())
  }

  # Delete each old message
  deleted_message_status <- character(length = length(messages_to_delete$id))
  for ( i in 1:length(messages_to_delete$id)) {
    message <- delete_post(post_id = messages_to_delete$id[i])
    deleted_message_status[i] <- message[[1]]
  }

  # Summarize response
  Response <- data.frame( message_id = messages_to_delete$id
                        , delete_status = deleted_message_status
                        )

  return(Response)
}



