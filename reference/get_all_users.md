# Get all known Mattermost users

Retrieves a list of user IDs for users known to the authenticated user's
server. The exact format depends on the Mattermost API version;
typically a character vector of user IDs.

## Usage

``` r
get_all_users(verbose = FALSE, auth = get_default_auth())
```

## Arguments

- verbose:

  (Logical) If \`TRUE\`, detailed information about the request and
  response will be printed. Default is \`FALSE\`.

- auth:

  The authentication object created by \[authenticate_mattermost()\].

## Value

A character vector of user IDs, or a list depending on the Mattermost
API response.

## Examples

``` r
if (FALSE) { # \dontrun{
  get_all_users()
} # }
```
