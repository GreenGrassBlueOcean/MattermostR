# Get user online status

Retrieve the current status of a user (online, away, offline, or dnd).

## Usage

``` r
get_user_status(user_id, verbose = FALSE, auth = get_default_auth())
```

## Arguments

- user_id:

  Character. The user ID to query. The API also accepts \`"me"\` to
  refer to the authenticated user.

- verbose:

  Logical. Print detailed request information? Default \`FALSE\`.

- auth:

  A \`mattermost_auth\` object created by \[authenticate_mattermost()\].
  Defaults to \[get_default_auth()\].

## Value

A named list with fields \`user_id\`, \`status\`, \`manual\`,
\`last_activity_at\`, and \`active_channel\`.

## Permissions

Must be authenticated.

## Examples

``` r
if (FALSE) { # \dontrun{
  status <- get_user_status("user123")
  status$status
  # "online", "away", "offline", or "dnd"

  # Use "me" for the authenticated user
  my_status <- get_user_status("me")
} # }
```
