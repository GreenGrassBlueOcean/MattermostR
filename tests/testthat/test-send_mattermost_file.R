# Test suite for send_mattermost_file

# --- Input validation tests (no mocks needed for the API layer) ---

test_that("send_mattermost_file() rejects NULL channel_id", {
  test_file_path <- testthat::test_path("testdata/output.txt")
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com", headers = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  expect_error(
    send_mattermost_file(channel_id = NULL, file_path = test_file_path, auth = mock_auth),
    "channel_id cannot be empty or NULL"
  )
})

test_that("send_mattermost_file() rejects NULL file_path", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com", headers = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  expect_error(
    send_mattermost_file(channel_id = "123", file_path = NULL, auth = mock_auth),
    "file_path cannot be empty or NULL"
  )
})

test_that("send_mattermost_file() rejects invalid auth object", {
  test_file_path <- testthat::test_path("testdata/output.txt")
  expect_error(
    send_mattermost_file(channel_id = "123", file_path = test_file_path, auth = NULL),
    "The provided object is not a valid 'mattermost_auth' object."
  )
})

test_that("send_mattermost_file() rejects non-existent file", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com", headers = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  non_existent_path <- tempfile()
  expect_error(
    send_mattermost_file(channel_id = "123", file_path = non_existent_path, auth = mock_auth),
    "The file specified by 'file_path' does not exist."
  )
})

# --- Tests that verify delegation to mattermost_api_request() ---

test_that("send_mattermost_file() delegates to mattermost_api_request with correct args", {
  test_file_path <- testthat::test_path("testdata/output.txt")
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com", headers = "Bearer mock_token"),
    class = "mattermost_auth"
  )

  fake_response <- list(
    file_infos = data.frame(id = "file123", name = "output.txt", stringsAsFactors = FALSE)
  )

  mock_api <- mockery::mock(fake_response)
  mockery::stub(send_mattermost_file, "mattermost_api_request", mock_api)

  result <- send_mattermost_file(
    channel_id = "chan_abc",
    file_path = test_file_path,
    auth = mock_auth
  )

  # Verify mattermost_api_request was called exactly once
  mockery::expect_called(mock_api, 1)

  # Inspect the call arguments
  call_args <- mockery::mock_args(mock_api)[[1]]
  expect_equal(call_args$auth, mock_auth)
  expect_equal(call_args$endpoint, "/api/v4/files")
  expect_equal(call_args$method, "POST")
  expect_true(call_args$multipart)
  expect_false(call_args$verbose)

  # Body should contain files and channel_id, but no comment
  expect_equal(call_args$body$channel_id, "chan_abc")
  expect_null(call_args$body$comment)
  expect_true(inherits(call_args$body$files, "form_file"))

  # Return value is passed through

  expect_equal(result, fake_response)
})

test_that("send_mattermost_file() includes comment in body when provided", {
  test_file_path <- testthat::test_path("testdata/output.txt")
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com", headers = "Bearer mock_token"),
    class = "mattermost_auth"
  )

  mock_api <- mockery::mock(list(ok = TRUE))
  mockery::stub(send_mattermost_file, "mattermost_api_request", mock_api)

  send_mattermost_file(
    channel_id = "chan_abc",
    file_path = test_file_path,
    comment = "Here is the report",
    auth = mock_auth
  )

  call_args <- mockery::mock_args(mock_api)[[1]]
  expect_equal(call_args$body$comment, "Here is the report")
  expect_equal(call_args$body$channel_id, "chan_abc")
})

test_that("send_mattermost_file() omits comment from body when NULL", {
  test_file_path <- testthat::test_path("testdata/output.txt")
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com", headers = "Bearer mock_token"),
    class = "mattermost_auth"
  )

  mock_api <- mockery::mock(list(ok = TRUE))
  mockery::stub(send_mattermost_file, "mattermost_api_request", mock_api)

  send_mattermost_file(
    channel_id = "chan_abc",
    file_path = test_file_path,
    auth = mock_auth
  )

  call_args <- mockery::mock_args(mock_api)[[1]]
  expect_null(call_args$body$comment)
  # Body should have exactly 2 elements: files and channel_id
  expect_equal(sort(names(call_args$body)), c("channel_id", "files"))
})

test_that("send_mattermost_file() passes verbose = TRUE through to mattermost_api_request", {
  test_file_path <- testthat::test_path("testdata/output.txt")
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com", headers = "Bearer mock_token"),
    class = "mattermost_auth"
  )

  mock_api <- mockery::mock(list(ok = TRUE))
  mockery::stub(send_mattermost_file, "mattermost_api_request", mock_api)

  send_mattermost_file(
    channel_id = "chan_abc",
    file_path = test_file_path,
    auth = mock_auth,
    verbose = TRUE
  )

  call_args <- mockery::mock_args(mock_api)[[1]]
  expect_true(call_args$verbose)
})

test_that("send_mattermost_file() returns NULL when mattermost_api_request returns NULL", {
  test_file_path <- testthat::test_path("testdata/output.txt")
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com", headers = "Bearer mock_token"),
    class = "mattermost_auth"
  )

  mock_api <- mockery::mock(NULL)
  mockery::stub(send_mattermost_file, "mattermost_api_request", mock_api)

  result <- send_mattermost_file(
    channel_id = "chan_abc",
    file_path = test_file_path,
    auth = mock_auth
  )

  expect_null(result)
})
