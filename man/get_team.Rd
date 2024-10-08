% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_all_teams.R
\name{get_team}
\alias{get_team}
\title{Get data of a single team from its team_id}
\usage{
get_team(team_id = NULL, verbose = FALSE, auth = authenticate_mattermost())
}
\arguments{
\item{team_id}{The ID of the Mattermost team.}

\item{verbose}{(Logical) If `TRUE`, detailed information about the request and response will be printed.}

\item{auth}{A list containing `base_url` and `headers` for authentication.}
}
\value{
A data frame containing details of a team.
}
\description{
Get data of a single team from its team_id
}
\examples{
\dontrun{
teams <- get_all_teams()
teaminfo <- lapply(teams$id, get_team)
}
}
