# Retrieve a Mattermost Post Thread by Post ID

Fetches the root post and all replies in the thread containing
\`post_id\` via \`GET /api/v4/posts/\<post_id\>/thread\`, returning a
chronologically ordered data frame.

## Usage

``` r
get_post_thread(
  post_id = NULL,
  per_page = NULL,
  from_post = NULL,
  include_metadata = TRUE,
  verbose = FALSE,
  auth = get_default_auth()
)
```

## Arguments

- post_id:

  Character string. The ID of any post in the thread (typically the root
  post).

- per_page:

  Optional integer. Maximum number of posts to return per page.

- from_post:

  Optional character string. Post ID to start pagination from.

- include_metadata:

  Logical. If \`TRUE\` (default), includes \`root_id\`,
  \`override_username\`, and \`from_webhook\` columns.

- verbose:

  Logical. If \`TRUE\`, prints request and response details. Default
  \`FALSE\`.

- auth:

  The authentication object created by \[authenticate_mattermost()\].

## Value

A data frame of posts in the thread ordered chronologically by
\`create_at\` ascending.

## Examples

``` r
if (FALSE) { # \dontrun{
auth <- authenticate_mattermost()
thread_df <- get_post_thread("root_post_id_123", auth = auth)
} # }
```
