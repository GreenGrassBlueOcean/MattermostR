# List bot accounts

Retrieve a paginated list of bots on the server.

## Usage

``` r
get_bots(
  page = 0,
  per_page = 60,
  include_deleted = FALSE,
  only_orphaned = FALSE,
  verbose = FALSE,
  auth = get_default_auth()
)
```

## Arguments

- page:

  Integer. Zero-based page number. Default \`0\`.

- per_page:

  Integer. Number of bots per page. Default \`60\`. Maximum \`200\`.

- include_deleted:

  Logical. If \`TRUE\`, include disabled (deleted) bots in the results.
  Default \`FALSE\`.

- only_orphaned:

  Logical. If \`TRUE\`, return only orphaned bots (bots whose owner has
  been deactivated). Default \`FALSE\`.

- verbose:

  Logical. Print detailed request information? Default \`FALSE\`.

- auth:

  A \`mattermost_auth\` object created by \[authenticate_mattermost()\].
  Defaults to \[get_default_auth()\].

## Value

A data frame of bots with columns such as \`user_id\`, \`username\`,
\`display_name\`, \`description\`, \`owner_id\`, \`create_at\`,
\`update_at\`, and \`delete_at\`.

## Permissions

Must have \`read_bots\` permission for bots you own, or
\`read_others_bots\` for bots owned by other users.

## See also

\[get_bot()\], \[create_bot()\]

## Examples

``` r
if (FALSE) { # \dontrun{
  bots <- get_bots()
  nrow(bots)

  # Only orphaned bots
  orphaned <- get_bots(only_orphaned = TRUE)

  # Page through results
  page2 <- get_bots(page = 1, per_page = 100)
} # }
```
