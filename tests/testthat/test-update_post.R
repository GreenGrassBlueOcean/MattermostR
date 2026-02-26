# Test suite for update_post

test_that("update_post() validates post_id", {
  # NULL post_id
  expect_error(update_post(post_id = NULL, message = "hi"),
               "post_id cannot be empty or NULL")

  # Empty string post_id
  expect_error(update_post(post_id = "", message = "hi"),
               "post_id cannot be empty or NULL")
})

test_that("update_post() validates auth", {
  expect_error(update_post(post_id = "123", message = "hi", auth = NULL),
               "The provided object is not a valid 'mattermost_auth' object.")
})

test_that("update_post() requires at least one patch field", {
  mock_auth <- structure(
    list(base_url = "https://fake-mattermost.com", headers = "Bearer faketoken"),
    class = "mattermost_auth"
  )

  mockery::stub(update_post, "check_mattermost_auth", function(auth) {})

  expect_error(
    update_post(post_id = "123", auth = mock_auth),
    "At least one of 'message', 'is_pinned', or 'props' must be provided."
  )
})

test_that("update_post() sends message-only patch", {
  mock_auth <- structure(
    list(base_url = "https://fake-mattermost.com", headers = "Bearer faketoken"),
    class = "mattermost_auth"
  )
  mock_response <- list(id = "123", message = "Updated text", is_pinned = FALSE)

  mockery::stub(update_post, "check_mattermost_auth", function(auth) {})
  mock_api <- mockery::mock(mock_response)
  mockery::stub(update_post, "mattermost_api_request", mock_api)

  result <- update_post(post_id = "123", message = "Updated text", auth = mock_auth)

  expect_equal(result, mock_response)

  # Verify correct endpoint and method
  call_args <- mockery::mock_args(mock_api)[[1]]
  expect_equal(call_args$endpoint, "/api/v4/posts/123/patch")
  expect_equal(call_args$method, "PUT")
  expect_equal(call_args$body, list(message = "Updated text"))
})

test_that("update_post() sends is_pinned patch", {
  mock_auth <- structure(
    list(base_url = "https://fake-mattermost.com", headers = "Bearer faketoken"),
    class = "mattermost_auth"
  )
  mock_response <- list(id = "456", is_pinned = TRUE)

  mockery::stub(update_post, "check_mattermost_auth", function(auth) {})
  mock_api <- mockery::mock(mock_response)
  mockery::stub(update_post, "mattermost_api_request", mock_api)

  result <- update_post(post_id = "456", is_pinned = TRUE, auth = mock_auth)

  call_args <- mockery::mock_args(mock_api)[[1]]
  expect_equal(call_args$body, list(is_pinned = TRUE))
})

test_that("update_post() sends multiple fields in body", {
  mock_auth <- structure(
    list(base_url = "https://fake-mattermost.com", headers = "Bearer faketoken"),
    class = "mattermost_auth"
  )
  mock_response <- list(id = "789", message = "new", is_pinned = TRUE)

  mockery::stub(update_post, "check_mattermost_auth", function(auth) {})
  mock_api <- mockery::mock(mock_response)
  mockery::stub(update_post, "mattermost_api_request", mock_api)

  result <- update_post(
    post_id = "789",
    message = "new",
    is_pinned = TRUE,
    props = list(card = "extra"),
    auth = mock_auth
  )

  call_args <- mockery::mock_args(mock_api)[[1]]
  expect_equal(call_args$body$message, "new")
  expect_true(call_args$body$is_pinned)
  expect_equal(call_args$body$props, list(card = "extra"))
})

test_that("update_post() passes verbose to mattermost_api_request", {
  mock_auth <- structure(
    list(base_url = "https://fake-mattermost.com", headers = "Bearer faketoken"),
    class = "mattermost_auth"
  )

  mockery::stub(update_post, "check_mattermost_auth", function(auth) {})
  mock_api <- mockery::mock(list(id = "123"))
  mockery::stub(update_post, "mattermost_api_request", mock_api)

  update_post(post_id = "123", message = "test", verbose = TRUE, auth = mock_auth)

  call_args <- mockery::mock_args(mock_api)[[1]]
  expect_true(call_args$verbose)
})

test_that("update_post() propagates API errors", {
  mock_auth <- structure(
    list(base_url = "https://fake-mattermost.com", headers = "Bearer faketoken"),
    class = "mattermost_auth"
  )

  mockery::stub(update_post, "check_mattermost_auth", function(auth) {})
  mockery::stub(update_post, "mattermost_api_request", function(...) {
    stop("Post not found")
  })

  expect_error(
    update_post(post_id = "bad_id", message = "test", auth = mock_auth),
    "Post not found"
  )
})
