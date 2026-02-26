# Disable a bot account

Disable (soft-delete) a bot. The bot will no longer be able to post or
respond, but can be re-enabled with \[enable_bot()\].

## Usage

``` r
disable_bot(bot_user_id, verbose = FALSE, auth = get_default_auth())
```

## Arguments

- bot_user_id:

  Character. The bot's user ID.

- verbose:

  Logical. Print detailed request information? Default \`FALSE\`.

- auth:

  A \`mattermost_auth\` object created by \[authenticate_mattermost()\].
  Defaults to \[get_default_auth()\].

## Value

A named list representing the disabled bot (same schema as
\[create_bot()\]).

## Permissions

Must have \`manage_bots\` permission for bots you own, or
\`manage_others_bots\` for bots owned by other users.

## See also

\[enable_bot()\], \[get_bot()\]

## Examples

``` r
if (FALSE) { # \dontrun{
  disable_bot("bot_user_id_abc")
} # }
```
