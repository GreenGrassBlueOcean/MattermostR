# Get a bot account

Retrieve a bot by its bot user ID.

## Usage

``` r
get_bot(
  bot_user_id,
  include_deleted = FALSE,
  verbose = FALSE,
  auth = get_default_auth()
)
```

## Arguments

- bot_user_id:

  Character. The bot's user ID.

- include_deleted:

  Logical. If \`TRUE\`, return the bot even if it has been disabled
  (deleted). Default \`FALSE\`.

- verbose:

  Logical. Print detailed request information? Default \`FALSE\`.

- auth:

  A \`mattermost_auth\` object created by \[authenticate_mattermost()\].
  Defaults to \[get_default_auth()\].

## Value

A named list representing the bot (same schema as \[create_bot()\]).

## Permissions

Must have \`read_bots\` permission for bots you own, or
\`read_others_bots\` for bots owned by other users.

## See also

\[get_bots()\], \[create_bot()\]

## Examples

``` r
if (FALSE) { # \dontrun{
  bot <- get_bot("bot_user_id_abc")
  bot$username

  # Include disabled bots
  bot <- get_bot("bot_user_id_abc", include_deleted = TRUE)
} # }
```
