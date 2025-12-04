# Get information about a specific Mattermost user

Retrieve detailed information about a user, such as their username,
email, roles, and ID.

## Usage

``` r
get_user_info(user_id = NULL, auth = authenticate_mattermost())
```

## Arguments

- user_id:

  A character string containing the Mattermost user ID. You can also use
  the special string \*\*"me"\*\* to retrieve information about the
  currently authenticated user (the bot/user associated with the token).

- auth:

  The authentication object created by \`authenticate_mattermost()\`.

## Value

Parsed JSON response with user information (list).

## Examples

``` r
if (FALSE) { # \dontrun{
  # Get info about a specific user by ID
  user <- get_user_info("xb123abc456...")

  # Get info about the current authenticated bot/user
  myself <- get_user_info("me")
  print(myself$id)
} # }
```
