# Remove a Reaction from a Mattermost Post

Deletes a specific reaction (emoji) that a user previously added to a
post.

## Usage

``` r
remove_reaction(
  user_id,
  post_id,
  emoji_name,
  verbose = FALSE,
  auth = get_default_auth()
)
```

## Arguments

- user_id:

  The ID of the user whose reaction to remove.

- post_id:

  The ID of the post to remove the reaction from.

- emoji_name:

  The name of the emoji to remove (e.g. `"thumbsup"`). Colons are
  stripped automatically.

- verbose:

  (Logical) If `TRUE`, detailed information about the request and
  response will be printed.

- auth:

  The authentication object created by
  [`authenticate_mattermost()`](https://greengrassblueocean.github.io/MattermostR/reference/authenticate_mattermost.md).
  Must be a valid `mattermost_auth` object.

## Value

A named list with the deletion status as returned by the Mattermost API
(typically `list(status = "OK")`).

## Details

The caller must be the user who made the reaction or have
`manage_system` permission.

## Examples

``` r
if (FALSE) { # \dontrun{
auth <- authenticate_mattermost()
me <- get_me(auth = auth)

# Remove a thumbsup reaction
remove_reaction(
  user_id = me$id,
  post_id = "post_abc123",
  emoji_name = "thumbsup",
  auth = auth
)
} # }
```
