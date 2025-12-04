# List all teams in Mattermost

List all teams in Mattermost

## Usage

``` r
get_all_teams(verbose = FALSE, auth = authenticate_mattermost())
```

## Arguments

- verbose:

  (Logical) If \`TRUE\`, detailed information about the request and
  response will be printed.

- auth:

  A list containing \`base_url\` and \`headers\` for authentication.

## Value

A data frame containing details of all teams.

## Examples

``` r
if (FALSE) { # \dontrun{
teams <- get_all_teams()
} # }
```
