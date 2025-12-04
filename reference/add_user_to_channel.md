# Add a user to a channel

Adds a user to a specified Mattermost channel. This function resolves
the IDs into readable names to provide a user-friendly success message.

## Usage

``` r
add_user_to_channel(
  channel_id,
  user_id,
  verbose = FALSE,
  auth = authenticate_mattermost()
)
```

## Arguments

- channel_id:

  The ID of the channel to add the user to.

- user_id:

  The ID of the user to add. You can use the string "me" to add the
  authenticated user.

- verbose:

  Boolean. If \`TRUE\`, prints the request details.

- auth:

  The authentication object created by \`authenticate_mattermost()\`.

## Value

The raw channel member object (invisibly) for programmatic use.

## Examples

``` r
if (FALSE) { # \dontrun{
  # Authenticate
  auth <- authenticate_mattermost()

  # Get current user ID
  me <- get_user_info("me", auth = auth)

  # Get the first team available to the user
  teams <- get_all_teams(auth = auth)
  team_id <- teams$id[1]

  # Get channels for this team
  channels <- get_team_channels(team_id = team_id, auth = auth)

  # Get the channel ID for "Town Square" by name
  channel_id <- get_channel_id_lookup(channels, name = "town-square")

  # Add current user to that channel
  add_user_to_channel(channel_id, me$id, auth = auth)
} # }
```
