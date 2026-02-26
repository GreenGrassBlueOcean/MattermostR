# Regenerate a command token

Generate a new verification token for a slash command. The old token is
immediately invalidated.

## Usage

``` r
regen_command_token(command_id, verbose = FALSE, auth = get_default_auth())
```

## Arguments

- command_id:

  Character. The command ID to regenerate the token for.

- verbose:

  Logical. Print detailed request information? Default \`FALSE\`.

- auth:

  A \`mattermost_auth\` object created by \[authenticate_mattermost()\].
  Defaults to \[get_default_auth()\].

## Value

A named list with a single field \`token\` containing the new token.

## Permissions

Must have \`manage_slash_commands\` permission for the team the command
belongs to.

## See also

\[create_command()\], \[get_command()\]

## Examples

``` r
if (FALSE) { # \dontrun{
  new_token <- regen_command_token("cmd_id_abc")
  new_token$token
} # }
```
