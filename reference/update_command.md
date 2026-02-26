# Update a slash command

Update a command definition. The request body should be a complete
Command object (the API replaces the entire definition).

## Usage

``` r
update_command(command_id, body, verbose = FALSE, auth = get_default_auth())
```

## Arguments

- command_id:

  Character. The command ID to update.

- body:

  Named list. The full Command object with updated fields. Must include
  required fields like \`id\`, \`team_id\`, \`trigger\`, \`url\`, and
  \`method\`.

- verbose:

  Logical. Print detailed request information? Default \`FALSE\`.

- auth:

  A \`mattermost_auth\` object created by \[authenticate_mattermost()\].
  Defaults to \[get_default_auth()\].

## Value

A named list representing the updated command (same schema as
\[create_command()\]).

## Permissions

Must have \`manage_slash_commands\` permission for the team the command
belongs to.

## See also

\[get_command()\], \[create_command()\], \[delete_command()\]

## Examples

``` r
if (FALSE) { # \dontrun{
  cmd <- get_command("cmd_id_abc")
  cmd$description <- "Updated description"
  update_command("cmd_id_abc", body = cmd)
} # }
```
