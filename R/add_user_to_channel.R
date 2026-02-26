#' Add a user to a channel
#'
#' Adds a user to a specified Mattermost channel.
#'
#' By default, the function resolves the user and channel IDs into readable
#' names for a user-friendly success message (2 extra API calls). Set
#' `resolve_names = FALSE` to skip these lookups and reduce API traffic to a
#' single call — useful when adding users in a loop. For true batch operations,
#' see [add_users_to_channel()].
#'
#' @param channel_id The ID of the channel to add the user to.
#' @param user_id The ID of the user to add. You can use the string `"me"` to
#'   add the authenticated user.
#' @param resolve_names Logical. If `TRUE` (default), fetches readable
#'   usernames and channel names for the success message. Set to `FALSE` to
#'   skip these lookups and save 2 API calls.
#' @param verbose Boolean. If `TRUE`, prints the request details.
#' @param auth The authentication object created by [authenticate_mattermost()].
#'
#' @return The channel member object returned by the API (invisibly).
#' @export
#' @seealso [add_users_to_channel()] for batch operations.
#' @examples
#' \dontrun{
#'   # Add current user to a channel (with friendly names)
#'   me <- get_user("me", auth = auth)
#'   add_user_to_channel(channel_id, me$id, auth = auth)
#'
#'   # Fast path: skip name resolution
#'   add_user_to_channel(channel_id, me$id, resolve_names = FALSE, auth = auth)
#' }
add_user_to_channel <- function(channel_id, user_id,
                                resolve_names = TRUE,
                                verbose = FALSE,
                                auth = get_default_auth()) {

  # Check required inputs
  check_not_null(channel_id, "channel_id")
  check_not_null(user_id, "user_id")
  check_mattermost_auth(auth)

  endpoint <- paste0("/api/v4/channels/", channel_id, "/members")

  body <- list(user_id = user_id)

  # 1. Add the user (API call 1 — always required)
  response <- mattermost_api_request(
    auth     = auth,
    endpoint = endpoint,
    method   = "POST",
    body     = body,
    verbose  = verbose
  )

  # 2. Optionally resolve human-readable names (API calls 2 & 3)
  if (resolve_names) {
    user_name <- tryCatch({
      u_info <- get_user(user_id, auth = auth)
      u_info$username
    }, error = function(e) user_id)

    channel_name <- tryCatch({
      c_info <- get_channel_info(channel_id, verbose = FALSE, auth = auth)
      c_info$display_name
    }, error = function(e) channel_id)
  } else {
    user_name    <- user_id
    channel_name <- channel_id
  }

  message(sprintf("Success: User '%s' is now a member of channel '%s'.",
                  user_name, channel_name))

  return(invisible(response))
}


#' Add multiple users to a channel in a single API call
#'
#' Uses the Mattermost batch endpoint to add up to 1000 users to a channel
#' with a single HTTP request. This is far more efficient than calling
#' [add_user_to_channel()] in a loop.
#'
#' @param channel_id The ID of the channel to add users to.
#' @param user_ids A character vector of user IDs (max 1000).
#' @param resolve_names Logical. If `TRUE`, fetches readable usernames and
#'   the channel name for the success message (2 extra API calls, regardless
#'   of how many users). Defaults to `FALSE` for efficiency.
#' @param verbose Boolean. If `TRUE`, prints the request details.
#' @param auth The authentication object created by [authenticate_mattermost()].
#'
#' @return The API response (invisibly). Typically a list with a `channel_id`
#'   and member details.
#' @export
#' @seealso [add_user_to_channel()] for adding a single user.
#' @examples
#' \dontrun{
#'   # Add 50 users to a channel in one shot
#'   add_users_to_channel(channel_id, user_ids = ids_vector, auth = auth)
#'
#'   # With friendly names in the message
#'   add_users_to_channel(channel_id, user_ids = ids_vector,
#'                        resolve_names = TRUE, auth = auth)
#' }
add_users_to_channel <- function(channel_id, user_ids,
                                 resolve_names = FALSE,
                                 verbose = FALSE,
                                 auth = get_default_auth()) {

  # Validate inputs
  check_not_null(channel_id, "channel_id")
  check_mattermost_auth(auth)

  if (!is.character(user_ids) || length(user_ids) == 0L) {
    stop("user_ids must be a non-empty character vector.")
  }
  if (length(user_ids) > 1000L) {
    stop("The Mattermost API allows a maximum of 1000 users per request. ",
         "Received ", length(user_ids), ".")
  }

  endpoint <- paste0("/api/v4/channels/", channel_id, "/members")

  body <- list(user_ids = user_ids)

  # 1. Batch add (single API call)
  response <- mattermost_api_request(
    auth     = auth,
    endpoint = endpoint,
    method   = "POST",
    body     = body,
    verbose  = verbose
  )

  # 2. Optionally resolve human-readable names
  n <- length(user_ids)
  if (resolve_names) {
    channel_name <- tryCatch({
      c_info <- get_channel_info(channel_id, verbose = FALSE, auth = auth)
      c_info$display_name
    }, error = function(e) channel_id)

    # Batch user lookup: POST /api/v4/users/ids
    user_names <- tryCatch({
      users <- mattermost_api_request(
        auth     = auth,
        endpoint = "/api/v4/users/ids",
        method   = "POST",
        body     = user_ids,
        verbose  = FALSE
      )
      if (is.data.frame(users) && "username" %in% names(users)) {
        users$username
      } else {
        user_ids
      }
    }, error = function(e) user_ids)

    preview <- paste(utils::head(user_names, 5), collapse = ", ")
    if (n > 5) preview <- paste0(preview, ", ...")
    message(sprintf("Success: %d user(s) added to channel '%s': %s",
                    n, channel_name, preview))
  } else {
    message(sprintf("Success: %d user(s) added to channel '%s'.",
                    n, channel_id))
  }

  return(invisible(response))
}
