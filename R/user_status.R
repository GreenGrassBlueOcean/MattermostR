#' Get user online status
#'
#' Retrieve the current status of a user (online, away, offline, or dnd).
#'
#' @param user_id Character. The user ID to query. The API also accepts
#'   `"me"` to refer to the authenticated user.
#' @param verbose Logical. Print detailed request information? Default `FALSE`.
#' @param auth A `mattermost_auth` object created by
#'   [authenticate_mattermost()]. Defaults to [get_default_auth()].
#'
#' @return A named list with fields `user_id`, `status`, `manual`,
#'   `last_activity_at`, and `active_channel`.
#'
#' @section Permissions:
#' Must be authenticated.
#'
#' @export
#' @examples
#' \dontrun{
#'   status <- get_user_status("user123")
#'   status$status
#'   # "online", "away", "offline", or "dnd"
#'
#'   # Use "me" for the authenticated user
#'   my_status <- get_user_status("me")
#' }
get_user_status <- function(user_id,
                            verbose = FALSE,
                            auth = get_default_auth()) {

  check_not_null(user_id, "user_id")
  check_mattermost_auth(auth)

  endpoint <- paste0("/api/v4/users/", user_id, "/status")

  mattermost_api_request(
    auth     = auth,
    endpoint = endpoint,
    method   = "GET",
    verbose  = verbose
  )
}


#' Set user online status
#'
#' Manually set a user's status. When setting a user's status to anything
#' other than `"online"`, the status remains fixed until explicitly set back
#' to `"online"`, at which point automatic activity-based updates resume.
#'
#' @param user_id Character. The user ID to update.
#' @param status Character. One of `"online"`, `"away"`, `"offline"`, or
#'   `"dnd"`. Case-insensitive.
#' @param dnd_end_time Optional integer. Unix epoch timestamp (seconds) at
#'   which DND status should automatically expire. Only meaningful when
#'   `status = "dnd"`. A warning is issued if provided for other statuses.
#' @param verbose Logical. Print detailed request information? Default `FALSE`.
#' @param auth A `mattermost_auth` object created by
#'   [authenticate_mattermost()]. Defaults to [get_default_auth()].
#'
#' @return A named list with the updated status object (same schema as
#'   [get_user_status()]).
#'
#' @section Permissions:
#' Must have `edit_other_users` permission for the team to set another
#' user's status.
#'
#' @export
#' @examples
#' \dontrun{
#'   set_user_status("user123", "dnd",
#'                   dnd_end_time = as.integer(Sys.time()) + 3600)
#'
#'   set_user_status("user123", "online")
#' }
set_user_status <- function(user_id,
                            status,
                            dnd_end_time = NULL,
                            verbose = FALSE,
                            auth = get_default_auth()) {

  check_not_null(user_id, "user_id")
  check_not_null(status, "status")
  check_mattermost_auth(auth)

  status <- tolower(status)
  valid_statuses <- c("online", "away", "offline", "dnd")
  if (!status %in% valid_statuses) {
    stop("status must be one of: ", paste(valid_statuses, collapse = ", "),
         call. = FALSE)
  }

  if (!is.null(dnd_end_time)) {
    if (!is.numeric(dnd_end_time) || dnd_end_time <= 0) {
      stop("dnd_end_time must be a positive number (Unix epoch seconds).",
           call. = FALSE)
    }
    if (status != "dnd") {
      warning("dnd_end_time is only meaningful when status is 'dnd'. Ignoring.",
              call. = FALSE)
      dnd_end_time <- NULL
    }
  }

  endpoint <- paste0("/api/v4/users/", user_id, "/status")

  body <- list(user_id = user_id, status = status)
  if (!is.null(dnd_end_time)) {
    body$dnd_end_time <- as.integer(dnd_end_time)
  }

  mattermost_api_request(
    auth     = auth,
    endpoint = endpoint,
    method   = "PUT",
    body     = body,
    verbose  = verbose
  )
}
