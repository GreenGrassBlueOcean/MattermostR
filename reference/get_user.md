# Get information about a specific Mattermost user

Get information about a specific Mattermost user

## Usage

``` r
get_user(user_id = NULL, verbose = FALSE, auth = authenticate_mattermost())
```

## Arguments

- user_id:

  The ID of the post to delete.

- verbose:

  (Logical) If \`TRUE\`, detailed information about the request and
  response will be printed.

- auth:

  The authentication object created by \`authenticate_mattermost()\`.

## Value

a vector user_ids

## Examples

``` r
if (FALSE) { # \dontrun{
 users <- get_all_users()
 userinfo <- lapply(users, get_user)
} # }
```
