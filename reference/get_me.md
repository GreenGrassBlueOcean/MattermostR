# Get information about which user is belonging to bearer key,

Get information about which user is belonging to bearer key,

## Usage

``` r
get_me(verbose = FALSE, auth = get_default_auth())
```

## Arguments

- verbose:

  (Logical) If \`TRUE\`, detailed information about the request and
  response will be printed.

- auth:

  The authentication object created by \`authenticate_mattermost()\`.

## Value

a list with user information for the authentication key

## Examples

``` r
if (FALSE) { # \dontrun{
 get_me()
} # }
```
