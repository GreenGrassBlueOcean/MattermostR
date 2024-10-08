# File: R/get_all_teams.R

#' List all teams in Mattermost
#'
#' @param auth A list containing `base_url` and `headers` for authentication.
#' @param verbose (Logical) If `TRUE`, detailed information about the request and response will be printed.
#'
#' @return A data frame containing details of all teams.
#' @export
#' @examples
#' \dontrun{
#' teams <- get_all_teams()
#' }
get_all_teams <- function(verbose = FALSE, auth = authenticate_mattermost()){

  # Check required input for completeness
  check_mattermost_auth(auth)

  # Define the endpoint for listing all teams
  endpoint <- "/api/v4/teams"

  # Send the request to get all teams
  teams_data <- mattermost_api_request(auth = auth, endpoint = endpoint, method = "GET", verbose = verbose)

  if(length(teams_data) == 0L){
    warning("The user for which the current bearer authentication key is taken is not part of any teams, change bearer key?
            , use get_me() to obtain more information about the current key user")
  }


  return(teams_data)
}


#' Get data of a single team from its team_id
#'
#' @param auth A list containing `base_url` and `headers` for authentication.
#' @param verbose (Logical) If `TRUE`, detailed information about the request and response will be printed.
#' @param team_id The ID of the Mattermost team.
#'
#' @return A data frame containing details of a team.
#' @export
#' @examples
#' \dontrun{
#' teams <- get_all_teams()
#' teaminfo <- lapply(teams$id, get_team)
#' }
get_team <- function(team_id = NULL, verbose = FALSE, auth = authenticate_mattermost()){

  # Check required input for completeness
  check_not_null(team_id, "team_id")
  check_mattermost_auth(auth)

  # Define the endpoint for listing all teams
  endpoint <- paste0("/api/v4/teams/" , team_id)

  # Send the request to get all teams
  team_data <- mattermost_api_request( auth = auth, endpoint = endpoint
                                       , method = "GET", verbose = verbose)

  return(team_data)
}
