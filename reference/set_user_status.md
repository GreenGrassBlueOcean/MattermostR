# Set user online status

Manually set a user's status. When setting a user's status to anything
other than \`"online"\`, the status remains fixed until explicitly set
back to \`"online"\`, at which point automatic activity-based updates
resume.

## Usage

``` r
set_user_status(
  user_id,
  status,
  dnd_end_time = NULL,
  verbose = FALSE,
  auth = get_default_auth()
)
```

## Arguments

- user_id:

  Character. The user ID to update.

- status:

  Character. One of \`"online"\`, \`"away"\`, \`"offline"\`, or
  \`"dnd"\`. Case-insensitive.

- dnd_end_time:

  Optional integer. Unix epoch timestamp (seconds) at which DND status
  should automatically expire. Only meaningful when \`status = "dnd"\`.
  A warning is issued if provided for other statuses.

- verbose:

  Logical. Print detailed request information? Default \`FALSE\`.

- auth:

  A \`mattermost_auth\` object created by \[authenticate_mattermost()\].
  Defaults to \[get_default_auth()\].

## Value

A named list with the updated status object (same schema as
\[get_user_status()\]).

## Permissions

Must have \`edit_other_users\` permission for the team to set another
user's status.

## Examples

``` r
if (FALSE) { # \dontrun{
  set_user_status("user123", "dnd",
                  dnd_end_time = as.integer(Sys.time()) + 3600)

  set_user_status("user123", "online")
} # }
```
