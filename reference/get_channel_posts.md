# Get posts from a Mattermost channel

Retrieves posts from a Mattermost channel with support for pagination.
The Mattermost API returns at most \`per_page\` posts per request
(default 60). Use the \`page\` and \`per_page\` parameters to paginate
through results, or use \`since\` to retrieve all posts modified after a
given timestamp (up to 1000).

## Usage

``` r
get_channel_posts(
  channel_id,
  page = 0,
  per_page = 60,
  since = NULL,
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

- verbose:

  Boolean. If \`TRUE\`, the function will print request/response details
  for more information.

- auth:

  The authentication object created by \`authenticate_mattermost()\`.

## Value

A data frame of posts from the channel with columns \`id\`,
\`create_at\`, \`update_at\`, \`edit_at\`, \`delete_at\`, \`is_pinned\`,
\`user_id\`, \`channel_id\`, \`message\`, and \`type\`. Returns an empty
data frame if no posts are found.

A warning is issued when the number of returned posts equals
\`per_page\`, indicating that additional pages may be available.

## Examples

``` r
if (FALSE) { # \dontrun{
  teams <- get_all_teams()
  team_channels <- get_team_channels(team_id = teams$id[1])
  channel_id <- get_channel_id_lookup(team_channels, "off-topic")

  # Get the first page (default 60 posts)
  posts <- get_channel_posts(channel_id)

  # Get 200 posts per page, page 0
  posts <- get_channel_posts(channel_id, per_page = 200)

  # Get page 2
  posts <- get_channel_posts(channel_id, page = 2, per_page = 200)

  # Get all posts modified since a date (up to 1000)
  posts <- get_channel_posts(channel_id, since = as.POSIXct("2024-01-01", tz = "UTC"))
} # }
```
