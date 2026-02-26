
#' Get the list of channels for a team
#'
#' @param team_id A character string containing the Mattermost team ID.
#' @param verbose (Logical) If `TRUE`, detailed information about the request
#'   and response will be printed. Default is `FALSE`.
#' @param auth The authentication object created by [authenticate_mattermost()].
#'
#' @return A data frame with one row per channel (columns include `id`,
#'   `display_name`, `name`, `type`, `team_id`, etc.).
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
get_team_channels <- function(team_id = NULL, verbose = FALSE, auth = get_default_auth()) {

  # Check required input for completeness
  check_not_null(team_id, "team_id")
  check_mattermost_auth(auth)

  # Auto-paginate through all channels (API defaults to 60 per page)
  endpoint <- paste0("/api/v4/teams/", team_id, "/channels")
  paginate_api(auth, endpoint, per_page = 200, verbose = verbose)
}
