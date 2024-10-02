# File: R/create_channel.R

#' Create a new Mattermost channel
#'
#' @param team_id The ID of the team where the channel will be created.
#' @param name A short name for the channel.
#' @param display_name The display name for the channel.
#' @param type The type of the channel: "O" for open (default) or "P" for private.
#' @param verbose (Logical) If `TRUE`, detailed information about the request and response will be printed.
#' @param auth The authentication object created by `authenticate_mattermost()`.
#'
#' @return A list with details about the created channel.
#' @export
#' @examples
#' \dontrun{
#' teams <- get_all_teams()
#' new_channel <- create_channel(team_id = teams$id[1], name = "newchannel2"
#' , display_name = "a new channel", verbose = TRUE)
#' }
create_channel <- function(team_id = NULL, name = NULL, display_name = NULL, type = "O", verbose = FALSE, auth = authenticate_mattermost()) {

  # Check required input for completeness
  check_not_null(team_id, "team_id")
  check_not_null(name, "name")
  check_not_null(display_name, "display_name")
  check_mattermost_auth(auth)

  # Check if a channel with the same name already exists
  existing_channels <- get_team_channels(team_id = team_id
                                        , auth = auth
                                        , verbose = verbose)  # Use the existing function to get channels

  # Check for uniqueness of the channel name
  if (any(existing_channels$name == name)) {
    stop("A channel with the name '", name, "' already exists.")
  }

  endpoint <- "/api/v4/channels"

  # Validate type input
  if (!type %in% c("O", "P")) {
    stop("Channel type must be either 'O' for open or 'P' for private.")
  }

  # Construct the body for channel creation
  body <- list(
    team_id = team_id,
    name = name,
    display_name = display_name,
    type = toupper(type)  # Ensure type is uppercase
  )

  # Send the request using mattermost_api_request
  response <- mattermost_api_request(
    auth = auth,
    endpoint = endpoint,
    method = "POST",
    body = body,
    verbose = verbose
  )

  return(response)
}

# Compact error checking for required parameters
check_not_null <- function(param, param_name) {
  if (is.null(param) || !nzchar(param)) {
    stop(paste(param_name, "cannot be empty or NULL"))
  }
}


