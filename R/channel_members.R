#' Get members of a channel
#'
#' Retrieve a page of members for a channel. Each member record includes
#' the user's ID, roles, notification preferences, and activity timestamps.
#'
#' @param channel_id Character. The channel ID to query.
#' @param page Integer. Zero-based page number. Default `0`.
#' @param per_page Integer. Number of members per page. Default `60`
#'   (Mattermost API default). Maximum `200`.
#' @param verbose Logical. Print detailed request information? Default `FALSE`.
#' @param auth A `mattermost_auth` object created by
#'   [authenticate_mattermost()]. Defaults to [get_default_auth()].
#'
#' @return A data frame of channel members with columns such as
#'   `channel_id`, `user_id`, `roles`, `last_viewed_at`, `msg_count`,
#'   `mention_count`, `last_update_at`, `scheme_user`, and `scheme_admin`.
#'
#' @section Permissions:
#' Must have `read_channel` permission for the channel.
#'
#' @seealso [add_user_to_channel()], [remove_channel_member()]
#' @export
#' @examples
#' \dontrun{
#'   members <- get_channel_members("channel_id_abc")
#'   nrow(members)
#'
#'   # Page through results
#'   page2 <- get_channel_members("channel_id_abc", page = 1, per_page = 100)
#' }
get_channel_members <- function(channel_id,
                                page = 0,
                                per_page = 60,
                                verbose = FALSE,
                                auth = get_default_auth()) {

  check_not_null(channel_id, "channel_id")
  check_mattermost_auth(auth)

  if (!is.numeric(page) || page < 0) {
    stop("page must be a non-negative integer.", call. = FALSE)
  }
  if (!is.numeric(per_page) || per_page < 1 || per_page > 200) {
    stop("per_page must be between 1 and 200.", call. = FALSE)
  }

  endpoint <- paste0("/api/v4/channels/", channel_id,
                     "/members?page=", page, "&per_page=", per_page)

  mattermost_api_request(
    auth     = auth,
    endpoint = endpoint,
    method   = "GET",
    verbose  = verbose
  )
}


#' Remove a user from a channel
#'
#' Remove a user from a channel by deleting their channel membership.
#' Only works for public and private channels (not direct or group messages).
#'
#' @param channel_id Character. The channel ID to remove the user from.
#' @param user_id Character. The user ID to remove.
#' @param verbose Logical. Print detailed request information? Default `FALSE`.
#' @param auth A `mattermost_auth` object created by
#'   [authenticate_mattermost()]. Defaults to [get_default_auth()].
#'
#' @return A named list with `status = "OK"` on success.
#'
#' @section Permissions:
#' Requires `manage_public_channel_members` for public channels or
#' `manage_private_channel_members` for private channels.
#'
#' @seealso [get_channel_members()], [add_user_to_channel()]
#' @export
#' @examples
#' \dontrun{
#'   remove_channel_member("channel_id_abc", "user_id_xyz")
#' }
remove_channel_member <- function(channel_id,
                                  user_id,
                                  verbose = FALSE,
                                  auth = get_default_auth()) {

  check_not_null(channel_id, "channel_id")
  check_not_null(user_id, "user_id")
  check_mattermost_auth(auth)

  endpoint <- paste0("/api/v4/channels/", channel_id,
                     "/members/", user_id)

  mattermost_api_request(
    auth     = auth,
    endpoint = endpoint,
    method   = "DELETE",
    verbose  = verbose
  )
}
