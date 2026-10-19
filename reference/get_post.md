# Retrieve a Single Mattermost Post by ID

Fetches the full post object for a specific Mattermost \`post_id\` via
\`GET /api/v4/posts/\<post_id\>\`.

## Usage

``` r
get_post(post_id = NULL, verbose = FALSE, auth = get_default_auth())
```

## Arguments

- post_id:

  Character string. The ID of the post to retrieve.

- verbose:

  Logical. If \`TRUE\`, prints request and response details. Default
  \`FALSE\`.

- auth:

  The authentication object created by \[authenticate_mattermost()\].

## Value

A named list representing the Mattermost post object (including \`id\`,
\`create_at\`, \`user_id\`, \`channel_id\`, \`root_id\`, \`message\`,
\`props\`, etc.).

## Examples

``` r
if (FALSE) { # \dontrun{
auth <- authenticate_mattermost()
post <- get_post("post_id_123", auth = auth)
} # }
```
