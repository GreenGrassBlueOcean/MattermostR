
test_that("mattermost_api_request() works as expected", {

  # 1. Test case: Missing or incomplete authentication details
  expect_error(mattermost_api_request(auth = list(base_url = NULL, headers = NULL), endpoint = "/api/v4/teams"),
               "Authentication details are incomplete. Please provide a valid base_url and Authorization token.")

  # 2. Test case: Unsupported HTTP method
  expect_error(mattermost_api_request(auth = list(base_url = "http://localhost", headers = "Bearer token"), endpoint = "/api/v4/teams", method = "PATCH"),
               "Unsupported HTTP method.")

  # 3. Test case: Successful GET request
  mockery::stub(mattermost_api_request, 'httr2::req_perform', function(req) {
    # Simulate a successful response object with non-empty body and necessary fields
    structure(list(
      body = charToRaw('{"id": "team123", "name": "Test Team"}'),
      status_code = 200L,
      headers = list(`content-type` = "application/json"),
      cache = new.env(parent = emptyenv())  # Add a mock cache environment to simulate internal structure
    ), class = "httr2_response")
  })

  mockery::stub(mattermost_api_request, 'httr2::resp_content_type', function(response) "application/json")
  mockery::stub(mattermost_api_request, 'httr2::resp_body_json', function(response, simplifyVector) list(id = "team123", name = "Test Team"))

  result <- mattermost_api_request(auth = list(base_url = "http://localhost", headers = "Bearer token"), endpoint = "/api/v4/teams")

  expect_equal(result$id, "team123")
  expect_equal(result$name, "Test Team")

  # 4. Test case: Successful POST request with body
  mockery::stub(mattermost_api_request, 'httr2::req_perform', function(req) {
    structure(list(
      body = charToRaw('{"id": "newteam123", "name": "New Test Team"}'),
      status_code = 201L,
      headers = list(`content-type` = "application/json"),
      cache = new.env(parent = emptyenv())
    ), class = "httr2_response")
  })

  mockery::stub(mattermost_api_request, 'httr2::resp_content_type', function(response) "application/json")
  mockery::stub(mattermost_api_request, 'httr2::resp_body_json', function(response, simplifyVector) list(id = "newteam123", name = "New Test Team"))

  result <- mattermost_api_request(
    auth = list(base_url = "http://localhost", headers = "Bearer token"),
    endpoint = "/api/v4/teams",
    method = "POST",
    body = list(name = "New Test Team", display_name = "New Team Display")
  )

  expect_equal(result$id, "newteam123")
  expect_equal(result$name, "New Test Team")

  # 5. Test case: Retry mechanism (simulate failure and success)
  # test_that("mattermost_api_request() handles retries correctly", {
  #   retry_count <- 0
  #   max_retries <- 3
  #
  #   # Mock req_perform to fail on the first two attempts and succeed on the third
  #   mockery::stub(mattermost_api_request, 'httr2::req_perform', function(req) {
  #     retry_count <<- retry_count + 1
  #     if (retry_count < max_retries) {
  #       # Simulate an error to trigger the retry logic
  #       stop("Request failed, retrying...")
  #     }
  #     # Simulate a successful response on the third attempt
  #     structure(list(
  #       body = charToRaw('{"id": "retryteam123", "name": "Retry Test Team"}'),
  #       status_code = 200L,
  #       headers = list(`content-type` = "application/json"),
  #       cache = new.env(parent = emptyenv())
  #     ), class = "httr2_response")
  #   })
  #
  #   # Mock the necessary response functions
  #   mockery::stub(mattermost_api_request, 'httr2::resp_content_type', function(response) "application/json")
  #   mockery::stub(mattermost_api_request, 'httr2::resp_body_json', function(response, simplifyVector) list(id = "retryteam123", name = "Retry Test Team"))
  #
  #   # Call the function and check that it works after retries
  #   result <- mattermost_api_request(auth = list(base_url = "http://localhost", headers = "Bearer token"), endpoint = "/api/v4/teams")
  #
  #   # Check the returned result
  #   expect_equal(result$id, "retryteam123")
  #   expect_equal(result$name, "Retry Test Team")
  #   expect_equal(retry_count, max_retries)  # Ensure it retried the expected number of times
  # })
  #
  #
  #
  #


  # # 6. Test case: Unexpected content type (non-JSON)
  # mockery::stub(mattermost_api_request, 'httr2::req_perform', function(req) {
  #   structure(list(
  #     body = charToRaw("This is not JSON"),
  #     status_code = 200L,
  #     headers = list(`content-type` = "text/plain"),
  #     cache = new.env(parent = emptyenv())
  #   ), class = "httr2_response")
  # })
  #
  # mockery::stub(mattermost_api_request, 'httr2::resp_content_type', function(response) "text/plain")
  # mockery::stub(mattermost_api_request, 'httr2::resp_body_string', function(response) "This is not JSON")
  #
  # expect_warning(
  #   result <- mattermost_api_request(auth = list(base_url = "http://localhost", headers = "Bearer token"), endpoint = "/api/v4/teams"),
  #   "Received unexpected content type"
  # )
  # expect_null(result)

  # 7. Test case: Verbose output
  verbose_output <- ""
  mockery::stub(mattermost_api_request, 'httr2::req_verbose', function(req) {
    verbose_output <<- "Verbose output enabled"
    req
  })

  mockery::stub(mattermost_api_request, 'httr2::req_perform', function(req) {
    structure(list(
      body = charToRaw('{"id": "verbose-team", "name": "Verbose Team"}'),
      status_code = 200L,
      headers = list(`content-type` = "application/json"),
      cache = new.env(parent = emptyenv())
    ), class = "httr2_response")
  })

  result <- mattermost_api_request(auth = list(base_url = "http://localhost", headers = "Bearer token"), endpoint = "/api/v4/teams", verbose = TRUE)

  expect_equal(verbose_output, "Verbose output enabled")
  expect_equal(result$id, "verbose-team")
  expect_equal(result$name, "Verbose Team")
})
