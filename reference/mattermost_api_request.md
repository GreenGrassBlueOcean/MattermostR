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

The content of the response, usually parsed as JSON. On error, raises a
`mattermost_error` condition (default) or returns `NULL` (legacy mode).

## Rate Limiting

Requests are proactively throttled via
[`httr2::req_throttle()`](https://httr2.r-lib.org/reference/req_throttle.html)
at a rate controlled by `getOption("MattermostR.rate_limit", 10)`
requests per second. Set to `Inf` to disable throttling. The default of
10 matches Mattermost's out-of-the-box server setting (configurable in
System Console).

If the server returns HTTP 429 (Too Many Requests), the retry logic
reads the `X-Ratelimit-Reset` header to wait exactly the right number of
seconds before retrying.

## Error Handling

By default, HTTP errors and connection failures raise a
`mattermost_error` condition (an S3 error class) that can be caught with
`tryCatch(..., mattermost_error = function(e) ...)`.

Set `options(MattermostR.on_error = "message")` to revert to the legacy
behaviour where errors are emitted via
[`message()`](https://rdrr.io/r/base/message.html) and the function
returns `NULL`.
