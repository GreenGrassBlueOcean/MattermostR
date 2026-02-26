# Delete a Mattermost channel

Archives a Mattermost channel.

## Usage

``` r
delete_channel(channel_id, team_id, verbose = FALSE, auth = get_default_auth())
```

## Arguments

- channel_id:

  The ID of the channel that will be deleted.

- team_id:

  The ID of the team to which the channel belongs.

- verbose:

  (Logical) If \`TRUE\`, detailed information about the request and
  response will be printed.

- auth:

  The authentication object created by \`authenticate_mattermost()\`.

## Value

A named list with the deletion status as returned by the Mattermost API.

## Details

Note on Channel Deletion

When a channel is deleted online via the Mattermost API, it is not
permanently removed but rather archived. The archived channel can be
restored manually through the Mattermost channel management interface in
the GUI. While the Mattermost REST API specification does include an
option for permanent deletion of channels, this functionality is
currently not implemented in this package.

## Examples

``` r
if (FALSE) { # \dontrun{
# First create a channel
teams <- get_all_teams()
new_channel <- create_channel(team_id = teams$id, name = "newchannel"
, display_name = "a new channel")

# Now delete the channel
info <- delete_channel(channel_id = new_channel$id, team_id = teams$id)
} # }
```
