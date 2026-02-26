# List all teams in Mattermost

List all teams in Mattermost

## Usage

``` r
get_all_teams(verbose = FALSE, auth = get_default_auth())
```

## Arguments

- verbose:

  (Logical) If \`TRUE\`, detailed information about the request and
  response will be printed. Default is \`FALSE\`.

- auth:

  The authentication object created by \[authenticate_mattermost()\].

## Value

A data frame with one row per team (columns include \`id\`,
\`display_name\`, \`name\`, \`type\`, etc.). Returns an empty data frame
/ list if the user belongs to no teams (with a warning).

## Examples

``` r
if (FALSE) { # \dontrun{
teams <- get_all_teams()
} # }
```
