# Delete Messages Older Than X Days in a Mattermost Channel

This function deletes messages that are older than a specified number of
days in a given Mattermost channel. It fetches the messages from the
channel, checks their timestamps, and deletes the ones that are older
than the specified days.

## Usage

``` r
delete_old_messages(channel_id, days, auth = authenticate_mattermost())
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

A character vector of message IDs that were deleted.

## Examples

``` r
if (FALSE) { # \dontrun{
  teams <- get_all_teams()
  team_channels <- get_team_channels(team_id = teams$id[1])
  channel_id <- get_channel_id_lookup(team_channels, name = "off-topic")
  posts <- delete_old_messages(channel_id, 0)

} # }
```
