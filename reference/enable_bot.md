# Enable a bot account

Re-enable a previously disabled bot so it can post and respond again.

## Usage

``` r
enable_bot(bot_user_id, verbose = FALSE, auth = get_default_auth())
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

A named list representing the enabled bot (same schema as
\[create_bot()\]).

## Permissions

Must have \`manage_bots\` permission for bots you own, or
\`manage_others_bots\` for bots owned by other users.

## See also

\[disable_bot()\], \[get_bot()\]

## Examples

``` r
if (FALSE) { # \dontrun{
  enable_bot("bot_user_id_abc")
} # }
```
