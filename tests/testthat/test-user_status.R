# ---------- get_user_status() ----------

test_that("get_user_status() requires user_id", {
  expect_error(get_user_status(user_id = NULL), "user_id")
  expect_error(get_user_status(user_id = ""),   "user_id")
})

test_that("get_user_status() validates auth", {
  expect_error(get_user_status("u1", auth = "not_auth"), "mattermost_auth")
})

test_that("get_user_status() constructs correct GET request", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_response <- list(user_id = "u1", status = "online",
                        manual = FALSE, last_activity_at = 1700000000000)
  mock_api <- mockery::mock(mock_response)
  mockery::stub(get_user_status, "mattermost_api_request", mock_api)
  mockery::stub(get_user_status, "check_mattermost_auth", function(auth) {})

  result <- get_user_status("u1", auth = mock_auth)

  expect_equal(result, mock_response)
  args <- mockery::mock_args(mock_api)[[1]]
  expect_equal(args$endpoint, "/api/v4/users/u1/status")
  expect_equal(args$method, "GET")
})

test_that("get_user_status() accepts 'me' as user_id", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_api <- mockery::mock(list(user_id = "me", status = "away"))
  mockery::stub(get_user_status, "mattermost_api_request", mock_api)
  mockery::stub(get_user_status, "check_mattermost_auth", function(auth) {})

  get_user_status("me", auth = mock_auth)

  args <- mockery::mock_args(mock_api)[[1]]
  expect_equal(args$endpoint, "/api/v4/users/me/status")
})

test_that("get_user_status() passes verbose flag", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_api <- mockery::mock(list())
  mockery::stub(get_user_status, "mattermost_api_request", mock_api)
  mockery::stub(get_user_status, "check_mattermost_auth", function(auth) {})

  get_user_status("u1", verbose = TRUE, auth = mock_auth)

  args <- mockery::mock_args(mock_api)[[1]]
  expect_true(args$verbose)
})

# ---------- set_user_status() ----------

test_that("set_user_status() requires user_id and status", {
  expect_error(set_user_status(user_id = NULL, status = "online"), "user_id")
  expect_error(set_user_status(user_id = "u1",  status = NULL),    "status")
})

test_that("set_user_status() validates auth", {
  expect_error(set_user_status("u1", "online", auth = "bad"), "mattermost_auth")
})

test_that("set_user_status() rejects invalid status values", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mockery::stub(set_user_status, "check_mattermost_auth", function(auth) {})

  expect_error(set_user_status("u1", "busy", auth = mock_auth),
               "status must be one of")
  expect_error(set_user_status("u1", "active", auth = mock_auth),
               "status must be one of")
})

test_that("set_user_status() is case-insensitive for status", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_api <- mockery::mock(list(status = "dnd"), list(status = "away"))
  mockery::stub(set_user_status, "mattermost_api_request", mock_api)
  mockery::stub(set_user_status, "check_mattermost_auth", function(auth) {})

  set_user_status("u1", "DND", auth = mock_auth)
  args1 <- mockery::mock_args(mock_api)[[1]]
  expect_equal(args1$body$status, "dnd")

  set_user_status("u1", "Away", auth = mock_auth)
  args2 <- mockery::mock_args(mock_api)[[2]]
  expect_equal(args2$body$status, "away")
})

test_that("set_user_status() constructs correct PUT request", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_response <- list(user_id = "u1", status = "offline")
  mock_api <- mockery::mock(mock_response)
  mockery::stub(set_user_status, "mattermost_api_request", mock_api)
  mockery::stub(set_user_status, "check_mattermost_auth", function(auth) {})

  result <- set_user_status("u1", "offline", auth = mock_auth)

  expect_equal(result, mock_response)
  args <- mockery::mock_args(mock_api)[[1]]
  expect_equal(args$endpoint, "/api/v4/users/u1/status")
  expect_equal(args$method, "PUT")
  expect_equal(args$body$user_id, "u1")
  expect_equal(args$body$status, "offline")
  expect_null(args$body$dnd_end_time)
})

test_that("set_user_status() includes dnd_end_time when status is dnd", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_api <- mockery::mock(list(status = "dnd"))
  mockery::stub(set_user_status, "mattermost_api_request", mock_api)
  mockery::stub(set_user_status, "check_mattermost_auth", function(auth) {})

  set_user_status("u1", "dnd", dnd_end_time = 1700003600, auth = mock_auth)

  args <- mockery::mock_args(mock_api)[[1]]
  expect_equal(args$body$dnd_end_time, 1700003600L)
})

test_that("set_user_status() warns when dnd_end_time used with non-dnd status", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_api <- mockery::mock(list(status = "online"))
  mockery::stub(set_user_status, "mattermost_api_request", mock_api)
  mockery::stub(set_user_status, "check_mattermost_auth", function(auth) {})

  expect_warning(
    set_user_status("u1", "online", dnd_end_time = 1700003600, auth = mock_auth),
    "dnd_end_time is only meaningful"
  )

  args <- mockery::mock_args(mock_api)[[1]]
  expect_null(args$body$dnd_end_time)
})

test_that("set_user_status() rejects invalid dnd_end_time", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mockery::stub(set_user_status, "check_mattermost_auth", function(auth) {})

  expect_error(set_user_status("u1", "dnd", dnd_end_time = -1, auth = mock_auth),
               "positive number")
  expect_error(set_user_status("u1", "dnd", dnd_end_time = "abc", auth = mock_auth),
               "positive number")
})

test_that("set_user_status() passes verbose flag", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_api <- mockery::mock(list())
  mockery::stub(set_user_status, "mattermost_api_request", mock_api)
  mockery::stub(set_user_status, "check_mattermost_auth", function(auth) {})

  set_user_status("u1", "online", verbose = TRUE, auth = mock_auth)

  args <- mockery::mock_args(mock_api)[[1]]
  expect_true(args$verbose)
})
