# Update (Patch) an Existing Mattermost Post

Partially updates a post by providing only the fields to change. Omitted
fields are left unchanged. Uses the `PATCH` endpoint
(`PUT /api/v4/posts/{post_id}/patch`).

## Usage

``` r
update_post(
  post_id,
  message = NULL,
  is_pinned = NULL,
  props = NULL,
  verbose = FALSE,
  auth = get_default_auth()
)
```

## Arguments

- post_id:

  The ID of the post to update. Must be a non-empty string.

- message:

  Optional. The new message text (supports Markdown).

- is_pinned:

  Optional. Set to `TRUE` to pin the post to the channel, or `FALSE` to
  unpin it.

- props:

  Optional. A named list of properties to attach to the post.

- verbose:

  (Logical) If `TRUE`, detailed information about the request and
  response will be printed.

- auth:

  The authentication object created by
  [`authenticate_mattermost()`](https://greengrassblueocean.github.io/MattermostR/reference/authenticate_mattermost.md).
  Must be a valid `mattermost_auth` object.

## Value

A named list containing the updated post's fields (e.g. `id`, `message`,
`channel_id`, `is_pinned`).

## Details

At least one of `message`, `is_pinned`, or `props` must be provided. The
caller must have `edit_post` permission for the channel the post is in.

## See also

\[pin_post()\] and \[unpin_post()\] for dedicated pin/unpin endpoints.

## Examples

``` r
if (FALSE) { # \dontrun{
auth <- authenticate_mattermost()

# Edit a message
update_post(post_id = "abc123", message = "Updated text", auth = auth)

# Pin a post
update_post(post_id = "abc123", is_pinned = TRUE, auth = auth)

# Edit message and pin in one call
update_post(
  post_id = "abc123",
  message = "Important update",
  is_pinned = TRUE,
  auth = auth
)
} # }
```
