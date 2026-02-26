# Delete a specific post in Mattermost

Delete a specific post in Mattermost

## Usage

``` r
delete_post(post_id = NULL, verbose = FALSE, auth = get_default_auth())
```

## Arguments

- post_id:

  The ID of the post to delete.

- verbose:

  Boolean. If \`TRUE\`, the function will print request/response details
  for more information.

- auth:

  The authentication object created by \`authenticate_mattermost()\`.

## Value

A named list with the deletion status as returned by the Mattermost API.

## Examples

``` r
if (FALSE) { # \dontrun{
 delete_post(post_id = "fake_id")
} # }
```
