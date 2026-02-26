# Add multiple users to a channel in a single API call

Uses the Mattermost batch endpoint to add up to 1000 users to a channel
with a single HTTP request. This is far more efficient than calling
\[add_user_to_channel()\] in a loop.

## Usage

``` r
add_users_to_channel(
  channel_id,
  user_ids,
  resolve_names = FALSE,
  verbose = FALSE,
  auth = get_default_auth()
)
```

## Arguments

- channel_id:

  The ID of the channel to add users to.

- user_ids:

  A character vector of user IDs (max 1000).

- resolve_names:

  Logical. If \`TRUE\`, fetches readable usernames and the channel name
  for the success message (2 extra API calls, regardless of how many
  users). Defaults to \`FALSE\` for efficiency.

- verbose:

  Boolean. If \`TRUE\`, prints the request details.

- auth:

  The authentication object created by \[authenticate_mattermost()\].

## Value

The API response (invisibly). Typically a list with a \`channel_id\` and
member details.

## See also

\[add_user_to_channel()\] for adding a single user.

## Examples

``` r
if (FALSE) { # \dontrun{
  # Add 50 users to a channel in one shot
  add_users_to_channel(channel_id, user_ids = ids_vector, auth = auth)

  # With friendly names in the message
  add_users_to_channel(channel_id, user_ids = ids_vector,
                       resolve_names = TRUE, auth = auth)
} # }
```
