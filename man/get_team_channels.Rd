% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_team_channels.R
\name{get_team_channels}
\alias{get_team_channels}
\title{Get the list of channels for a team}
\usage{
get_team_channels(
  team_id = NULL,
  verbose = FALSE,
  auth = authenticate_mattermost()
)
}
\arguments{
\item{team_id}{The ID of the team for which to retrieve channels.}

\item{verbose}{(Logical) If `TRUE`, detailed information about the request and response will be printed.}

\item{auth}{A list containing `base_url` and `headers` for authentication.}
}
\value{
A data frame of channels with their IDs and names.
}
\description{
Get the list of channels for a team
}
\examples{
\dontrun{
authenticate_mattermost()
teams <- get_all_teams()
team_channels <- get_team_channels(team_id = teams$id[1])
}
}
\seealso{
[get_channel_id_by_display_name()]
}
