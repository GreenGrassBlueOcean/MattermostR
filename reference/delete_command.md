# Delete a slash command

Delete a custom slash command by its ID.

## Usage

``` r
delete_command(command_id, verbose = FALSE, auth = get_default_auth())
```

## Arguments

- command_id:

  Character. The command ID to delete.

- verbose:

  Logical. Print detailed request information? Default \`FALSE\`.

- auth:

  A \`mattermost_auth\` object created by \[authenticate_mattermost()\].
  Defaults to \[get_default_auth()\].

## Value

A named list with \`status = "OK"\` on success.

## Permissions

Must have \`manage_slash_commands\` permission for the team the command
belongs to.

## See also

\[create_command()\], \[get_command()\]

## Examples

``` r
if (FALSE) { # \dontrun{
  delete_command("cmd_id_abc")
} # }
```
