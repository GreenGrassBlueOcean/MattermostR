# Delete Messages Older Than X Days in a Mattermost Channel

This function deletes messages that are older than a specified number of
days in a given Mattermost channel. It auto-paginates through all posts
in the channel, filters by creation timestamp, and deletes the ones
older than the specified number of days.

## Usage

``` r
delete_old_messages(channel_id, days, auth = get_default_auth())
```

## Arguments

- channel_id:

  Character string. The ID of the Mattermost channel from which messages
  should be deleted.

- days:

  Numeric. The age in days of the messages to be deleted.

- auth:

  The authentication object created by \`authenticate_mattermost()\`.

## Value

A data frame with columns \`message_id\` and \`delete_status\`, or an
empty data frame if no messages were deleted.

## Examples

``` r
if (FALSE) { # \dontrun{
  teams <- get_all_teams()
  team_channels <- get_team_channels(team_id = teams$id[1])
  channel_id <- get_channel_id_lookup(team_channels, name = "off-topic")
  posts <- delete_old_messages(channel_id, 0)

} # }
```
