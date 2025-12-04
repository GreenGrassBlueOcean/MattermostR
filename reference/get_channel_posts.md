# Get posts from a Mattermost channel

Get posts from a Mattermost channel

## Usage

``` r
get_channel_posts(
  channel_id,
  verbose = FALSE,
  auth = authenticate_mattermost()
)
```

## Arguments

- channel_id:

  The Mattermost channel ID.

- verbose:

  Boolean. If \`TRUE\`, the function will print request/response details
  for more information.

- auth:

  The authentication object created by \`authenticate_mattermost()\`.

## Value

Parsed JSON response with posts from the channel.

## Examples

``` r
if (FALSE) { # \dontrun{
  teams <- get_all_teams()
  team_channels <- get_team_channels(team_id = teams$id[1])
  channel_id <- get_channel_id_lookup(team_channels, name = "off-topic")
  posts <- get_channel_posts(channel_id)
} # }
```
