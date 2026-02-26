# Changelog

## MattermostR 0.2.0

### New functions

#### Messaging

- [`send_webhook_message()`](https://greengrassblueocean.github.io/MattermostR/reference/send_webhook_message.md)
  — send messages via incoming webhooks (no auth required).
- [`update_post()`](https://greengrassblueocean.github.io/MattermostR/reference/update_post.md)
  — edit an existing post’s message text, pinned state, or props.
- [`delete_old_messages()`](https://greengrassblueocean.github.io/MattermostR/reference/delete_old_messages.md)
  now auto-paginates via an internal helper; no manual looping needed.

#### Posts, reactions & pins

- [`add_reaction()`](https://greengrassblueocean.github.io/MattermostR/reference/add_reaction.md),
  [`get_reactions()`](https://greengrassblueocean.github.io/MattermostR/reference/get_reactions.md),
  [`remove_reaction()`](https://greengrassblueocean.github.io/MattermostR/reference/remove_reaction.md)
  — emoji reactions on posts.
- [`pin_post()`](https://greengrassblueocean.github.io/MattermostR/reference/pin_post.md),
  [`unpin_post()`](https://greengrassblueocean.github.io/MattermostR/reference/unpin_post.md)
  — semantic pin/unpin using the dedicated API endpoints.
- [`get_channel_posts()`](https://greengrassblueocean.github.io/MattermostR/reference/get_channel_posts.md)
  gains `page`, `per_page`, and `since` parameters with pagination
  support.

#### Channels

- [`create_direct_channel()`](https://greengrassblueocean.github.io/MattermostR/reference/create_direct_channel.md)
  — creates a DM (2 user IDs) or group message channel (3–8 user IDs).
- [`get_channel_members()`](https://greengrassblueocean.github.io/MattermostR/reference/get_channel_members.md)
  — paginated retrieval of channel membership.
- [`remove_channel_member()`](https://greengrassblueocean.github.io/MattermostR/reference/remove_channel_member.md)
  — remove a user from a channel.
- [`add_users_to_channel()`](https://greengrassblueocean.github.io/MattermostR/reference/add_users_to_channel.md)
  — batch-add up to 1000 users in a single API call.
- [`add_user_to_channel()`](https://greengrassblueocean.github.io/MattermostR/reference/add_user_to_channel.md)
  gains a `resolve_names` parameter (default `TRUE`).

#### Users

- [`get_user_status()`](https://greengrassblueocean.github.io/MattermostR/reference/get_user_status.md),
  [`set_user_status()`](https://greengrassblueocean.github.io/MattermostR/reference/set_user_status.md)
  — read and set online/away/offline/DND status, with DND end-time
  support.

#### Bots

- [`create_bot()`](https://greengrassblueocean.github.io/MattermostR/reference/create_bot.md),
  [`get_bot()`](https://greengrassblueocean.github.io/MattermostR/reference/get_bot.md),
  [`get_bots()`](https://greengrassblueocean.github.io/MattermostR/reference/get_bots.md),
  [`update_bot()`](https://greengrassblueocean.github.io/MattermostR/reference/update_bot.md),
  [`disable_bot()`](https://greengrassblueocean.github.io/MattermostR/reference/disable_bot.md),
  [`enable_bot()`](https://greengrassblueocean.github.io/MattermostR/reference/enable_bot.md),
  [`assign_bot()`](https://greengrassblueocean.github.io/MattermostR/reference/assign_bot.md)
  — full bot account management.

#### Slash commands

- [`create_command()`](https://greengrassblueocean.github.io/MattermostR/reference/create_command.md),
  [`get_command()`](https://greengrassblueocean.github.io/MattermostR/reference/get_command.md),
  [`list_commands()`](https://greengrassblueocean.github.io/MattermostR/reference/list_commands.md),
  [`update_command()`](https://greengrassblueocean.github.io/MattermostR/reference/update_command.md),
  [`delete_command()`](https://greengrassblueocean.github.io/MattermostR/reference/delete_command.md),
  [`execute_command()`](https://greengrassblueocean.github.io/MattermostR/reference/execute_command.md),
  [`regen_command_token()`](https://greengrassblueocean.github.io/MattermostR/reference/regen_command_token.md)
  — full slash command lifecycle.

### Improvements

- Thread replies:
  [`send_mattermost_message()`](https://greengrassblueocean.github.io/MattermostR/reference/send_mattermost_message.md)
  gains a `root_id` parameter for posting into threads.
- Message priority: priority is now passed under `metadata$priority`
  (the correct API location). Valid values are `"Normal"` (default),
  `"Important"`, and `"Urgent"`. The old undocumented `"High"` / `"Low"`
  values have been removed.
- `send_mattermost_file()` now delegates to
  [`mattermost_api_request()`](https://greengrassblueocean.github.io/MattermostR/reference/mattermost_api_request.md)
  with `multipart = TRUE`, gaining retry/backoff, error handling, and
  verbose support.
- Rate limiting: proactive throttling at 10 req/s via `req_throttle()`.
  Reactive 429 handling reads `X-Ratelimit-Reset` for precise wait
  timing. Override with `options(MattermostR.rate_limit = Inf)`.
- Structured error conditions: HTTP errors now raise a
  `mattermost_error` S3 condition. Set
  `options(MattermostR.on_error = "message")` for legacy `NULL`-return
  behaviour.
- `get_default_auth()` and
  [`authenticate_mattermost()`](https://greengrassblueocean.github.io/MattermostR/reference/authenticate_mattermost.md)
  now resolve credentials from environment variables
  (`MATTERMOST_TOKEN`, `MATTERMOST_URL`) before R options, in both
  functions.
- [`authenticate_mattermost()`](https://greengrassblueocean.github.io/MattermostR/reference/authenticate_mattermost.md)
  gains `cache_credentials = FALSE` to prevent storing the token in
  [`options()`](https://rdrr.io/r/base/options.html).
  [`clear_mattermost_credentials()`](https://greengrassblueocean.github.io/MattermostR/reference/clear_mattermost_credentials.md)
  wipes cached credentials.
- [`print.mattermost_auth()`](https://greengrassblueocean.github.io/MattermostR/reference/print.mattermost_auth.md)
  masks the bearer token in console output.
- `paginate_api()` internal helper auto-paginates any GET endpoint that
  supports `page`/`per_page`. Used by
  [`get_all_teams()`](https://greengrassblueocean.github.io/MattermostR/reference/get_all_teams.md),
  [`get_team_channels()`](https://greengrassblueocean.github.io/MattermostR/reference/get_team_channels.md),
  and post-retrieval.
- [`get_user_info()`](https://greengrassblueocean.github.io/MattermostR/reference/get_user_info.md)
  is now deprecated in favour of
  [`get_user()`](https://greengrassblueocean.github.io/MattermostR/reference/get_user.md)
  (emits a `lifecycle` warning).
- [`get_me()`](https://greengrassblueocean.github.io/MattermostR/reference/get_me.md)
  now defaults to `verbose = FALSE`, consistent with all other
  functions.
- `check_not_null()` rewritten to handle vector inputs safely.

### Bug fixes

- Username/password login rewritten to use `httr2` directly, fixing
  broken authentication flow.
- [`get_channel_posts()`](https://greengrassblueocean.github.io/MattermostR/reference/get_channel_posts.md)
  previously returned only the first page; now fully paginated.

------------------------------------------------------------------------

## MattermostR 0.1.0

- Initial release.
- [`authenticate_mattermost()`](https://greengrassblueocean.github.io/MattermostR/reference/authenticate_mattermost.md)
  — token-based and username/password authentication.
- [`send_mattermost_message()`](https://greengrassblueocean.github.io/MattermostR/reference/send_mattermost_message.md)
  — send messages with optional file and plot attachments.
- `send_mattermost_file()` — upload files to a channel.
- [`get_mattermost_file()`](https://greengrassblueocean.github.io/MattermostR/reference/get_mattermost_file.md)
  — download files from Mattermost.
- [`create_channel()`](https://greengrassblueocean.github.io/MattermostR/reference/create_channel.md),
  [`delete_channel()`](https://greengrassblueocean.github.io/MattermostR/reference/delete_channel.md)
  — channel management.
- [`get_channel_info()`](https://greengrassblueocean.github.io/MattermostR/reference/get_channel_info.md),
  [`get_channel_id_lookup()`](https://greengrassblueocean.github.io/MattermostR/reference/get_channel_id_lookup.md)
  — channel lookup helpers.
- [`get_team_channels()`](https://greengrassblueocean.github.io/MattermostR/reference/get_team_channels.md),
  [`get_all_teams()`](https://greengrassblueocean.github.io/MattermostR/reference/get_all_teams.md),
  [`get_team()`](https://greengrassblueocean.github.io/MattermostR/reference/get_team.md)
  — team and channel discovery.
- [`add_user_to_channel()`](https://greengrassblueocean.github.io/MattermostR/reference/add_user_to_channel.md)
  — add a user to a channel.
- [`get_me()`](https://greengrassblueocean.github.io/MattermostR/reference/get_me.md),
  [`get_user()`](https://greengrassblueocean.github.io/MattermostR/reference/get_user.md),
  [`get_all_users()`](https://greengrassblueocean.github.io/MattermostR/reference/get_all_users.md)
  — user lookups.
- [`search_posts()`](https://greengrassblueocean.github.io/MattermostR/reference/search_posts.md)
  — search message history with filtering by channel, user, and date.
- [`get_channel_posts()`](https://greengrassblueocean.github.io/MattermostR/reference/get_channel_posts.md)
  — retrieve posts from a channel.
- [`delete_post()`](https://greengrassblueocean.github.io/MattermostR/reference/delete_post.md),
  [`delete_old_messages()`](https://greengrassblueocean.github.io/MattermostR/reference/delete_old_messages.md)
  — post deletion.
- [`mattermost_api_request()`](https://greengrassblueocean.github.io/MattermostR/reference/mattermost_api_request.md)
  — low-level HTTP handler.
- [`check_mattermost_status()`](https://greengrassblueocean.github.io/MattermostR/reference/check_mattermost_status.md)
  — server health check.
