# ---------- create_bot() ----------

test_that("create_bot() requires username", {
  expect_error(create_bot(username = NULL), "username")
  expect_error(create_bot(username = ""),   "username")
})

test_that("create_bot() validates auth", {
  expect_error(create_bot("mybot", auth = "not_auth"), "mattermost_auth")
})

test_that("create_bot() constructs correct POST request", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_response <- list(user_id = "bot1", username = "mybot",
                        display_name = "My Bot", description = "A bot",
                        owner_id = "owner1", create_at = 1700000000000)
  mock_api <- mockery::mock(mock_response)
  mockery::stub(create_bot, "mattermost_api_request", mock_api)
  mockery::stub(create_bot, "check_mattermost_auth", function(auth) {})

  result <- create_bot("mybot", display_name = "My Bot",
                       description = "A bot", auth = mock_auth)

  expect_equal(result, mock_response)
  args <- mockery::mock_args(mock_api)[[1]]
  expect_equal(args$endpoint, "/api/v4/bots")
  expect_equal(args$method, "POST")
  expect_equal(args$body$username, "mybot")
  expect_equal(args$body$display_name, "My Bot")
  expect_equal(args$body$description, "A bot")
})

test_that("create_bot() omits NULL optional fields from body", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_api <- mockery::mock(list())
  mockery::stub(create_bot, "mattermost_api_request", mock_api)
  mockery::stub(create_bot, "check_mattermost_auth", function(auth) {})

  create_bot("mybot", auth = mock_auth)

  args <- mockery::mock_args(mock_api)[[1]]
  expect_equal(names(args$body), "username")
  expect_null(args$body$display_name)
  expect_null(args$body$description)
})

test_that("create_bot() passes verbose flag", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_api <- mockery::mock(list())
  mockery::stub(create_bot, "mattermost_api_request", mock_api)
  mockery::stub(create_bot, "check_mattermost_auth", function(auth) {})

  create_bot("mybot", verbose = TRUE, auth = mock_auth)

  args <- mockery::mock_args(mock_api)[[1]]
  expect_true(args$verbose)
})


# ---------- get_bot() ----------

test_that("get_bot() requires bot_user_id", {
  expect_error(get_bot(bot_user_id = NULL), "bot_user_id")
  expect_error(get_bot(bot_user_id = ""),   "bot_user_id")
})

test_that("get_bot() validates auth", {
  expect_error(get_bot("b1", auth = "bad"), "mattermost_auth")
})

test_that("get_bot() constructs correct GET request", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_response <- list(user_id = "b1", username = "testbot")
  mock_api <- mockery::mock(mock_response)
  mockery::stub(get_bot, "mattermost_api_request", mock_api)
  mockery::stub(get_bot, "check_mattermost_auth", function(auth) {})

  result <- get_bot("b1", auth = mock_auth)

  expect_equal(result, mock_response)
  args <- mockery::mock_args(mock_api)[[1]]
  expect_equal(args$endpoint, "/api/v4/bots/b1")
  expect_equal(args$method, "GET")
})

test_that("get_bot() appends include_deleted query param", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_api <- mockery::mock(list())
  mockery::stub(get_bot, "mattermost_api_request", mock_api)
  mockery::stub(get_bot, "check_mattermost_auth", function(auth) {})

  get_bot("b1", include_deleted = TRUE, auth = mock_auth)

  args <- mockery::mock_args(mock_api)[[1]]
  expect_equal(args$endpoint, "/api/v4/bots/b1?include_deleted=true")
})

test_that("get_bot() does not append include_deleted when FALSE", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_api <- mockery::mock(list())
  mockery::stub(get_bot, "mattermost_api_request", mock_api)
  mockery::stub(get_bot, "check_mattermost_auth", function(auth) {})

  get_bot("b1", include_deleted = FALSE, auth = mock_auth)

  args <- mockery::mock_args(mock_api)[[1]]
  expect_equal(args$endpoint, "/api/v4/bots/b1")
})

test_that("get_bot() passes verbose flag", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_api <- mockery::mock(list())
  mockery::stub(get_bot, "mattermost_api_request", mock_api)
  mockery::stub(get_bot, "check_mattermost_auth", function(auth) {})

  get_bot("b1", verbose = TRUE, auth = mock_auth)

  args <- mockery::mock_args(mock_api)[[1]]
  expect_true(args$verbose)
})


# ---------- get_bots() ----------

