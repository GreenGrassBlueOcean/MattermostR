#' Add a user to a channel
#'
#' Adds a user to a specified Mattermost channel. This function resolves the
#' IDs into readable names to provide a user-friendly success message.
#'
#' @param channel_id The ID of the channel to add the user to.
#' @param user_id The ID of the user to add. You can use the string "me" to add the authenticated user.
#' @param verbose Boolean. If `TRUE`, prints the request details.
#' @param auth The authentication object created by `authenticate_mattermost()`.
#'
#' @return The raw channel member object (invisibly) for programmatic use.
#' @export
#' @examples
#' \dontrun{
#'   # Authenticate
#'   auth <- authenticate_mattermost()
#'
#'   # Get current user ID
#'   me <- get_user_info("me", auth = auth)
#'
#'   # Get the first team available to the user
#'   teams <- get_all_teams(auth = auth)
#'   team_id <- teams$id[1]
#'
#'   # Get channels for this team
#'   channels <- get_team_channels(team_id = team_id, auth = auth)
#'
#'   # Get the channel ID for "Town Square" by name
#'   channel_id <- get_channel_id_lookup(channels, name = "town-square")
#'
#'   # Add current user to that channel
#'   add_user_to_channel(channel_id, me$id, auth = auth)
#' }
add_user_to_channel <- function(channel_id, user_id, verbose = FALSE, auth = authenticate_mattermost()) {

  # Check required inputs
  check_not_null(channel_id, "channel_id")
  check_not_null(user_id, "user_id")
  check_mattermost_auth(auth)

  endpoint <- paste0("/api/v4/channels/", channel_id, "/members")

  # Request body
  body <- list(
    user_id = user_id
  )

  # 1. Attempt to add the user (API Call 1)
  # We wrap this in tryCatch, although you noted Mattermost often returns 200/201 even if existing.
  response <- tryCatch({
    mattermost_api_request(
      auth = auth,
      endpoint = endpoint,
      method = "POST",
      body = body,
      verbose = verbose
    )
  }, error = function(e) {
    stop(e)
  })

  # 2. Fetch User Info for display (API Call 2)
  # We suppress warnings/errors here to ensure the function doesn't fail just because of a print lookup
  user_name <- tryCatch({
    u_info <- get_user_info(user_id, auth = auth)
    u_info$username
  }, error = function(e) user_id) # Fallback to ID if lookup fails

  # 3. Fetch Channel Info for display (API Call 3)
  channel_name <- tryCatch({
    c_info <- get_channel_info(channel_id, verbose = FALSE, auth = auth)
    c_info$display_name
  }, error = function(e) channel_id) # Fallback to ID if lookup fails

  # 4. Print user-friendly message
  message(sprintf("Success: User '%s' is now a member of channel '%s'.", user_name, channel_name))

  # Return the raw response invisibly so it doesn't clutter the console
  return(invisible(response))
}
