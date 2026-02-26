# Create a Direct Message or Group Message Channel

Creates a direct message channel (2 users) or a group message channel
(3–8 users). If the channel already exists, the existing channel is
returned (the operation is idempotent).

## Usage

``` r
create_direct_channel(user_ids, verbose = FALSE, auth = get_default_auth())
```

## Arguments

- user_ids:

  A character vector of Mattermost user IDs.

  - Exactly 2 IDs creates a **direct message** channel
    (`POST /api/v4/channels/direct`).

  - 3–8 IDs creates a **group message** channel
    (`POST /api/v4/channels/group`).

- verbose:

  (Logical) If `TRUE`, detailed information about the request and
  response will be printed.

- auth:

  The authentication object created by
  [`authenticate_mattermost()`](https://greengrassblueocean.github.io/MattermostR/reference/authenticate_mattermost.md).
  Must be a valid `mattermost_auth` object.

## Value

A named list with the channel's fields (e.g. `id`, `name`, `type`).
Direct message channels have `type = "D"`; group message channels have
`type = "G"`.

## Details

After creating the channel, use
[`send_mattermost_message`](https://greengrassblueocean.github.io/MattermostR/reference/send_mattermost_message.md)`(channel_id = result$id, ...)`
to send messages to it.

## Examples

``` r
if (FALSE) { # \dontrun{
auth <- authenticate_mattermost()

# Create a direct message channel between two users
dm <- create_direct_channel(
  user_ids = c("user_id_1", "user_id_2"),
  auth = auth
)
send_mattermost_message(channel_id = dm$id, message = "Hello!", auth = auth)

# Create a group message channel with three users
gm <- create_direct_channel(
  user_ids = c("user_id_1", "user_id_2", "user_id_3"),
  auth = auth
)
send_mattermost_message(channel_id = gm$id, message = "Hi team!", auth = auth)
} # }
```
