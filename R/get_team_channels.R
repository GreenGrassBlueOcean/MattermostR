# File: R/get_team_channels.R

#' Get the list of channels for a team
#'
#' @param auth A list containing `base_url` and `headers` for authentication.
#' @param team_id The ID of the team for which to retrieve channels.
#' @param verbose (Logical) If `TRUE`, detailed information about the request and response will be printed.
#'
#' @return A data frame of channels with their IDs and names.
#' @export
#'
#' @seealso [get_channel_id_by_display_name()]
#'
#' @examples
#' \dontrun{
#' authenticate_mattermost()
#' teams <- get_all_teams()
#' team_channels <- get_team_channels(team_id = teams$id[1])
#' }
get_team_channels <- function(team_id = NULL, verbose = FALSE, auth= authenticate_mattermost()) {

  # Check required input for completeness
  check_not_null(team_id, "team_id")
  check_mattermost_auth(auth)


  endpoint <- paste0("/api/v4/teams/", team_id, "/channels")

  # Send the request to get channels
  channels_data <- mattermost_api_request( auth = auth
                                          , endpoint =  endpoint
                                          , method = "GET"
                                          , verbose = verbose
                                          )

  return(channels_data)
}
