# Get information about a specific Mattermost user

Get information about a specific Mattermost user

## Usage

``` r
get_all_users(verbose = FALSE, auth = authenticate_mattermost())
```

## Arguments

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
 get_all_users()
} # }
```
