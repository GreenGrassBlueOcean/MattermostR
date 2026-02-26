# Send a Message via a Mattermost Incoming Webhook

Posts a message to Mattermost using an incoming webhook URL. Incoming
webhooks are simpler than bot-token authentication — no `auth` object is
needed. The webhook URL itself acts as the credential.

## Usage

``` r
send_webhook_message(
  webhook_url,
  text = NULL,
  channel = NULL,
  username = NULL,
  icon_url = NULL,
  icon_emoji = NULL,
  attachments = NULL,
  props = NULL,
  priority = NULL
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

## Value

The `httr2` response object, returned invisibly. A successful request
returns HTTP 200 with body `"ok"`.

## Details

Incoming webhooks must be enabled on the Mattermost server (**System
Console \> Integrations \> Integration Management**). The webhook URL is
created via **Product menu \> Integrations \> Incoming Webhook** in
Mattermost.

The request is retried up to 3 times on transient failures.

## Examples

``` r
if (FALSE) { # \dontrun{
# Simple text message
send_webhook_message(
  webhook_url = "https://mattermost.example.com/hooks/xxx-generatedkey-xxx",
  text = "Hello from R!"
)

# Override channel and username
send_webhook_message(
  webhook_url = "https://mattermost.example.com/hooks/xxx-generatedkey-xxx",
  text = "Build passed :white_check_mark:",
  channel = "ci-notifications",
  username = "CI Bot",
  icon_emoji = ":robot:"
)

# Rich attachment without text
send_webhook_message(
  webhook_url = "https://mattermost.example.com/hooks/xxx-generatedkey-xxx",
  attachments = list(
    list(
      title = "Trade Alert",
      text = "AAPL filled at $185.50",
      color = "#00FF00"
    )
  )
)

# Direct message via webhook
send_webhook_message(
  webhook_url = "https://mattermost.example.com/hooks/xxx-generatedkey-xxx",
  text = "Private notification for you.",
  channel = "@jsmith"
)
} # }
```
