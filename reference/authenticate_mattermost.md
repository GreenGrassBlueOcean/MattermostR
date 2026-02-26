# Authenticate with Mattermost API

Creates a `mattermost_auth` object for use with all MattermostR
functions.

## Usage

``` r
authenticate_mattermost(
  base_url,
  token = NULL,
  username = NULL,
  password = NULL,
  test_connection = FALSE,
  cache_credentials = TRUE
)
```

## Arguments

- base_url:

  The base URL of the Mattermost server. Do not add the team name here
  so really only "https://yourmattermost.stackhero-network.com/"

- token:

  Optional. The Bearer token for authentication. If NULL, resolved from
  `MATTERMOST_TOKEN` env var, then `options("mattermost.token")`.

- username:

  Optional. The username for login if not using a token.

- password:

  Optional. The password for login if not using a token.

- test_connection:

  Boolean. If \`TRUE\`, the function will check the connection status
  with Mattermost.

- cache_credentials:

  Boolean. If \`TRUE\` (default), stores the token and base URL in R
  [`options()`](https://rdrr.io/r/base/options.html) so that subsequent
  calls can use `get_default_auth()`. Set to `FALSE` in shared
  environments to avoid exposing the token in session state.

## Value

A \`mattermost_auth\` object containing \`base_url\` and \`headers\` for
further API calls.

## Credential Resolution

When `token` or `base_url` are not supplied as arguments, the function
looks for them in two places, in order:

1.  **Environment variables** — `MATTERMOST_TOKEN` and `MATTERMOST_URL`.

2.  **R options** — `mattermost.token` and `mattermost.base_url`.

Environment variables are the recommended approach in shared or
production environments (e.g. RStudio Server, Posit Workbench) because
they are not visible to other code running in the same R session.

## Security

By default (`cache_credentials = TRUE`), the resolved token and URL are
stored in R [`options()`](https://rdrr.io/r/base/options.html) for
convenience. In shared environments, set `cache_credentials = FALSE` and
pass the returned auth object explicitly, or use
[`clear_mattermost_credentials()`](https://greengrassblueocean.github.io/MattermostR/reference/clear_mattermost_credentials.md)
when done.

## Examples

``` r
if (FALSE) { # \dontrun{
# Token-based (caches by default)
authenticate_mattermost(base_url = "https://mattermost.stackhero-network.com"
, token = "your token", test_connection = TRUE)

# Secure: don't cache in options, rely on env vars for subsequent calls
auth <- authenticate_mattermost(
  base_url = "https://mm.example.com",
  token = Sys.getenv("MATTERMOST_TOKEN"),
  cache_credentials = FALSE
)
} # }
```
