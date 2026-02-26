# Get information about a specific Mattermost user

\`r lifecycle::badge("deprecated")\`

\`get_user_info()\` was renamed to \[get_user()\] in MattermostR 0.2.0
to provide a more consistent API. It will be removed in a future
release.

## Usage

``` r
get_user_info(user_id = NULL, auth = get_default_auth())
```

## Arguments

- user_id:

  A character string containing the Mattermost user ID, or \`"me"\` for
  the authenticated user.

- auth:

  The authentication object created by \[authenticate_mattermost()\].

## Value

A named list with user fields returned by the Mattermost API (e.g.
\`id\`, \`username\`, \`email\`, \`roles\`).

## Examples

``` r
if (FALSE) { # \dontrun{
  # Prefer get_user() instead:
  user <- get_user("xb123abc456...")
} # }
```
