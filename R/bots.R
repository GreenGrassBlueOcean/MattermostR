#' Create a bot account
#'
#' Create a new bot account on the Mattermost server. The bot will be owned
#' by the authenticated user.
#'
#' @param username Character. Required. The username for the bot. Must be
#'   unique across all users and bots on the server.
#' @param display_name Character. Optional display name for the bot.
#' @param description Character. Optional description of the bot.
#' @param verbose Logical. Print detailed request information? Default `FALSE`.
#' @param auth A `mattermost_auth` object created by
#'   [authenticate_mattermost()]. Defaults to [get_default_auth()].
#'
#' @return A named list representing the created bot, with fields `user_id`,
#'   `username`, `display_name`, `description`, `owner_id`, `create_at`,
#'   `update_at`, and `delete_at`.
#'
#' @section Permissions:
#' Must have `create_bot` permission.
#'
#' @seealso [get_bot()], [get_bots()], [update_bot()], [disable_bot()],
#'   [enable_bot()], [assign_bot()]
#' @export
#' @examples
#' \dontrun{
#'   bot <- create_bot("my-bot", display_name = "My Bot",
#'                     description = "Automated notifications")
#'   bot$user_id
#' }
create_bot <- function(username,
                       display_name = NULL,
                       description = NULL,
                       verbose = FALSE,
                       auth = get_default_auth()) {

  check_not_null(username, "username")
  check_mattermost_auth(auth)

  body <- list(username = username)
  if (!is.null(display_name)) body$display_name <- display_name
  if (!is.null(description))  body$description  <- description

  mattermost_api_request(
    auth     = auth,
    endpoint = "/api/v4/bots",
    method   = "POST",
    body     = body,
    verbose  = verbose
  )
}


#' Get a bot account
#'
#' Retrieve a bot by its bot user ID.
#'
#' @param bot_user_id Character. The bot's user ID.
#' @param include_deleted Logical. If `TRUE`, return the bot even if it has
#'   been disabled (deleted). Default `FALSE`.
#' @param verbose Logical. Print detailed request information? Default `FALSE`.
#' @param auth A `mattermost_auth` object created by
#'   [authenticate_mattermost()]. Defaults to [get_default_auth()].
#'
#' @return A named list representing the bot (same schema as [create_bot()]).
#'
#' @section Permissions:
#' Must have `read_bots` permission for bots you own, or
#' `read_others_bots` for bots owned by other users.
#'
#' @seealso [get_bots()], [create_bot()]
#' @export
#' @examples
#' \dontrun{
#'   bot <- get_bot("bot_user_id_abc")
#'   bot$username
#'
#'   # Include disabled bots
#'   bot <- get_bot("bot_user_id_abc", include_deleted = TRUE)
#' }
get_bot <- function(bot_user_id,
                    include_deleted = FALSE,
                    verbose = FALSE,
                    auth = get_default_auth()) {

  check_not_null(bot_user_id, "bot_user_id")
  check_mattermost_auth(auth)

  endpoint <- paste0("/api/v4/bots/", bot_user_id)
  if (isTRUE(include_deleted)) {
    endpoint <- paste0(endpoint, "?include_deleted=true")
  }

  mattermost_api_request(
    auth     = auth,
    endpoint = endpoint,
    method   = "GET",
    verbose  = verbose
  )
}


#' List bot accounts
#'
#' Retrieve a paginated list of bots on the server.
#'
#' @param page Integer. Zero-based page number. Default `0`.
#' @param per_page Integer. Number of bots per page. Default `60`.
#'   Maximum `200`.
#' @param include_deleted Logical. If `TRUE`, include disabled (deleted) bots
#'   in the results. Default `FALSE`.
#' @param only_orphaned Logical. If `TRUE`, return only orphaned bots (bots
#'   whose owner has been deactivated). Default `FALSE`.
#' @param verbose Logical. Print detailed request information? Default `FALSE`.
#' @param auth A `mattermost_auth` object created by
#'   [authenticate_mattermost()]. Defaults to [get_default_auth()].
#'
#' @return A data frame of bots with columns such as `user_id`, `username`,
#'   `display_name`, `description`, `owner_id`, `create_at`, `update_at`,
#'   and `delete_at`.
#'
#' @section Permissions:
#' Must have `read_bots` permission for bots you own, or
#' `read_others_bots` for bots owned by other users.
#'
#' @seealso [get_bot()], [create_bot()]
#' @export
#' @examples
#' \dontrun{
#'   bots <- get_bots()
#'   nrow(bots)
#'
#'   # Only orphaned bots
#'   orphaned <- get_bots(only_orphaned = TRUE)
#'
#'   # Page through results
#'   page2 <- get_bots(page = 1, per_page = 100)
#' }
get_bots <- function(page = 0,
                     per_page = 60,
                     include_deleted = FALSE,
                     only_orphaned = FALSE,
                     verbose = FALSE,
                     auth = get_default_auth()) {

  check_mattermost_auth(auth)

  if (!is.numeric(page) || page < 0) {
    stop("page must be a non-negative integer.", call. = FALSE)
  }
  if (!is.numeric(per_page) || per_page < 1 || per_page > 200) {
    stop("per_page must be between 1 and 200.", call. = FALSE)
  }

  params <- paste0("page=", page, "&per_page=", per_page)
  if (isTRUE(include_deleted)) params <- paste0(params, "&include_deleted=true")
  if (isTRUE(only_orphaned))   params <- paste0(params, "&only_orphaned=true")

  endpoint <- paste0("/api/v4/bots?", params)

  mattermost_api_request(
    auth     = auth,
    endpoint = endpoint,
    method   = "GET",
    verbose  = verbose
  )
}


