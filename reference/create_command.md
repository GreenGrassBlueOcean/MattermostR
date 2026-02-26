# Create a slash command

Register a custom slash command for a team. When a user types the
trigger word in Mattermost, the server sends a request to the specified
URL.

## Usage

``` r
create_command(
  team_id,
  trigger,
  url,
  method = c("P", "G"),
  auto_complete = FALSE,
  auto_complete_desc = NULL,
  auto_complete_hint = NULL,
  display_name = NULL,
  description = NULL,
  username = NULL,
  icon_url = NULL,
  verbose = FALSE,
  auth = get_default_auth()
)
```

## Arguments

- team_id:

  Character. The team ID where the command will be created.

- trigger:

  Character. The trigger word (without leading \`/\`). When a user types
  \`/\<trigger\>\`, the command fires.

- url:

  Character. The callback URL that receives the command payload.

- method:

  Character. HTTP method for the callback: \`"P"\` for POST, \`"G"\` for
  GET. Default \`"P"\`.

- auto_complete:

  Logical. Enable autocomplete for this command? Default \`FALSE\`.

- auto_complete_desc:

  Character. Optional description shown in autocomplete.

- auto_complete_hint:

  Character. Optional hint shown in autocomplete.

- display_name:

  Character. Optional display name for the command.

- description:

  Character. Optional description of the command.

- username:

  Character. Optional username override for the response post.

- icon_url:

  Character. Optional icon URL override for the response post.

- verbose:

  Logical. Print detailed request information? Default \`FALSE\`.

- auth:

  A \`mattermost_auth\` object created by \[authenticate_mattermost()\].
  Defaults to \[get_default_auth()\].

## Value

A named list representing the created command, with fields such as
\`id\`, \`token\`, \`team_id\`, \`trigger\`, \`method\`, \`url\`,
\`creator_id\`, \`create_at\`, \`update_at\`, \`delete_at\`,
\`display_name\`, \`description\`, \`username\`, \`icon_url\`,
\`auto_complete\`, \`auto_complete_desc\`, and \`auto_complete_hint\`.

## Permissions

Must have \`manage_slash_commands\` permission for the team.

## See also

\[get_command()\], \[list_commands()\], \[update_command()\],
\[delete_command()\], \[execute_command()\]

## Examples

``` r
if (FALSE) { # \dontrun{
  cmd <- create_command(
    team_id = "team123",
    trigger = "pnl",
    url     = "https://my-r-server.example.com/pnl",
    method  = "P",
    auto_complete      = TRUE,
    auto_complete_desc = "Show P&L for a ticker",
    auto_complete_hint = "[TICKER]"
  )
  cmd$id
  cmd$token
} # }
```
