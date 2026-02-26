# Update a bot account

Partially update a bot's username, display name, or description. Only
the provided fields are updated; omitted fields remain unchanged.

## Usage

``` r
update_bot(
  bot_user_id,
  username,
  display_name = NULL,
  description = NULL,
  verbose = FALSE,
  auth = get_default_auth()
)
```

## Arguments

- bot_user_id:

  Character. The bot's user ID.

- username:

  Character. Required. The new username for the bot.

- display_name:

  Character. Optional new display name.

- description:

  Character. Optional new description.

- verbose:

  Logical. Print detailed request information? Default \`FALSE\`.

- auth:

  A \`mattermost_auth\` object created by \[authenticate_mattermost()\].
  Defaults to \[get_default_auth()\].

## Value

A named list representing the updated bot (same schema as
\[create_bot()\]).

## Permissions

Must have \`manage_bots\` permission for bots you own, or
\`manage_others_bots\` for bots owned by other users.

## See also

\[create_bot()\], \[get_bot()\]

## Examples

``` r
if (FALSE) { # \dontrun{
  updated <- update_bot("bot_user_id_abc", username = "new-bot-name",
                        display_name = "New Display Name")
} # }
```
