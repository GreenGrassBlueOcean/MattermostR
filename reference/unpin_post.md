# Unpin a post from its channel

Remove a post's pinned status from the channel. This is the semantic
endpoint for unpinning; the same effect can be achieved via
\`update_post(post_id, is_pinned = FALSE)\`.

## Usage

``` r
unpin_post(post_id, verbose = FALSE, auth = get_default_auth())
```

## Arguments

- post_id:

  Character. The ID of the post to unpin.

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

\[pin_post()\], \[update_post()\]

## Examples

``` r
if (FALSE) { # \dontrun{
  unpin_post("post_id_abc")
} # }
```
