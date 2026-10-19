# Get Channel Posts with Extended Webhook and Thread Metadata

Convenience wrapper around
[`get_channel_posts`](https://greengrassblueocean.github.io/MattermostR/reference/get_channel_posts.md)
that defaults `include_metadata = TRUE` (extracting `root_id`,
`override_username`, and `from_webhook`) and preserves Mattermost's
reverse-chronological post ordering.

## Usage

``` r
mm_get_channel_posts(
  channel_id,
  page = 0,
  per_page = 60,
  since = NULL,
  include_metadata = TRUE,
  verbose = FALSE,
  auth = get_default_auth()
)
```

## Arguments

- channel_id:

  The Mattermost channel ID.

- page:

  (Integer) The page to select (0-based). Default is 0.

- per_page:

  (Integer) The number of posts per page. Default is 60, maximum is 200.

- since:

  (Optional) A POSIXct, Date, or numeric (Unix time in milliseconds)
  value. When provided, returns all posts created or modified after this
  time, up to a server-side limit of 1000 posts. \*\*Cannot\*\* be
  combined with \`page\` or \`per_page\`.

- include_metadata:

  Boolean. If \`TRUE\`, appends \`root_id\`, \`override_username\`, and
  \`from_webhook\` columns extracted from post metadata. Default is
  \`FALSE\`.

- verbose:

  Boolean. If \`TRUE\`, the function will print request/response details
  for more information.

- auth:

  The authentication object created by \`authenticate_mattermost()\`.

## Value

A data frame of posts ordered newest-first, including extended metadata
columns (`root_id`, `override_username`, `from_webhook`) when
`include_metadata = TRUE`.

## Examples

``` r
if (FALSE) { # \dontrun{
  posts <- mm_get_channel_posts("channel_id_here", per_page = 60)
} # }
```
