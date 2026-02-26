# Remove a user from a channel

Remove a user from a channel by deleting their channel membership. Only
works for public and private channels (not direct or group messages).

## Usage

``` r
remove_channel_member(
  channel_id,
  user_id,
  verbose = FALSE,
  auth = get_default_auth()
)
```

## Arguments

- channel_id:

  Character. The channel ID to remove the user from.

- user_id:

  Character. The user ID to remove.

- verbose:

  Logical. Print detailed request information? Default \`FALSE\`.

- auth:

  A \`mattermost_auth\` object created by \[authenticate_mattermost()\].
  Defaults to \[get_default_auth()\].

## Value

A named list with \`status = "OK"\` on success.

## Permissions

Requires \`manage_public_channel_members\` for public channels or
\`manage_private_channel_members\` for private channels.

## See also

\[get_channel_members()\], \[add_user_to_channel()\]

## Examples

``` r
if (FALSE) { # \dontrun{
  remove_channel_member("channel_id_abc", "user_id_xyz")
} # }
```
