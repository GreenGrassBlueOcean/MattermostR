# Add a user to a channel

Adds a user to a specified Mattermost channel.

## Usage

``` r
add_user_to_channel(
  channel_id,
  user_id,
  resolve_names = TRUE,
  verbose = FALSE,
  auth = get_default_auth()
)
```

## Arguments

- channel_id:

  The ID of the channel to add the user to.

- user_id:

  The ID of the user to add. You can use the string \`"me"\` to add the
  authenticated user.

- resolve_names:

  Logical. If \`TRUE\` (default), fetches readable usernames and channel
  names for the success message. Set to \`FALSE\` to skip these lookups
  and save 2 API calls.

- verbose:

  Boolean. If \`TRUE\`, prints the request details.

- auth:

  The authentication object created by \[authenticate_mattermost()\].

## Value

The channel member object returned by the API (invisibly).

## Details

By default, the function resolves the user and channel IDs into readable
names for a user-friendly success message (2 extra API calls). Set
\`resolve_names = FALSE\` to skip these lookups and reduce API traffic
to a single call — useful when adding users in a loop. For true batch
operations, see \[add_users_to_channel()\].

## See also

\[add_users_to_channel()\] for batch operations.

## Examples

``` r
if (FALSE) { # \dontrun{
  # Add current user to a channel (with friendly names)
  me <- get_user("me", auth = auth)
  add_user_to_channel(channel_id, me$id, auth = auth)

  # Fast path: skip name resolution
  add_user_to_channel(channel_id, me$id, resolve_names = FALSE, auth = auth)
} # }
```