test_that("get_bots() validates auth", {
  expect_error(get_bots(auth = "bad"), "mattermost_auth")
})

test_that("get_bots() validates page parameter", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mockery::stub(get_bots, "check_mattermost_auth", function(auth) {})

  expect_error(get_bots(page = -1, auth = mock_auth), "non-negative")
})

test_that("get_bots() validates per_page parameter", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mockery::stub(get_bots, "check_mattermost_auth", function(auth) {})

  expect_error(get_bots(per_page = 0, auth = mock_auth), "between 1 and 200")
  expect_error(get_bots(per_page = 201, auth = mock_auth), "between 1 and 200")
})

test_that("get_bots() constructs correct GET request with defaults", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_api <- mockery::mock(data.frame())
  mockery::stub(get_bots, "mattermost_api_request", mock_api)
  mockery::stub(get_bots, "check_mattermost_auth", function(auth) {})

  get_bots(auth = mock_auth)

  args <- mockery::mock_args(mock_api)[[1]]
  expect_equal(args$endpoint, "/api/v4/bots?page=0&per_page=60")
  expect_equal(args$method, "GET")
})

test_that("get_bots() appends include_deleted and only_orphaned", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_api <- mockery::mock(data.frame())
  mockery::stub(get_bots, "mattermost_api_request", mock_api)
  mockery::stub(get_bots, "check_mattermost_auth", function(auth) {})

  get_bots(include_deleted = TRUE, only_orphaned = TRUE, auth = mock_auth)

  args <- mockery::mock_args(mock_api)[[1]]
  expect_true(grepl("include_deleted=true", args$endpoint))
  expect_true(grepl("only_orphaned=true", args$endpoint))
})

test_that("get_bots() respects custom page and per_page", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_api <- mockery::mock(data.frame())
  mockery::stub(get_bots, "mattermost_api_request", mock_api)
  mockery::stub(get_bots, "check_mattermost_auth", function(auth) {})

  get_bots(page = 2, per_page = 100, auth = mock_auth)

  args <- mockery::mock_args(mock_api)[[1]]
  expect_true(grepl("page=2", args$endpoint))
  expect_true(grepl("per_page=100", args$endpoint))
})

test_that("get_bots() passes verbose flag", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_api <- mockery::mock(data.frame())
  mockery::stub(get_bots, "mattermost_api_request", mock_api)
  mockery::stub(get_bots, "check_mattermost_auth", function(auth) {})

  get_bots(verbose = TRUE, auth = mock_auth)

  args <- mockery::mock_args(mock_api)[[1]]
  expect_true(args$verbose)
})


# ---------- update_bot() ----------

test_that("update_bot() requires bot_user_id and username", {
  expect_error(update_bot(bot_user_id = NULL, username = "x"), "bot_user_id")
  expect_error(update_bot(bot_user_id = "b1", username = NULL), "username")
  expect_error(update_bot(bot_user_id = "",   username = "x"), "bot_user_id")
  expect_error(update_bot(bot_user_id = "b1", username = ""),  "username")
})

test_that("update_bot() validates auth", {
  expect_error(update_bot("b1", "x", auth = "bad"), "mattermost_auth")
})

test_that("update_bot() constructs correct PUT request", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_response <- list(user_id = "b1", username = "newname")
  mock_api <- mockery::mock(mock_response)
  mockery::stub(update_bot, "mattermost_api_request", mock_api)
  mockery::stub(update_bot, "check_mattermost_auth", function(auth) {})

  result <- update_bot("b1", "newname", display_name = "New",
                       description = "Updated", auth = mock_auth)

  expect_equal(result, mock_response)
  args <- mockery::mock_args(mock_api)[[1]]
  expect_equal(args$endpoint, "/api/v4/bots/b1")
  expect_equal(args$method, "PUT")
  expect_equal(args$body$username, "newname")
  expect_equal(args$body$display_name, "New")
  expect_equal(args$body$description, "Updated")
})

test_that("update_bot() omits NULL optional fields from body", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_api <- mockery::mock(list())
  mockery::stub(update_bot, "mattermost_api_request", mock_api)
  mockery::stub(update_bot, "check_mattermost_auth", function(auth) {})

  update_bot("b1", "mybot", auth = mock_auth)

  args <- mockery::mock_args(mock_api)[[1]]
  expect_equal(names(args$body), "username")
})


# ---------- disable_bot() ----------

