# Clear cached Mattermost credentials from R options

Removes `mattermost.token` and `mattermost.base_url` from the current
session's R options. Useful in shared environments where you want to
ensure the bearer token is not accessible after use.

## Usage

``` r
clear_mattermost_credentials()
```

## Value

`NULL`, invisibly.

## Details

This does not affect environment variables, which should be managed at
the OS or container level.

## Examples

``` r
if (FALSE) { # \dontrun{
auth <- authenticate_mattermost(base_url = "https://mm.example.com", token = "secret")
# ... use auth ...
clear_mattermost_credentials()
} # }
```
