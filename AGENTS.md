# MattermostR — Agent Memory

This file provides quick-start context for AI assistants working in this repository.

## What This Is

**MattermostR** is an R package (v0.1.0) wrapping the Mattermost REST API v4.
It provides R-native functions for messaging, file management, channel operations,
team administration, and search.

- **Repo**: [GreenGrassBlueOcean/MattermostR](https://github.com/GreenGrassBlueOcean/MattermostR)
- **Docs**: <https://greengrassblueocean.github.io/MattermostR/>
- **License**: MIT | **R**: >= 4.1.0

---

## Key Files

| File | Purpose |
|------|---------|
| `R/authenticate.R` | Authentication — token-based and username/password, plus `get_default_auth()` helper |
| `R/mattermost_api_request.R` | Core HTTP handler — all user functions route through here |
| `R/handle_http_error.R` | `mattermost_error` condition class, `raise_mattermost_error()`, `handle_http_error()` |
| `R/send_message.R` | `send_mattermost_message()` + `normalize_priority()` + `root_id` thread replies |
| `R/send_mattermost_message_helper_functions.R` | Plot save/upload pipeline |
| `R/send_mattermost_file.R` | File upload — delegates to `mattermost_api_request()` with `multipart = TRUE` |
| `R/add_user_to_channel.R` | `add_user_to_channel()` + `add_users_to_channel()` (batch, up to 1000) |
| `R/create_direct_channel.R` | `create_direct_channel()` — DM (2 IDs) or group message (3–8 IDs) channels |
| `R/update_post.R` | `update_post()` — patch a post's message, is_pinned, or props |
| `R/reactions.R` | `add_reaction()`, `get_reactions()`, `remove_reaction()` — emoji reactions on posts |
| `R/send_webhook_message.R` | `send_webhook_message()` — incoming webhook support, no auth needed |
| `R/user_status.R` | `get_user_status()` + `set_user_status()` — online/away/offline/dnd status |
| `R/pin_posts.R` | `pin_post()` + `unpin_post()` — semantic pin/unpin endpoints |
| `R/channel_members.R` | `get_channel_members()` + `remove_channel_member()` — channel membership |
| `R/bots.R` | `create_bot()`, `get_bot()`, `get_bots()`, `update_bot()`, `disable_bot()`, `enable_bot()`, `assign_bot()` — bot account management |
| `R/commands.R` | `create_command()`, `get_command()`, `list_commands()`, `update_command()`, `delete_command()`, `execute_command()`, `regen_command_token()` — slash commands |
| `R/get_channel_posts.R` | Posts → data.frame; paginated via `page`/`per_page`/`since` |
| `R/paginate_api.R` | Internal `paginate_api()` — auto-pagination for GET endpoints with `page`/`per_page` |
| `R/utils.R` | `check_not_null()` input validation |
| `tests/testthat/helper.R` | `mock_auth_helper()`, `mock_api_request_helper()`, `sub_everything()` |

---

## How to Load / Test

```r
devtools::load_all(".")          # Load package in development
devtools::test()                 # Run full test suite (784 tests, 100% coverage)
devtools::document()             # Regenerate roxygen docs
```

Tests use `mockery` (function stubs) and `httptest2` (recorded HTTP responses).
No live Mattermost server is needed.

---

## Data / Auth Model

- Auth is an S3 object of class `mattermost_auth` with fields `base_url` and `headers`.
- `print.mattermost_auth()` masks the bearer token in console output (shows first 4 + last 4 chars).
- Every exported function accepts `auth = get_default_auth()` as a default.
- **Credential resolution order** (both in `authenticate_mattermost()` and `get_default_auth()`):
  1. Environment variables: `MATTERMOST_TOKEN` and `MATTERMOST_URL`
  2. R options: `mattermost.token` and `mattermost.base_url`
- `authenticate_mattermost(cache_credentials = TRUE)` (default) stores token/URL in `options()` for convenience. Set `cache_credentials = FALSE` in shared environments to keep the token out of session state.
- `clear_mattermost_credentials()` wipes `options()` after use.
- Internal helper `resolve_credential(env_var, option_name)` implements the env-then-option lookup.
- Mock auth for tests: `structure(list(base_url = "https://mock.mattermost.com", headers = "Bearer mock_token"), class = "mattermost_auth")`

---

## Priority Values (as of fix applied Feb 2026)

`send_mattermost_message()` accepts `priority = "Normal"` (default), `"Important"`, or `"Urgent"`.

- Priority is passed under **`body$metadata$priority$priority`** (not `body$props`).
- API values: `""` = normal (omitted), `"important"`, `"urgent"`.
- `normalize_priority()` is case-insensitive: `"URGENT"`, `"urgent"`, `"Urgent"` all work.
- **Old values `"High"` and `"Low"` were removed** — they were never functional on the server.

---

## Known Bugs (open as of Feb 2026)

| # | Severity | Description |
|---|----------|-------------|
| 1.1 | ~~P0~~ **Fixed** | Priority moved from `props` to `metadata`; "Low"/"High" replaced with "Important"/"Urgent" |
| 1.2 | ~~P0~~ **Fixed** | Username/password login rewritten — uses `httr2` directly via `perform_login_request()`, bypasses `mattermost_api_request()` |
| 1.3 | ~~P0~~ **Fixed** | `send_mattermost_file()` rewritten to delegate to `mattermost_api_request()` with `multipart = TRUE` — now has retry/backoff, error handling, and verbose support |
| 1.4 | ~~P0~~ **Fixed** | `get_channel_posts()` now has `page`, `per_page`, and `since` params with pagination-limit warning |
| 1.5 | ~~P1~~ **Fixed** | `delete_old_messages()` now auto-paginates via `get_all_channel_posts()` helper (200 per page) |
| 1.6 | ~~P1~~ **Fixed** | `check_not_null()` rewritten to handle vectors safely — no more `nzchar()` warning |
| 1.7 | ~~P1~~ **Fixed** | `get_me()` now defaults to `verbose = FALSE`, consistent with all other functions |
| 2.3 | ~~P1~~ **Fixed** | Bearer token no longer cached in `options()` by default path; env vars (`MATTERMOST_TOKEN`/`MATTERMOST_URL`) preferred; `cache_credentials = FALSE` + `clear_mattermost_credentials()` added |
| 2.4 | ~~P2~~ **Fixed** | Rate limit awareness: proactive throttling (10 req/s default) + reactive 429 handling via `X-Ratelimit-Reset` header |
| 2.5 | ~~P2~~ **Fixed** | `get_user_info()` deprecated via `lifecycle::deprecate_warn()`, now a thin alias for `get_user()`. Internal callers migrated. |
| 2.6 | ~~P2~~ **Fixed** | Return type docs corrected across all exported functions. Array endpoints → data.frame, single-object endpoints → list. |
| 2.7 | ~~P2~~ **Fixed** | `add_user_to_channel()` now has `resolve_names` param (default `TRUE`). New `add_users_to_channel()` batch function uses `user_ids` array (max 1000, single POST). |

---

## Design Notes

- **`mattermost_api_request()`** is the only function that touches `httr2` directly (except `perform_login_request()` for login). All user functions delegate to it.
- Rate limiting: proactive throttle at `getOption("MattermostR.rate_limit", 10)` req/s via `req_throttle()`. Set to `Inf` to disable. On 429 responses, `mm_after()` reads `X-Ratelimit-Reset` for precise wait timing.
- Retry: up to 5 attempts, exponential backoff `0.5 * 2^(attempt-1)` seconds.
- On HTTP error, functions raise a `mattermost_error` condition by default. Set `options(MattermostR.on_error = "message")` for legacy `NULL`-return behaviour.
- `get_user_info()` is a deprecated alias for `get_user()` (emits `lifecycle::deprecate_warn()`).
- **Return type convention**: array endpoints return data frames (via `simplifyVector = TRUE`), single-object endpoints return named lists. Post-processing functions (`get_channel_posts()`, `search_posts()`) always return data frames.
- `add_user_to_channel()` supports `resolve_names = FALSE` to skip display-only lookups (1 API call instead of 3).
- `add_users_to_channel()` is the batch variant — uses `user_ids` array (max 1000), single POST. With `resolve_names = TRUE`, uses batch `POST /api/v4/users/ids` (always 3 calls total).
- **`paginate_api()`** is the internal auto-pagination helper. Iterates `page`/`per_page` query params (max 200/page). Accepts optional `transform` callback for nested responses (e.g. posts endpoint). Used by `get_all_teams()`, `get_team_channels()`, and `get_all_channel_posts()`.

---

## Planned / Proposed Extensions (from analysis.md)

High-value work not yet implemented:

| Priority | Feature | Notes |
|----------|---------|-------|
| ~~P1~~ | ~~`root_id` for thread replies~~ | **Done** — `root_id` param on `send_mattermost_message()` |
| ~~P1~~ | ~~Incoming webhook support~~ | **Done** — `send_webhook_message()`, no auth needed, direct `httr2` with 3 retries |
| ~~P1~~ | ~~Structured error conditions~~ | **Done** — `mattermost_error` S3 condition class + `options(MattermostR.on_error)` toggle |
| ~~P1~~ | ~~`get_channel_posts()` pagination~~ | **Done** — `page`/`per_page`/`since` params added |
| ~~P2~~ | ~~`update_post()` — edit messages~~ | **Done** — `update_post()` with `message`, `is_pinned`, `props` fields |
| ~~P2~~ | ~~Direct / group messages~~ | **Done** — `create_direct_channel()`: 2 IDs → DM, 3–8 IDs → group |
| ~~P2~~ | ~~Reactions API~~ | **Done** — `add_reaction()`, `get_reactions()`, `remove_reaction()` |
| ~~P2~~ | ~~Pagination helper~~ | **Done** — `paginate_api()` with `transform` callback; `get_all_teams()` and `get_team_channels()` now auto-paginate |
| ~~P3~~ | ~~User status~~ | **Done** — `get_user_status()`, `set_user_status()` with DND end-time support |
| ~~P3~~ | ~~Pin posts~~ | **Done** — `pin_post()`, `unpin_post()` semantic endpoints |
| ~~P3~~ | ~~Channel members~~ | **Done** — `get_channel_members()` (paginated), `remove_channel_member()` |
| ~~P3~~ | ~~Bot accounts~~ | **Done** — `create_bot()`, `get_bot()`, `get_bots()`, `update_bot()`, `disable_bot()`, `enable_bot()`, `assign_bot()` |
| ~~P3~~ | ~~Slash commands~~ | **Done** — `create_command()`, `get_command()`, `list_commands()`, `update_command()`, `delete_command()`, `execute_command()`, `regen_command_token()` |
