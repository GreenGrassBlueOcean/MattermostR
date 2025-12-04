# Get the list of channels for a team

Get the list of channels for a team

## Usage

``` r
get_team_channels(
  team_id = NULL,
  verbose = FALSE,
  auth = authenticate_mattermost()
)
```

## Arguments

- team_id:

  The ID of the team for which to retrieve channels.

- verbose:

  (Logical) If \`TRUE\`, detailed information about the request and
  response will be printed.

- auth:

  A list containing \`base_url\` and \`headers\` for authentication.

## Value

A data frame of channels with their IDs and names.

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
