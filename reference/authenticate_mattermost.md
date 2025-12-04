# Authenticate with Mattermost API

Authenticate with Mattermost API

## Usage

``` r
authenticate_mattermost(
  base_url,
  token = NULL,
  username = NULL,
  password = NULL,
  test_connection = FALSE
)
```

## Arguments

- base_url:

  The base URL of the Mattermost server. Do not add the team name here
  so really only "https://yourmattermost.stackhero-network.com/"

- token:

  Optional. The Bearer token for authentication. If NULL, it will be
  retrieved from options().

- username:

  Optional. The username for login if not using a token.

- password:

  Optional. The password for login if not using a token.

- test_connection:

  Boolean. If \`TRUE\`, the function will check the connection status
  with Mattermost.

## Value

A \`mattermost_auth\` object containing \`base_url\` and \`headers\` for
further API calls.

## Examples

``` r
if (FALSE) { # \dontrun{
authenticate_mattermost(base_url = "https://mattermost.stackhero-network.com"
, token = "your token", test_connection = TRUE)
} # }
```
