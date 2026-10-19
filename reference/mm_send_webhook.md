# Send a Message via a Mattermost Incoming Webhook (Alias)

Alias for
[`send_webhook_message`](https://greengrassblueocean.github.io/MattermostR/reference/send_webhook_message.md)
providing a consistent `mm_*` prefix alongside
[`mm_get_channel_posts`](https://greengrassblueocean.github.io/MattermostR/reference/mm_get_channel_posts.md).

## Usage

``` r
mm_send_webhook(
  webhook_url,
  text = NULL,
  channel = NULL,
  username = NULL,
  icon_url = NULL,
  icon_emoji = NULL,
  attachments = NULL,
  props = NULL,
  priority = NULL,
  timeout = 10,
  max_tries = 3
)
```

## Arguments

- webhook_url:

  The full incoming webhook URL (e.g.
  `"https://mattermost.example.com/hooks/xxx-generatedkey-xxx"`). Treat
  this as a secret.

- text:

  Markdown-formatted message text. Required unless `attachments` is
  provided.

- channel:

  Optional. Override the channel the message posts in. Use the channel's
  short name (e.g. `"town-square"`), not the display name. Use
  `"@username"` to send a direct message.

- username:

  Optional. Override the username the message posts as. Requires the
  server setting *Enable integrations to override usernames* to be
  enabled.

- icon_url:

  Optional. Override the profile picture with an image URL. Requires the
  server setting *Enable integrations to override profile picture icons*
  to be enabled.

- icon_emoji:

  Optional. Override the profile picture with an emoji (e.g.
  `":robot:"`). Takes precedence over `icon_url`.

- attachments:

  Optional. A list of [message
  attachment](https://developers.mattermost.com/integrate/reference/message-attachments/)
  objects for richer formatting. Required if `text` is not provided.

- props:

  Optional. A named list of extra properties for the post. Supports the
  `card` key for additional Markdown shown in the right-hand side panel.

- priority:

  Optional. A list specifying message priority (e.g.
  `list(priority = "important")`).

- timeout:

  Numeric. Request timeout in seconds (default `10`).

- max_tries:

  Integer. Maximum number of retry attempts on transient HTTP failures
  (default `3`).

## Value

The `httr2` response object, returned invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
mm_send_webhook(
  webhook_url = "https://mattermost.example.com/hooks/xxx-generatedkey-xxx",
  text = "Hello from MattermostR!"
)
} # }
```
