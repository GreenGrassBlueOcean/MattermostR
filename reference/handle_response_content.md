# Handle the content of the response

Handle the content of the response

## Usage

``` r
handle_response_content(response, verbose = FALSE)
```

## Arguments

- response:

  The response object from the API request.

- verbose:

  Boolean. If \`TRUE\`, the function will print the response details for
  more information.

## Value

The response object if the content type is JSON, or a warning if it's
not.
