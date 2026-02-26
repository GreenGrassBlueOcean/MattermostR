# MattermostR 0.2.0

## New functions

### Messaging
- `send_webhook_message()` — send messages via incoming webhooks (no auth required).
- `update_post()` — edit an existing post's message text, pinned state, or props.
- `delete_old_messages()` now auto-paginates via an internal helper; no manual looping needed.

### Posts, reactions & pins
- `add_reaction()`, `get_reactions()`, `remove_reaction()` — emoji reactions on posts.
- `pin_post()`, `unpin_post()` — semantic pin/unpin using the dedicated API endpoints.
- `get_channel_posts()` gains `page`, `per_page`, and `since` parameters with pagination support.

### Channels
- `create_direct_channel()` — creates a DM (2 user IDs) or group message channel (3–8 user IDs).
- `get_channel_members()` — paginated retrieval of channel membership.
- `remove_channel_member()` — remove a user from a channel.
- `add_users_to_channel()` — batch-add up to 1000 users in a single API call.
- `add_user_to_channel()` gains a `resolve_names` parameter (default `TRUE`).

### Users
- `get_user_status()`, `set_user_status()` — read and set online/away/offline/DND status, with DND end-time support.

### Bots
- `create_bot()`, `get_bot()`, `get_bots()`, `update_bot()`, `disable_bot()`, `enable_bot()`, `assign_bot()` — full bot account management.

### Slash commands
- `create_command()`, `get_command()`, `list_commands()`, `update_command()`, `delete_command()`, `execute_command()`, `regen_command_token()` — full slash command lifecycle.

## Improvements

- Thread replies: `send_mattermost_message()` gains a `root_id` parameter for posting into threads.
- Message priority: priority is now passed under `metadata$priority` (the correct API location). Valid values are `"Normal"` (default), `"Important"`, and `"Urgent"`. The old undocumented `"High"` / `"Low"` values have been removed.
- `send_mattermost_file()` now delegates to `mattermost_api_request()` with `multipart = TRUE`, gaining retry/backoff, error handling, and verbose support.
- Rate limiting: proactive throttling at 10 req/s via `req_throttle()`. Reactive 429 handling reads `X-Ratelimit-Reset` for precise wait timing. Override with `options(MattermostR.rate_limit = Inf)`.
- Structured error conditions: HTTP errors now raise a `mattermost_error` S3 condition. Set `options(MattermostR.on_error = "message")` for legacy `NULL`-return behaviour.
- `get_default_auth()` and `authenticate_mattermost()` now resolve credentials from environment variables (`MATTERMOST_TOKEN`, `MATTERMOST_URL`) before R options, in both functions.
- `authenticate_mattermost()` gains `cache_credentials = FALSE` to prevent storing the token in `options()`. `clear_mattermost_credentials()` wipes cached credentials.
- `print.mattermost_auth()` masks the bearer token in console output.
- `paginate_api()` internal helper auto-paginates any GET endpoint that supports `page`/`per_page`. Used by `get_all_teams()`, `get_team_channels()`, and post-retrieval.
- `get_user_info()` is now deprecated in favour of `get_user()` (emits a `lifecycle` warning).
- `get_me()` now defaults to `verbose = FALSE`, consistent with all other functions.
- `check_not_null()` rewritten to handle vector inputs safely.

## Bug fixes

- Username/password login rewritten to use `httr2` directly, fixing broken authentication flow.
- `get_channel_posts()` previously returned only the first page; now fully paginated.

---

# MattermostR 0.1.0

- Initial release.
- `authenticate_mattermost()` — token-based and username/password authentication.
- `send_mattermost_message()` — send messages with optional file and plot attachments.
- `send_mattermost_file()` — upload files to a channel.
- `get_mattermost_file()` — download files from Mattermost.
- `create_channel()`, `delete_channel()` — channel management.
- `get_channel_info()`, `get_channel_id_lookup()` — channel lookup helpers.
- `get_team_channels()`, `get_all_teams()`, `get_team()` — team and channel discovery.
- `add_user_to_channel()` — add a user to a channel.
- `get_me()`, `get_user()`, `get_all_users()` — user lookups.
- `search_posts()` — search message history with filtering by channel, user, and date.
- `get_channel_posts()` — retrieve posts from a channel.
- `delete_post()`, `delete_old_messages()` — post deletion.
- `mattermost_api_request()` — low-level HTTP handler.
- `check_mattermost_status()` — server health check.
