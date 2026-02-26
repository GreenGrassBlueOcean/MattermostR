# Retrieve a file from Mattermost

This function retrieves a file from Mattermost based on its file ID.

## Usage

``` r
get_mattermost_file(file_id, auth = get_default_auth())
```

## Arguments

- file_id:

  The ID of the file to be retrieved.

- auth:

  The authentication object created by \[authenticate_mattermost()\].

## Value

The file contents as returned by the Mattermost API. The exact type
depends on the file's content type (typically raw bytes or a character
string).

## Examples

``` r
if (FALSE) { # \dontrun{
# Assuming you have already authenticated and obtained the file_id
file_id <- "your_file_id_here"
file_response <- get_mattermost_file(file_id = file_id)
print(file_response)

file_response <- get_mattermost_file(file_id = "i5rb43jei787jxcud7ekyyyyhc")
} # }
```
