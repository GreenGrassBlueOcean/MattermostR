#' Create a slash command
#'
#' Register a custom slash command for a team. When a user types the trigger
#' word in Mattermost, the server sends a request to the specified URL.
#'
#' @param team_id Character. The team ID where the command will be created.
#' @param trigger Character. The trigger word (without leading `/`). When a
#'   user types `/<trigger>`, the command fires.
#' @param url Character. The callback URL that receives the command payload.
#' @param method Character. HTTP method for the callback: `"P"` for POST,
#'   `"G"` for GET. Default `"P"`.
#' @param auto_complete Logical. Enable autocomplete for this command?
#'   Default `FALSE`.
#' @param auto_complete_desc Character. Optional description shown in
#'   autocomplete.
#' @param auto_complete_hint Character. Optional hint shown in autocomplete.
#' @param display_name Character. Optional display name for the command.
#' @param description Character. Optional description of the command.
#' @param username Character. Optional username override for the response post.
#' @param icon_url Character. Optional icon URL override for the response post.
#' @param verbose Logical. Print detailed request information? Default `FALSE`.
#' @param auth A `mattermost_auth` object created by
#'   [authenticate_mattermost()]. Defaults to [get_default_auth()].
#'
#' @return A named list representing the created command, with fields such as
#'   `id`, `token`, `team_id`, `trigger`, `method`, `url`, `creator_id`,
#'   `create_at`, `update_at`, `delete_at`, `display_name`, `description`,
#'   `username`, `icon_url`, `auto_complete`, `auto_complete_desc`, and
#'   `auto_complete_hint`.
#'
#' @section Permissions:
#' Must have `manage_slash_commands` permission for the team.
#'
#' @seealso [get_command()], [list_commands()], [update_command()],
#'   [delete_command()], [execute_command()]
#' @export
#' @examples
#' \dontrun{
#'   cmd <- create_command(
#'     team_id = "team123",
#'     trigger = "pnl",
#'     url     = "https://my-r-server.example.com/pnl",
#'     method  = "P",
#'     auto_complete      = TRUE,
#'     auto_complete_desc = "Show P&L for a ticker",
#'     auto_complete_hint = "[TICKER]"
#'   )
#'   cmd$id
#'   cmd$token
#' }
create_command <- function(team_id,
                           trigger,
                           url,
                           method = c("P", "G"),
                           auto_complete = FALSE,
                           auto_complete_desc = NULL,
                           auto_complete_hint = NULL,
                           display_name = NULL,
                           description = NULL,
                           username = NULL,
                           icon_url = NULL,
                           verbose = FALSE,
                           auth = get_default_auth()) {

  check_not_null(team_id, "team_id")
  check_not_null(trigger, "trigger")
  check_not_null(url, "url")
  check_mattermost_auth(auth)

  method <- match.arg(method)

  body <- list(
    team_id = team_id,
    trigger = trigger,
    url     = url,
    method  = method
  )

  if (isTRUE(auto_complete))           body$auto_complete      <- TRUE
  if (!is.null(auto_complete_desc))    body$auto_complete_desc <- auto_complete_desc
  if (!is.null(auto_complete_hint))    body$auto_complete_hint <- auto_complete_hint
  if (!is.null(display_name))          body$display_name       <- display_name
  if (!is.null(description))           body$description        <- description
  if (!is.null(username))              body$username            <- username
  if (!is.null(icon_url))              body$icon_url            <- icon_url

  mattermost_api_request(
    auth     = auth,
    endpoint = "/api/v4/commands",
    method   = "POST",
    body     = body,
    verbose  = verbose
  )
}