#' Update a bot account
#'
#' Partially update a bot's username, display name, or description.
#' Only the provided fields are updated; omitted fields remain unchanged.
#'
#' @param bot_user_id Character. The bot's user ID.
#' @param username Character. Required. The new username for the bot.
#' @param display_name Character. Optional new display name.
#' @param description Character. Optional new description.
#' @param verbose Logical. Print detailed request information? Default `FALSE`.
#' @param auth A `mattermost_auth` object created by
#'   [authenticate_mattermost()]. Defaults to [get_default_auth()].
#'
#' @return A named list representing the updated bot (same schema as
#'   [create_bot()]).
#'
#' @section Permissions:
#' Must have `manage_bots` permission for bots you own, or
#' `manage_others_bots` for bots owned by other users.
#'
#' @seealso [create_bot()], [get_bot()]
#' @export
#' @examples
#' \dontrun{
#'   updated <- update_bot("bot_user_id_abc", username = "new-bot-name",
#'                         display_name = "New Display Name")
#' }
update_bot <- function(bot_user_id,
                       username,
                       display_name = NULL,
                       description = NULL,
                       verbose = FALSE,
                       auth = get_default_auth()) {

  check_not_null(bot_user_id, "bot_user_id")
  check_not_null(username, "username")
  check_mattermost_auth(auth)

  body <- list(username = username)
  if (!is.null(display_name)) body$display_name <- display_name
  if (!is.null(description))  body$description  <- description

  endpoint <- paste0("/api/v4/bots/", bot_user_id)

  mattermost_api_request(
    auth     = auth,
    endpoint = endpoint,
    method   = "PUT",
    body     = body,
    verbose  = verbose
  )
}


#' Disable a bot account
#'
#' Disable (soft-delete) a bot. The bot will no longer be able to post or
#' respond, but can be re-enabled with [enable_bot()].
#'
#' @param bot_user_id Character. The bot's user ID.
#' @param verbose Logical. Print detailed request information? Default `FALSE`.
#' @param auth A `mattermost_auth` object created by
#'   [authenticate_mattermost()]. Defaults to [get_default_auth()].
#'
#' @return A named list representing the disabled bot (same schema as
#'   [create_bot()]).
#'
#' @section Permissions:
#' Must have `manage_bots` permission for bots you own, or
#' `manage_others_bots` for bots owned by other users.
#'
#' @seealso [enable_bot()], [get_bot()]
#' @export
#' @examples
#' \dontrun{
#'   disable_bot("bot_user_id_abc")
#' }
disable_bot <- function(bot_user_id,
                        verbose = FALSE,
                        auth = get_default_auth()) {

  check_not_null(bot_user_id, "bot_user_id")
  check_mattermost_auth(auth)

  endpoint <- paste0("/api/v4/bots/", bot_user_id, "/disable")

  mattermost_api_request(
    auth     = auth,
    endpoint = endpoint,
    method   = "POST",
    verbose  = verbose
  )
}


#' Enable a bot account
#'
#' Re-enable a previously disabled bot so it can post and respond again.
#'
#' @param bot_user_id Character. The bot's user ID.
#' @param verbose Logical. Print detailed request information? Default `FALSE`.
#' @param auth A `mattermost_auth` object created by
#'   [authenticate_mattermost()]. Defaults to [get_default_auth()].
#'
#' @return A named list representing the enabled bot (same schema as
#'   [create_bot()]).
#'
#' @section Permissions:
#' Must have `manage_bots` permission for bots you own, or
#' `manage_others_bots` for bots owned by other users.
#'
#' @seealso [disable_bot()], [get_bot()]
#' @export
#' @examples
#' \dontrun{
#'   enable_bot("bot_user_id_abc")
#' }
enable_bot <- function(bot_user_id,
                       verbose = FALSE,
                       auth = get_default_auth()) {

  check_not_null(bot_user_id, "bot_user_id")
  check_mattermost_auth(auth)

  endpoint <- paste0("/api/v4/bots/", bot_user_id, "/enable")

  mattermost_api_request(
    auth     = auth,
    endpoint = endpoint,
    method   = "POST",
    verbose  = verbose
  )
}


#' Assign a bot to a different owner
#'
#' Transfer ownership of a bot to another user. The new owner will be able
#' to manage the bot's settings and access tokens.
#'
#' @param bot_user_id Character. The bot's user ID.
#' @param user_id Character. The user ID of the new owner.
#' @param verbose Logical. Print detailed request information? Default `FALSE`.
#' @param auth A `mattermost_auth` object created by
#'   [authenticate_mattermost()]. Defaults to [get_default_auth()].
#'
#' @return A named list representing the bot with updated ownership (same
#'   schema as [create_bot()]).
#'
#' @section Permissions:
#' Must have `manage_bots` permission for bots you own, or
#' `manage_others_bots` for bots owned by other users.
#'
#' @seealso [create_bot()], [get_bot()]
#' @export
#' @examples
#' \dontrun{
#'   assign_bot("bot_user_id_abc", "new_owner_user_id")
#' }
assign_bot <- function(bot_user_id,
                       user_id,
                       verbose = FALSE,
                       auth = get_default_auth()) {

  check_not_null(bot_user_id, "bot_user_id")
  check_not_null(user_id, "user_id")
  check_mattermost_auth(auth)

  endpoint <- paste0("/api/v4/bots/", bot_user_id, "/assign/", user_id)

  mattermost_api_request(
    auth     = auth,
    endpoint = endpoint,
    method   = "POST",
    verbose  = verbose
  )
}
