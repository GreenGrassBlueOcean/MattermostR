# Get members of a channel

Retrieve a page of members for a channel. Each member record includes
the user's ID, roles, notification preferences, and activity timestamps.

## Usage

``` r
get_channel_members(
  channel_id,
  page = 0,
  per_page = 60,
  verbose = FALSE,
  auth = get_default_auth()
)
```

## Arguments

- channel_id:

  Character. The channel ID to query.

- page:

  Integer. Zero-based page number. Default \`0\`.

- per_page:

  Integer. Number of members per page. Default \`60\` (Mattermost API
  default). Maximum \`200\`.

- verbose:

  Logical. Print detailed request information? Default \`FALSE\`.

- auth:

  A \`mattermost_auth\` object created by \[authenticate_mattermost()\].
  Defaults to \[get_default_auth()\].

## Value

A data frame of channel members with columns such as \`channel_id\`,
\`user_id\`, \`roles\`, \`last_viewed_at\`, \`msg_count\`,
\`mention_count\`, \`last_update_at\`, \`scheme_user\`, and
\`scheme_admin\`.

## Permissions

Must have \`read_channel\` permission for the channel.

## See also

\[add_user_to_channel()\], \[remove_channel_member()\]

## Examples

``` r
if (FALSE) { # \dontrun{
  members <- get_channel_members("channel_id_abc")
  nrow(members)

  # Page through results
  page2 <- get_channel_members("channel_id_abc", page = 1, per_page = 100)
} # }
```