#' Get a slash command
#'
#' Retrieve a command definition by its ID.
#'
#' @param command_id Character. The command ID.
#' @param verbose Logical. Print detailed request information? Default `FALSE`.
#' @param auth A `mattermost_auth` object created by
#'   [authenticate_mattermost()]. Defaults to [get_default_auth()].
#'
#' @return A named list representing the command (same schema as
#'   [create_command()]).
#'
#' @section Permissions:
#' Must have `manage_slash_commands` permission for the team the command
#' belongs to.
#'
#' @seealso [list_commands()], [create_command()]
#' @export
#' @examples
#' \dontrun{
#'   cmd <- get_command("cmd_id_abc")
#'   cmd$trigger
#' }
get_command <- function(command_id,
                        verbose = FALSE,
                        auth = get_default_auth()) {

  check_not_null(command_id, "command_id")
  check_mattermost_auth(auth)

  endpoint <- paste0("/api/v4/commands/", command_id)

  mattermost_api_request(
    auth     = auth,
    endpoint = endpoint,
    method   = "GET",
    verbose  = verbose
  )
}


#' List slash commands for a team
#'
#' Retrieve all commands for a team. By default, returns both system commands
#' and custom commands the user has access to.
#'
#' @param team_id Character. The team ID to query.
#' @param custom_only Logical. If `TRUE`, return only custom commands.
#'   Default `FALSE`.
#' @param verbose Logical. Print detailed request information? Default `FALSE`.
#' @param auth A `mattermost_auth` object created by
#'   [authenticate_mattermost()]. Defaults to [get_default_auth()].
#'
#' @return A data frame of commands with columns such as `id`, `token`,
#'   `team_id`, `trigger`, `method`, `url`, `display_name`, `description`,
#'   `creator_id`, etc.
#'
#' @section Permissions:
#' Must have `manage_slash_commands` permission to list custom commands.
#'
#' @seealso [get_command()], [create_command()]
#' @export
#' @examples
#' \dontrun{
#'   cmds <- list_commands("team123")
#'   nrow(cmds)
#'
#'   # Only custom commands
#'   custom <- list_commands("team123", custom_only = TRUE)
#' }
list_commands <- function(team_id,
                          custom_only = FALSE,
                          verbose = FALSE,
                          auth = get_default_auth()) {

  check_not_null(team_id, "team_id")
  check_mattermost_auth(auth)

  params <- paste0("team_id=", team_id)
  if (isTRUE(custom_only)) params <- paste0(params, "&custom_only=true")

  endpoint <- paste0("/api/v4/commands?", params)

  mattermost_api_request(
    auth     = auth,
    endpoint = endpoint,
    method   = "GET",
    verbose  = verbose
  )
}


#' Update a slash command
#'
#' Update a command definition. The request body should be a complete
#' Command object (the API replaces the entire definition).
#'
#' @param command_id Character. The command ID to update.
#' @param body Named list. The full Command object with updated fields.
#'   Must include required fields like `id`, `team_id`, `trigger`, `url`,
#'   and `method`.
#' @param verbose Logical. Print detailed request information? Default `FALSE`.
#' @param auth A `mattermost_auth` object created by
#'   [authenticate_mattermost()]. Defaults to [get_default_auth()].
#'
#' @return A named list representing the updated command (same schema as
#'   [create_command()]).
#'
#' @section Permissions:
#' Must have `manage_slash_commands` permission for the team the command
#' belongs to.
#'
#' @seealso [get_command()], [create_command()], [delete_command()]
#' @export
#' @examples
#' \dontrun{
#'   cmd <- get_command("cmd_id_abc")
#'   cmd$description <- "Updated description"
#'   update_command("cmd_id_abc", body = cmd)
#' }
update_command <- function(command_id,
                           body,
                           verbose = FALSE,
                           auth = get_default_auth()) {

  check_not_null(command_id, "command_id")
  check_not_null(body, "body")
  check_mattermost_auth(auth)

  if (!is.list(body)) {
    stop("body must be a named list.", call. = FALSE)
  }

  endpoint <- paste0("/api/v4/commands/", command_id)

  mattermost_api_request(
    auth     = auth,
    endpoint = endpoint,
    method   = "PUT",
    body     = body,
    verbose  = verbose
  )
}


