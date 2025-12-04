# Get data of a single team from its team_id

Get data of a single team from its team_id

## Usage

``` r
get_team(team_id = NULL, verbose = FALSE, auth = authenticate_mattermost())
```

## Arguments

- team_id:

  The ID of the Mattermost team.

- verbose:

  (Logical) If \`TRUE\`, detailed information about the request and
  response will be printed.

- auth:

  A list containing \`base_url\` and \`headers\` for authentication.

## Value

A data frame containing details of a team.

## Examples

``` r
if (FALSE) { # \dontrun{
teams <- get_all_teams()
teaminfo <- lapply(teams$id, get_team)
} # }
```
