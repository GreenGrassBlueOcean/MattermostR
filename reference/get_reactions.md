# Get All Reactions on a Mattermost Post

Retrieves all reactions made by all users on a given post.

## Usage

``` r
get_reactions(post_id, verbose = FALSE, auth = get_default_auth())
```

## Arguments

- post_id:

  The ID of the post to get reactions for.

- verbose:

  (Logical) If `TRUE`, detailed information about the request and
  response will be printed.

- auth:

  The authentication object created by
  [`authenticate_mattermost()`](https://greengrassblueocean.github.io/MattermostR/reference/authenticate_mattermost.md).
  Must be a valid `mattermost_auth` object.

## Value

A data frame of reactions with columns `user_id`, `post_id`,
`emoji_name`, and `create_at`. Returns an empty result if there are no
reactions.

## Details

The caller must have `read_channel` permission for the channel the post
is in.

## Examples

``` r
if (FALSE) { # \dontrun{
reactions <- get_reactions(post_id = "post_abc123")
reactions
} # }
```