test_that("disable_bot() requires bot_user_id", {
  expect_error(disable_bot(bot_user_id = NULL), "bot_user_id")
  expect_error(disable_bot(bot_user_id = ""),   "bot_user_id")
})

test_that("disable_bot() validates auth", {
  expect_error(disable_bot("b1", auth = "bad"), "mattermost_auth")
})

test_that("disable_bot() constructs correct POST request", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_response <- list(user_id = "b1", delete_at = 1700000000000)
  mock_api <- mockery::mock(mock_response)
  mockery::stub(disable_bot, "mattermost_api_request", mock_api)
  mockery::stub(disable_bot, "check_mattermost_auth", function(auth) {})

  result <- disable_bot("b1", auth = mock_auth)

  expect_equal(result, mock_response)
  args <- mockery::mock_args(mock_api)[[1]]
  expect_equal(args$endpoint, "/api/v4/bots/b1/disable")
  expect_equal(args$method, "POST")
})

test_that("disable_bot() passes verbose flag", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_api <- mockery::mock(list())
  mockery::stub(disable_bot, "mattermost_api_request", mock_api)
  mockery::stub(disable_bot, "check_mattermost_auth", function(auth) {})

  disable_bot("b1", verbose = TRUE, auth = mock_auth)

  args <- mockery::mock_args(mock_api)[[1]]
  expect_true(args$verbose)
})


# ---------- enable_bot() ----------

test_that("enable_bot() requires bot_user_id", {
  expect_error(enable_bot(bot_user_id = NULL), "bot_user_id")
  expect_error(enable_bot(bot_user_id = ""),   "bot_user_id")
})

test_that("enable_bot() validates auth", {
  expect_error(enable_bot("b1", auth = "bad"), "mattermost_auth")
})

test_that("enable_bot() constructs correct POST request", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_response <- list(user_id = "b1", delete_at = 0)
  mock_api <- mockery::mock(mock_response)
  mockery::stub(enable_bot, "mattermost_api_request", mock_api)
  mockery::stub(enable_bot, "check_mattermost_auth", function(auth) {})

  result <- enable_bot("b1", auth = mock_auth)

  expect_equal(result, mock_response)
  args <- mockery::mock_args(mock_api)[[1]]
  expect_equal(args$endpoint, "/api/v4/bots/b1/enable")
  expect_equal(args$method, "POST")
})

test_that("enable_bot() passes verbose flag", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_api <- mockery::mock(list())
  mockery::stub(enable_bot, "mattermost_api_request", mock_api)
  mockery::stub(enable_bot, "check_mattermost_auth", function(auth) {})

  enable_bot("b1", verbose = TRUE, auth = mock_auth)

  args <- mockery::mock_args(mock_api)[[1]]
  expect_true(args$verbose)
})


# ---------- assign_bot() ----------

test_that("assign_bot() requires bot_user_id and user_id", {
  expect_error(assign_bot(bot_user_id = NULL, user_id = "u1"), "bot_user_id")
  expect_error(assign_bot(bot_user_id = "b1", user_id = NULL), "user_id")
  expect_error(assign_bot(bot_user_id = "",   user_id = "u1"), "bot_user_id")
  expect_error(assign_bot(bot_user_id = "b1", user_id = ""),   "user_id")
})

test_that("assign_bot() validates auth", {
  expect_error(assign_bot("b1", "u1", auth = "bad"), "mattermost_auth")
})

test_that("assign_bot() constructs correct POST request", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_response <- list(user_id = "b1", owner_id = "u2")
  mock_api <- mockery::mock(mock_response)
  mockery::stub(assign_bot, "mattermost_api_request", mock_api)
  mockery::stub(assign_bot, "check_mattermost_auth", function(auth) {})

  result <- assign_bot("b1", "u2", auth = mock_auth)

  expect_equal(result, mock_response)
  args <- mockery::mock_args(mock_api)[[1]]
  expect_equal(args$endpoint, "/api/v4/bots/b1/assign/u2")
  expect_equal(args$method, "POST")
})

test_that("assign_bot() passes verbose flag", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_api <- mockery::mock(list())
  mockery::stub(assign_bot, "mattermost_api_request", mock_api)
  mockery::stub(assign_bot, "check_mattermost_auth", function(auth) {})

  assign_bot("b1", "u1", verbose = TRUE, auth = mock_auth)

  args <- mockery::mock_args(mock_api)[[1]]
  expect_true(args$verbose)
})
