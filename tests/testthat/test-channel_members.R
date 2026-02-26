# ---------- get_channel_members() ----------

test_that("get_channel_members() requires channel_id", {
  expect_error(get_channel_members(channel_id = NULL), "channel_id")
  expect_error(get_channel_members(channel_id = ""),   "channel_id")
})

test_that("get_channel_members() validates auth", {
  expect_error(get_channel_members("c1", auth = "bad"), "mattermost_auth")
})

test_that("get_channel_members() validates page parameter", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mockery::stub(get_channel_members, "check_mattermost_auth", function(auth) {})

  expect_error(get_channel_members("c1", page = -1, auth = mock_auth),
               "non-negative integer")
  expect_error(get_channel_members("c1", page = "a", auth = mock_auth),
               "non-negative integer")
})

test_that("get_channel_members() validates per_page parameter", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mockery::stub(get_channel_members, "check_mattermost_auth", function(auth) {})

  expect_error(get_channel_members("c1", per_page = 0, auth = mock_auth),
               "between 1 and 200")
  expect_error(get_channel_members("c1", per_page = 201, auth = mock_auth),
               "between 1 and 200")
})

test_that("get_channel_members() constructs correct GET request with defaults", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_response <- data.frame(
    channel_id = c("c1", "c1"),
    user_id    = c("u1", "u2"),
    roles      = c("channel_user", "channel_admin"),
    stringsAsFactors = FALSE
  )
  mock_api <- mockery::mock(mock_response)
  mockery::stub(get_channel_members, "mattermost_api_request", mock_api)
  mockery::stub(get_channel_members, "check_mattermost_auth", function(auth) {})

  result <- get_channel_members("c1", auth = mock_auth)

  expect_equal(result, mock_response)
  args <- mockery::mock_args(mock_api)[[1]]
  expect_equal(args$endpoint, "/api/v4/channels/c1/members?page=0&per_page=60")
  expect_equal(args$method, "GET")
})

test_that("get_channel_members() passes custom page and per_page", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_api <- mockery::mock(data.frame())
  mockery::stub(get_channel_members, "mattermost_api_request", mock_api)
  mockery::stub(get_channel_members, "check_mattermost_auth", function(auth) {})

  get_channel_members("c1", page = 3, per_page = 100, auth = mock_auth)

  args <- mockery::mock_args(mock_api)[[1]]
  expect_equal(args$endpoint, "/api/v4/channels/c1/members?page=3&per_page=100")
})

test_that("get_channel_members() passes verbose flag", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_api <- mockery::mock(data.frame())
  mockery::stub(get_channel_members, "mattermost_api_request", mock_api)
  mockery::stub(get_channel_members, "check_mattermost_auth", function(auth) {})

  get_channel_members("c1", verbose = TRUE, auth = mock_auth)

  args <- mockery::mock_args(mock_api)[[1]]
  expect_true(args$verbose)
})

# ---------- remove_channel_member() ----------

test_that("remove_channel_member() requires channel_id and user_id", {
  expect_error(remove_channel_member(channel_id = NULL, user_id = "u1"), "channel_id")
  expect_error(remove_channel_member(channel_id = "c1", user_id = NULL), "user_id")
  expect_error(remove_channel_member(channel_id = "",   user_id = "u1"), "channel_id")
  expect_error(remove_channel_member(channel_id = "c1", user_id = ""),   "user_id")
})

test_that("remove_channel_member() validates auth", {
  expect_error(remove_channel_member("c1", "u1", auth = "bad"),
               "mattermost_auth")
})

test_that("remove_channel_member() constructs correct DELETE request", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_response <- list(status = "OK")
  mock_api <- mockery::mock(mock_response)
  mockery::stub(remove_channel_member, "mattermost_api_request", mock_api)
  mockery::stub(remove_channel_member, "check_mattermost_auth", function(auth) {})

  result <- remove_channel_member("c1", "u1", auth = mock_auth)

  expect_equal(result, mock_response)
  args <- mockery::mock_args(mock_api)[[1]]
  expect_equal(args$endpoint, "/api/v4/channels/c1/members/u1")
  expect_equal(args$method, "DELETE")
})

test_that("remove_channel_member() passes verbose flag", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_api <- mockery::mock(list())
  mockery::stub(remove_channel_member, "mattermost_api_request", mock_api)
  mockery::stub(remove_channel_member, "check_mattermost_auth", function(auth) {})

  remove_channel_member("c1", "u1", verbose = TRUE, auth = mock_auth)

  args <- mockery::mock_args(mock_api)[[1]]
  expect_true(args$verbose)
})

test_that("remove_channel_member() propagates API errors", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mockery::stub(remove_channel_member, "mattermost_api_request",
                function(...) stop("Forbidden"))
  mockery::stub(remove_channel_member, "check_mattermost_auth", function(auth) {})

  expect_error(remove_channel_member("c1", "u1", auth = mock_auth), "Forbidden")
})