#' Delete a slash command
#'
#' Delete a custom slash command by its ID.
#'
#' @param command_id Character. The command ID to delete.
#' @param verbose Logical. Print detailed request information? Default `FALSE`.
#' @param auth A `mattermost_auth` object created by
#'   [authenticate_mattermost()]. Defaults to [get_default_auth()].
#'
#' @return A named list with `status = "OK"` on success.
#'
#' @section Permissions:
#' Must have `manage_slash_commands` permission for the team the command
#' belongs to.
#'
#' @seealso [create_command()], [get_command()]
#' @export
#' @examples
#' \dontrun{
#'   delete_command("cmd_id_abc")
#' }
delete_command <- function(command_id,
                           verbose = FALSE,
                           auth = get_default_auth()) {

  check_not_null(command_id, "command_id")
  check_mattermost_auth(auth)

  endpoint <- paste0("/api/v4/commands/", command_id)

  mattermost_api_request(
    auth     = auth,
    endpoint = endpoint,
    method   = "DELETE",
    verbose  = verbose
  )
}


#' Execute a slash command
#'
#' Programmatically execute a slash command in a channel, as if a user had
#' typed it. The command string should include the leading `/`.
#'
#' @param channel_id Character. The channel ID where the command will execute.
#' @param command Character. The full slash command string including the
#'   leading `/` and any arguments (e.g., `"/pnl AAPL"`).
#' @param verbose Logical. Print detailed request information? Default `FALSE`.
#' @param auth A `mattermost_auth` object created by
#'   [authenticate_mattermost()]. Defaults to [get_default_auth()].
#'
#' @return A named list representing the command response, with fields
#'   `ResponseType` (`"in_channel"` or `"ephemeral"`), `Text`, `Username`,
#'   `IconURL`, `GotoLocation`, and `Attachments`.
#'
#' @section Permissions:
#' Must have `use_slash_commands` permission for the team.
#'
#' @seealso [create_command()], [list_commands()]
#' @export
#' @examples
#' \dontrun{
#'   resp <- execute_command("channel123", "/pnl AAPL")
#'   resp$Text
#' }
execute_command <- function(channel_id,
                            command,
                            verbose = FALSE,
                            auth = get_default_auth()) {

  check_not_null(channel_id, "channel_id")
  check_not_null(command, "command")
  check_mattermost_auth(auth)

  body <- list(
    channel_id = channel_id,
    command    = command
  )

  mattermost_api_request(
    auth     = auth,
    endpoint = "/api/v4/commands/execute",
    method   = "POST",
    body     = body,
    verbose  = verbose
  )
}


#' Regenerate a command token
#'
#' Generate a new verification token for a slash command. The old token is
#' immediately invalidated.
#'
#' @param command_id Character. The command ID to regenerate the token for.
#' @param verbose Logical. Print detailed request information? Default `FALSE`.
#' @param auth A `mattermost_auth` object created by
#'   [authenticate_mattermost()]. Defaults to [get_default_auth()].
#'
#' @return A named list with a single field `token` containing the new token.
#'
#' @section Permissions:
#' Must have `manage_slash_commands` permission for the team the command
#' belongs to.
#'
#' @seealso [create_command()], [get_command()]
#' @export
#' @examples
#' \dontrun{
#'   new_token <- regen_command_token("cmd_id_abc")
#'   new_token$token
#' }
regen_command_token <- function(command_id,
                                verbose = FALSE,
                                auth = get_default_auth()) {

  check_not_null(command_id, "command_id")
  check_mattermost_auth(auth)

  endpoint <- paste0("/api/v4/commands/", command_id, "/regen_token")

  mattermost_api_request(
    auth     = auth,
    endpoint = endpoint,
    method   = "PUT",
    verbose  = verbose
  )
}
