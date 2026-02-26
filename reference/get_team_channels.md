# Get the list of channels for a team

Get the list of channels for a team

## Usage

``` r
get_team_channels(team_id = NULL, verbose = FALSE, auth = get_default_auth())
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

A data frame with one row per channel (columns include \`id\`,
\`display_name\`, \`name\`, \`type\`, \`team_id\`, etc.).

## See also

\[get_channel_id_by_display_name()\]

## Examples

``` r
if (FALSE) { # \dontrun{
authenticate_mattermost()
teams <- get_all_teams()
team_channels <- get_team_channels(team_id = teams$id[1])
} # }
```
