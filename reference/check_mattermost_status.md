# Check if the Mattermost server is online

Check if the Mattermost server is online

## Usage

``` r
check_mattermost_status(verbose = FALSE, auth = get_default_auth())
```

## Arguments

- verbose:

  Boolean. If \`TRUE\`, the function will print request/response details
  for more information.

- auth:

  A list containing \`base_url\` and \`headers\` for authentication.

## Value

TRUE if the server is online; FALSE otherwise.

## Examples

``` r
if (FALSE) { # \dontrun{
check_mattermost_status()
} # }
```
