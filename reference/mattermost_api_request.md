# Make a Mattermost API Request

This function sends an HTTP request to the Mattermost API using
authentication details, endpoint, and method provided. It handles
retries with exponential backoff for failed requests and supports both
regular JSON requests and multipart file uploads.

## Usage

``` r
mattermost_api_request(
  auth,
  endpoint,
  method = "GET",
  body = NULL,
  multipart = FALSE,
  verbose = FALSE
)
```

## Arguments

- auth:

  A list containing the \`base_url\` and \`headers\` (which includes the
  authentication token).

- endpoint:

  A string specifying the API endpoint (e.g., \`"/api/v4/teams"\`).

- method:

  A string specifying the HTTP method to use. Options include \`"GET"\`,
  \`"POST"\`, \`"PUT"\`, and \`"DELETE"\`.

- body:

  (Optional) A list or object representing the body of the request
  (e.g., for \`POST\` or \`PUT\` requests).

- multipart:

  (Logical) Set to \`TRUE\` if the request includes multipart data
  (e.g., file upload).

- verbose:

  (Logical) If \`TRUE\`, detailed information about the request and
  response will be printed.

## Value

The content of the response, usually parsed as JSON, or an error message
if the request fails.
