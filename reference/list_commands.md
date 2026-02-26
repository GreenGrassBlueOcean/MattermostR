# List slash commands for a team

Retrieve all commands for a team. By default, returns both system
commands and custom commands the user has access to.

## Usage

``` r
list_commands(
  team_id,
  custom_only = FALSE,
  verbose = FALSE,
  auth = get_default_auth()
)
```

## Arguments

- team_id:

  Character. The team ID to query.

- custom_only:

  Logical. If \`TRUE\`, return only custom commands. Default \`FALSE\`.

- verbose:

  Logical. Print detailed request information? Default \`FALSE\`.

- auth:

  A \`mattermost_auth\` object created by \[authenticate_mattermost()\].
  Defaults to \[get_default_auth()\].

## Value

A data frame of commands with columns such as \`id\`, \`token\`,
\`team_id\`, \`trigger\`, \`method\`, \`url\`, \`display_name\`,
\`description\`, \`creator_id\`, etc.

## Permissions

Must have \`manage_slash_commands\` permission to list custom commands.

## See also

\[get_command()\], \[create_command()\]

## Examples

``` r
if (FALSE) { # \dontrun{
  cmds <- list_commands("team123")
  nrow(cmds)

  # Only custom commands
  custom <- list_commands("team123", custom_only = TRUE)
} # }
```
