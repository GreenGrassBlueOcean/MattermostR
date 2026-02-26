# Search for posts in Mattermost

This function searches for posts across Mattermost based on specified
search terms and filters. It allows you to search by keywords, filter by
channels, users, dates, and more.

## Usage

``` r
search_posts(
  terms,
  team_id = NULL,
  in_channels = NULL,
  from_users = NULL,
  after_date = NULL,
  before_date = NULL,
  is_or_search = FALSE,
  page = 0,
  per_page = 200,
  time_zone_offset = 0,
  verbose = FALSE,
  auth = get_default_auth()
)
```

## Arguments

- terms:

  A character string containing the search terms. This is the main
  search query.

- team_id:

  (Optional) The ID of the team to search within. \*\*Recommended.\*\*
  Global searches (NULL team_id) often return incomplete results
  depending on server configuration.

- in_channels:

  (Optional) A character vector of channel IDs to limit the search to
  specific channels.

- from_users:

  (Optional) A character vector of user IDs to limit the search to posts
  from specific users.

- after_date:

  (Optional) A POSIXct date object or character string (YYYY-MM-DD) to
  search for posts after this date.

- before_date:

  (Optional) A POSIXct date object or character string (YYYY-MM-DD) to
  search for posts before this date.

- is_or_search:

  (Logical) If \`TRUE\`, posts matching any of the search terms will be
  returned (OR search). If \`FALSE\` (default), posts must match all
  search terms (AND search).

- page:

  (Integer) The page number for pagination (0-based, default is 0).

- per_page:

  (Integer) The number of posts per page. Defaults to \*\*200\*\* (max)
  to capture most results.

- time_zone_offset:

  (Integer) Time zone offset in hours from UTC (default is 0).

- verbose:

  (Logical) If \`TRUE\`, detailed information about the request and
  response will be printed.

- auth:

  The authentication object created by \`authenticate_mattermost()\`.

## Value

A data frame containing the search results with columns: - \`id\`: Post
ID - \`create_at\`: Creation timestamp (POSIXct) - \`update_at\`: Last
update timestamp (POSIXct) - \`edit_at\`: Last edit timestamp
(POSIXct) - \`delete_at\`: Deletion timestamp (POSIXct) if deleted -
\`is_pinned\`: Whether the post is pinned - \`user_id\`: ID of the user
who created the post - \`channel_id\`: ID of the channel containing the
post - \`message\`: The post message content - \`type\`: Post type

To get channel information (e.g., display name), use
\`get_channel_info()\` with the \`channel_id\`.

## Important - Bot Permissions

Mattermost Search typically \*\*only returns results from channels the
bot has joined\*\*. Even if a channel is public, you must use
\`add_user_to_channel()\` to add the bot before its posts will appear in
search results.

## Examples

``` r
if (FALSE) { # \dontrun{
  # 1. Authenticate
  auth <- authenticate_mattermost(
    base_url = "https://yourmattermost.server.com",
    token = "your-token"
  )

  # 2. Basic Team Search (Recommended)
  # Search results are usually scoped to a team.
  teams <- get_all_teams(auth = auth)
  team_id <- teams$id[1] # Use the first team

  results <- search_posts(
    terms = "project deadline",
    team_id = team_id,
    verbose = TRUE,
    auth = auth
  )

  # 3. Search in a Specific Channel (Ensuring Bot Access)
  # Note: Bots must usually JOIN a channel to search inside it.

  # a. Find the channel ID
  channels <- get_team_channels(team_id = team_id, auth = auth)
  channel_id <- get_channel_id_lookup(channels, name = "off-topic")

  # b. Add the bot to the channel (safe to run even if already a member)
  me <- get_user("me", auth = auth)
  add_user_to_channel(channel_id, me$id, auth = auth)

  # c. Perform the search
  results <- search_posts(
    terms = "lunch",
    team_id = team_id,
    in_channels = channel_id,
    auth = auth
  )

  # 4. Search with Date Filters
  results <- search_posts(
    terms = "error",
    team_id = team_id,
    after_date = "2024-01-01",
    before_date = Sys.Date(),
    auth = auth
  )

  # 5. Advanced: Combined Filter with Pagination
  # Search for "urgent" OR "critical" from specific users
  results <- search_posts(
    terms = "urgent critical",
    team_id = team_id,
    is_or_search = TRUE,
    per_page = 200,
    auth = auth
  )
} # }
```
