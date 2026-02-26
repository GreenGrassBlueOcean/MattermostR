# Execute a slash command

Programmatically execute a slash command in a channel, as if a user had
typed it. The command string should include the leading \`/\`.

## Usage

``` r
execute_command(
  channel_id,
  command,
  verbose = FALSE,
  auth = get_default_auth()
)
```

## Arguments

- channel_id:

  Character. The channel ID where the command will execute.

- command:

  Character. The full slash command string including the leading \`/\`
  and any arguments (e.g., \`"/pnl AAPL"\`).

- verbose:

  Logical. Print detailed request information? Default \`FALSE\`.

- auth:

  A \`mattermost_auth\` object created by \[authenticate_mattermost()\].
  Defaults to \[get_default_auth()\].

## Value

A named list representing the command response, with fields
\`ResponseType\` (\`"in_channel"\` or \`"ephemeral"\`), \`Text\`,
\`Username\`, \`IconURL\`, \`GotoLocation\`, and \`Attachments\`.

## Permissions

Must have \`use_slash_commands\` permission for the team.

## See also

\[create_command()\], \[list_commands()\]

## Examples

``` r
if (FALSE) { # \dontrun{
  resp <- execute_command("channel123", "/pnl AAPL")
  resp$Text
} # }
```
