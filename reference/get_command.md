# Get a slash command

Retrieve a command definition by its ID.

## Usage

``` r
get_command(command_id, verbose = FALSE, auth = get_default_auth())
```

## Arguments

- command_id:

  Character. The command ID.

- verbose:

  Logical. Print detailed request information? Default \`FALSE\`.

- auth:

  A \`mattermost_auth\` object created by \[authenticate_mattermost()\].
  Defaults to \[get_default_auth()\].

## Value

A named list representing the command (same schema as
\[create_command()\]).

## Permissions

Must have \`manage_slash_commands\` permission for the team the command
belongs to.

## See also

\[list_commands()\], \[create_command()\]

## Examples

``` r
if (FALSE) { # \dontrun{
  cmd <- get_command("cmd_id_abc")
  cmd$trigger
} # }
```
