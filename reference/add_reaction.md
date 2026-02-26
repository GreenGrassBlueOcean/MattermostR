# Add a Reaction to a Mattermost Post

Creates a reaction (emoji) on a post.

## Usage

``` r
add_reaction(
  user_id,
  post_id,
  emoji_name,
  verbose = FALSE,
  auth = get_default_auth()
)
```

## Arguments

- user_id:

  The ID of the user adding the reaction.

- post_id:

  The ID of the post to react to.

- emoji_name:

  The name of the emoji to react with (e.g. `"thumbsup"`). Colons are
  stripped automatically, so `":thumbsup:"` also works.

- verbose:

  (Logical) If `TRUE`, detailed information about the request and
  response will be printed.

- auth:

  The authentication object created by
  [`authenticate_mattermost()`](https://greengrassblueocean.github.io/MattermostR/reference/authenticate_mattermost.md).
  Must be a valid `mattermost_auth` object.

## Value

A named list with the reaction's fields: `user_id`, `post_id`,
`emoji_name`, and `create_at`.

## Details

The caller must have `read_channel` permission for the channel the post
is in.

## Examples

``` r
if (FALSE) { # \dontrun{
auth <- authenticate_mattermost()
me <- get_me(auth = auth)

# React with thumbsup
add_reaction(
  user_id = me$id,
  post_id = "post_abc123",
  emoji_name = "thumbsup",
  auth = auth
)

# Colons are stripped automatically
add_reaction(
  user_id = me$id,
  post_id = "post_abc123",
  emoji_name = ":white_check_mark:",
  auth = auth
)
} # }
```
