# Assign a bot to a different owner

Transfer ownership of a bot to another user. The new owner will be able
to manage the bot's settings and access tokens.

## Usage

``` r
assign_bot(bot_user_id, user_id, verbose = FALSE, auth = get_default_auth())
```

## Arguments

- bot_user_id:

  Character. The bot's user ID.

- user_id:

  Character. The user ID of the new owner.

- verbose:

  Logical. Print detailed request information? Default \`FALSE\`.

- auth:

  A \`mattermost_auth\` object created by \[authenticate_mattermost()\].
  Defaults to \[get_default_auth()\].

## Value

A named list representing the bot with updated ownership (same schema as
\[create_bot()\]).

## Permissions

Must have \`manage_bots\` permission for bots you own, or
\`manage_others_bots\` for bots owned by other users.

## See also

\[create_bot()\], \[get_bot()\]

## Examples

``` r
if (FALSE) { # \dontrun{
  assign_bot("bot_user_id_abc", "new_owner_user_id")
} # }
```
