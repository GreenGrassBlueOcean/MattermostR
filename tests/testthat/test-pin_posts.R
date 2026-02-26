# ---------- pin_post() ----------

test_that("pin_post() requires post_id", {
  expect_error(pin_post(post_id = NULL), "post_id")
  expect_error(pin_post(post_id = ""),   "post_id")
})

test_that("pin_post() validates auth", {
  expect_error(pin_post("p1", auth = "not_auth"), "mattermost_auth")
})

test_that("pin_post() constructs correct POST request", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_response <- list(status = "OK")
  mock_api <- mockery::mock(mock_response)
  mockery::stub(pin_post, "mattermost_api_request", mock_api)
  mockery::stub(pin_post, "check_mattermost_auth", function(auth) {})

  result <- pin_post("p1", auth = mock_auth)

  expect_equal(result, mock_response)
  args <- mockery::mock_args(mock_api)[[1]]
  expect_equal(args$endpoint, "/api/v4/posts/p1/pin")
  expect_equal(args$method, "POST")
  expect_null(args$body)
})

test_that("pin_post() passes verbose flag", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_api <- mockery::mock(list())
  mockery::stub(pin_post, "mattermost_api_request", mock_api)
  mockery::stub(pin_post, "check_mattermost_auth", function(auth) {})

  pin_post("p1", verbose = TRUE, auth = mock_auth)

  args <- mockery::mock_args(mock_api)[[1]]
  expect_true(args$verbose)
})

test_that("pin_post() propagates API errors", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mockery::stub(pin_post, "mattermost_api_request",
                function(...) stop("Post not found"))
  mockery::stub(pin_post, "check_mattermost_auth", function(auth) {})

  expect_error(pin_post("bad_id", auth = mock_auth), "Post not found")
})

# ---------- unpin_post() ----------

test_that("unpin_post() requires post_id", {
  expect_error(unpin_post(post_id = NULL), "post_id")
  expect_error(unpin_post(post_id = ""),   "post_id")
})

test_that("unpin_post() validates auth", {
  expect_error(unpin_post("p1", auth = "not_auth"), "mattermost_auth")
})

test_that("unpin_post() constructs correct POST request", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_response <- list(status = "OK")
  mock_api <- mockery::mock(mock_response)
  mockery::stub(unpin_post, "mattermost_api_request", mock_api)
  mockery::stub(unpin_post, "check_mattermost_auth", function(auth) {})

  result <- unpin_post("p1", auth = mock_auth)

  expect_equal(result, mock_response)
  args <- mockery::mock_args(mock_api)[[1]]
  expect_equal(args$endpoint, "/api/v4/posts/p1/unpin")
  expect_equal(args$method, "POST")
  expect_null(args$body)
})

test_that("unpin_post() passes verbose flag", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_api <- mockery::mock(list())
  mockery::stub(unpin_post, "mattermost_api_request", mock_api)
  mockery::stub(unpin_post, "check_mattermost_auth", function(auth) {})

  unpin_post("p1", verbose = TRUE, auth = mock_auth)

  args <- mockery::mock_args(mock_api)[[1]]
  expect_true(args$verbose)
})

test_that("unpin_post() propagates API errors", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mockery::stub(unpin_post, "mattermost_api_request",
                function(...) stop("Post not found"))
  mockery::stub(unpin_post, "check_mattermost_auth", function(auth) {})

  expect_error(unpin_post("bad_id", auth = mock_auth), "Post not found")
})
