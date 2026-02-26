# Create a bot account

Create a new bot account on the Mattermost server. The bot will be owned
by the authenticated user.

## Usage

``` r
create_bot(
  username,
  display_name = NULL,
  description = NULL,
  verbose = FALSE,
  auth = get_default_auth()
)
```

## Arguments

- username:

  Character. Required. The username for the bot. Must be unique across
  all users and bots on the server.

- display_name:

  Character. Optional display name for the bot.

- description:

  Character. Optional description of the bot.

- verbose:

  Logical. Print detailed request information? Default \`FALSE\`.

- auth:

  A \`mattermost_auth\` object created by \[authenticate_mattermost()\].
  Defaults to \[get_default_auth()\].

## Value

A named list representing the created bot, with fields \`user_id\`,
\`username\`, \`display_name\`, \`description\`, \`owner_id\`,
\`create_at\`, \`update_at\`, and \`delete_at\`.

## Permissions

Must have \`create_bot\` permission.

## See also

\[get_bot()\], \[get_bots()\], \[update_bot()\], \[disable_bot()\],
\[enable_bot()\], \[assign_bot()\]

## Examples

``` r
if (FALSE) { # \dontrun{
  bot <- create_bot("my-bot", display_name = "My Bot",
                    description = "Automated notifications")
  bot$user_id
} # }
```
