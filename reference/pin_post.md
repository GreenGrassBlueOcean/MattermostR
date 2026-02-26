# Pin a post to its channel

Pin a post to the top of the channel it belongs to. This is the semantic
endpoint for pinning; the same effect can be achieved via
\`update_post(post_id, is_pinned = TRUE)\`.

## Usage

``` r
pin_post(post_id, verbose = FALSE, auth = get_default_auth())
```

## Arguments

- post_id:

  Character. The ID of the post to pin.

- verbose:

  Logical. Print detailed request information? Default \`FALSE\`.

- auth:

  A \`mattermost_auth\` object created by \[authenticate_mattermost()\].
  Defaults to \[get_default_auth()\].

## Value

A named list with \`status = "OK"\` on success.

## Permissions

Must be authenticated and have \`read_channel\` permission for the
channel the post is in.

## See also

\[unpin_post()\], \[update_post()\]

## Examples

``` r
if (FALSE) { # \dontrun{
  pin_post("post_id_abc")
} # }
```
