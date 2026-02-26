# Get information about a Mattermost channel

Get information about a Mattermost channel

## Usage

``` r
get_channel_info(channel_id, verbose = FALSE, auth = get_default_auth())
```

## Arguments

- channel_id:

  A character string containing the Mattermost channel ID.

- verbose:

  (Logical) If \`TRUE\`, detailed information about the request and
  response will be printed. Default is \`FALSE\`.

- auth:

  The authentication object created by \[authenticate_mattermost()\].

## Value

A named list with channel fields returned by the Mattermost API (e.g.
\`id\`, \`display_name\`, \`name\`, \`type\`, \`team_id\`).

## Examples

``` r
if (FALSE) { # \dontrun{
 get_channel_info(channel_id = "newchannel2", verbose = TRUE)
} # }
```
