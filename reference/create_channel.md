# Create a new Mattermost channel

Create a new Mattermost channel

## Usage

``` r
create_channel(
  team_id = NULL,
  name = NULL,
  display_name = NULL,
  type = "O",
  verbose = FALSE,
  auth = authenticate_mattermost()
)
```

## Arguments

- team_id:

  The ID of the team where the channel will be created.

- name:

  A short name for the channel.

- display_name:

  The display name for the channel.

- type:

  The type of the channel: "O" for open (default) or "P" for private.

- verbose:

  (Logical) If \`TRUE\`, detailed information about the request and
  response will be printed.

- auth:

  The authentication object created by \`authenticate_mattermost()\`.

## Value

A list with details about the created channel.

## Examples

``` r
if (FALSE) { # \dontrun{
teams <- get_all_teams()
new_channel <- create_channel(team_id = teams$id[1], name = "newchannel2"
, display_name = "a new channel", verbose = TRUE)
} # }
```
