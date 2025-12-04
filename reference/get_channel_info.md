# Get information about a Mattermost channel

Get information about a Mattermost channel

## Usage

``` r
get_channel_info(channel_id, verbose = FALSE, auth = authenticate_mattermost())
```

## Arguments

- channel_id:

  The Mattermost channel ID.

- verbose:

  (Logical) If \`TRUE\`, detailed information about the request and
  response will be printed.

- auth:

  The authentication object created by \`authenticate_mattermost()\`.

## Value

Parsed JSON response with channel information.

## Examples

``` r
if (FALSE) { # \dontrun{
 get_channel_info(channel_id = "newchannel2", verbose = TRUE)
} # }
```
