# Get information about a specific Mattermost user

Retrieves detailed information about a user, such as their username,
email, roles, and ID. Use the special string \`"me"\` as \`user_id\` to
retrieve information about the currently authenticated user.

## Usage

``` r
get_user(user_id = NULL, verbose = FALSE, auth = get_default_auth())
```

## Arguments

- user_id:

  A character string containing the Mattermost user ID, or \`"me"\` for
  the authenticated user.

- verbose:

  (Logical) If \`TRUE\`, detailed information about the request and
  response will be printed. Default is \`FALSE\`.

- auth:

  The authentication object created by \[authenticate_mattermost()\].

## Value

A named list with user fields returned by the Mattermost API (e.g.
\`id\`, \`username\`, \`email\`, \`roles\`).

## Examples

``` r
if (FALSE) { # \dontrun{
  # Get info about a specific user by ID
  user <- get_user("xb123abc456...")

  # Get info about the current authenticated user
  myself <- get_user("me")
  print(myself$username)

  # Iterate over all known users
  users <- get_all_users()
  userinfo <- lapply(users, get_user)
} # }
```
