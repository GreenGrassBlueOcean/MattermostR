# Get data of a single team from its team_id

Get data of a single team from its team_id

## Usage

``` r
get_team(team_id = NULL, verbose = FALSE, auth = get_default_auth())
```

## Arguments

- team_id:

  A character string containing the Mattermost team ID.

- verbose:

  (Logical) If \`TRUE\`, detailed information about the request and
  response will be printed. Default is \`FALSE\`.

- auth:

  The authentication object created by \[authenticate_mattermost()\].

## Value

A named list with team fields returned by the Mattermost API (e.g.
\`id\`, \`display_name\`, \`name\`, \`type\`).

## Examples

``` r
if (FALSE) { # \dontrun{
teams <- get_all_teams()
teaminfo <- lapply(teams$id, get_team)
} # }
```
