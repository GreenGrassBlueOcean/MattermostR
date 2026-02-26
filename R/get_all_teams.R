
#' List all teams in Mattermost
#'
#' @param verbose (Logical) If `TRUE`, detailed information about the request
#'   and response will be printed. Default is `FALSE`.
#' @param auth The authentication object created by [authenticate_mattermost()].
#'
#' @return A data frame with one row per team (columns include `id`,
#'   `display_name`, `name`, `type`, etc.). Returns an empty data frame /
#'   list if the user belongs to no teams (with a warning).
#' @export
#' @examples
#' \dontrun{
#' teams <- get_all_teams()
#' }
get_all_teams <- function(verbose = FALSE, auth = get_default_auth()){

  # Check required input for completeness
  check_mattermost_auth(auth)

  # Auto-paginate through all teams (API defaults to 60 per page)
  teams_data <- paginate_api(auth, "/api/v4/teams", per_page = 200,
                             verbose = verbose)

  if (is.data.frame(teams_data) && nrow(teams_data) == 0L) {
    warning("The user for which the current bearer authentication key is taken is not part of any teams, change bearer key?
            , use get_me() to obtain more information about the current key user")
  }

  return(teams_data)
}


#' Get data of a single team from its team_id
#'
#' @param team_id A character string containing the Mattermost team ID.
#' @param verbose (Logical) If `TRUE`, detailed information about the request
#'   and response will be printed. Default is `FALSE`.
#' @param auth The authentication object created by [authenticate_mattermost()].
#'
#' @return A named list with team fields returned by the Mattermost API
#'   (e.g. `id`, `display_name`, `name`, `type`).
#' @export
#' @examples
#' \dontrun{
#' teams <- get_all_teams()
#' teaminfo <- lapply(teams$id, get_team)
#' }
get_team <- function(team_id = NULL, verbose = FALSE, auth = get_default_auth()){

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
