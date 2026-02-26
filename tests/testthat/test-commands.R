# ---------- create_command() ----------

test_that("create_command() requires team_id, trigger, and url", {
  expect_error(create_command(team_id = NULL, trigger = "t", url = "http://x"), "team_id")
  expect_error(create_command(team_id = "t1", trigger = NULL, url = "http://x"), "trigger")
  expect_error(create_command(team_id = "t1", trigger = "t",  url = NULL),       "url")
  expect_error(create_command(team_id = "",   trigger = "t",  url = "http://x"), "team_id")
  expect_error(create_command(team_id = "t1", trigger = "",   url = "http://x"), "trigger")
  expect_error(create_command(team_id = "t1", trigger = "t",  url = ""),         "url")
})

test_that("create_command() validates auth", {
  expect_error(create_command("t1", "t", "http://x", auth = "bad"), "mattermost_auth")
})

test_that("create_command() validates method argument", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mockery::stub(create_command, "check_mattermost_auth", function(auth) {})

  expect_error(create_command("t1", "t", "http://x", method = "X", auth = mock_auth),
               "'arg' should be one of")
})

test_that("create_command() constructs correct POST request with defaults", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_response <- list(id = "cmd1", token = "tok123", team_id = "t1",
                        trigger = "pnl", method = "P", url = "http://x")
  mock_api <- mockery::mock(mock_response)
  mockery::stub(create_command, "mattermost_api_request", mock_api)
  mockery::stub(create_command, "check_mattermost_auth", function(auth) {})

  result <- create_command("t1", "pnl", "http://x", auth = mock_auth)

  expect_equal(result, mock_response)
  args <- mockery::mock_args(mock_api)[[1]]
  expect_equal(args$endpoint, "/api/v4/commands")
  expect_equal(args$method, "POST")
  expect_equal(args$body$team_id, "t1")
  expect_equal(args$body$trigger, "pnl")
  expect_equal(args$body$url, "http://x")
  expect_equal(args$body$method, "P")
  # auto_complete defaults to FALSE, so should not appear in body
  expect_null(args$body$auto_complete)
})

test_that("create_command() includes optional fields when provided", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_api <- mockery::mock(list())
  mockery::stub(create_command, "mattermost_api_request", mock_api)
  mockery::stub(create_command, "check_mattermost_auth", function(auth) {})

  create_command("t1", "pnl", "http://x", method = "G",
                 auto_complete = TRUE, auto_complete_desc = "Show PnL",
                 auto_complete_hint = "[TICKER]", display_name = "PnL",
                 description = "Get PnL", username = "pnl-bot",
                 icon_url = "http://icon.png", auth = mock_auth)

  args <- mockery::mock_args(mock_api)[[1]]
  expect_equal(args$body$method, "G")
  expect_true(args$body$auto_complete)
  expect_equal(args$body$auto_complete_desc, "Show PnL")
  expect_equal(args$body$auto_complete_hint, "[TICKER]")
  expect_equal(args$body$display_name, "PnL")
  expect_equal(args$body$description, "Get PnL")
  expect_equal(args$body$username, "pnl-bot")
  expect_equal(args$body$icon_url, "http://icon.png")
})

test_that("create_command() passes verbose flag", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_api <- mockery::mock(list())
  mockery::stub(create_command, "mattermost_api_request", mock_api)
  mockery::stub(create_command, "check_mattermost_auth", function(auth) {})

  create_command("t1", "t", "http://x", verbose = TRUE, auth = mock_auth)

  args <- mockery::mock_args(mock_api)[[1]]
  expect_true(args$verbose)
})


# ---------- get_command() ----------

test_that("get_command() requires command_id", {
  expect_error(get_command(command_id = NULL), "command_id")
  expect_error(get_command(command_id = ""),   "command_id")
})

test_that("get_command() validates auth", {
  expect_error(get_command("c1", auth = "bad"), "mattermost_auth")
})

test_that("get_command() constructs correct GET request", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_response <- list(id = "c1", trigger = "test")
  mock_api <- mockery::mock(mock_response)
  mockery::stub(get_command, "mattermost_api_request", mock_api)
  mockery::stub(get_command, "check_mattermost_auth", function(auth) {})

  result <- get_command("c1", auth = mock_auth)

  expect_equal(result, mock_response)
  args <- mockery::mock_args(mock_api)[[1]]
  expect_equal(args$endpoint, "/api/v4/commands/c1")
  expect_equal(args$method, "GET")
})

test_that("get_command() passes verbose flag", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_api <- mockery::mock(list())
  mockery::stub(get_command, "mattermost_api_request", mock_api)
  mockery::stub(get_command, "check_mattermost_auth", function(auth) {})

  get_command("c1", verbose = TRUE, auth = mock_auth)

  args <- mockery::mock_args(mock_api)[[1]]
  expect_true(args$verbose)
})


# ---------- list_commands() ----------

test_that("list_commands() requires team_id", {
  expect_error(list_commands(team_id = NULL), "team_id")
  expect_error(list_commands(team_id = ""),   "team_id")
})

test_that("list_commands() validates auth", {
  expect_error(list_commands("t1", auth = "bad"), "mattermost_auth")
})

test_that("list_commands() constructs correct GET request with defaults", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_api <- mockery::mock(data.frame())
  mockery::stub(list_commands, "mattermost_api_request", mock_api)
  mockery::stub(list_commands, "check_mattermost_auth", function(auth) {})

  list_commands("t1", auth = mock_auth)

  args <- mockery::mock_args(mock_api)[[1]]
  expect_equal(args$endpoint, "/api/v4/commands?team_id=t1")
  expect_equal(args$method, "GET")
})

test_that("list_commands() appends custom_only when TRUE", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_api <- mockery::mock(data.frame())
  mockery::stub(list_commands, "mattermost_api_request", mock_api)
  mockery::stub(list_commands, "check_mattermost_auth", function(auth) {})

  list_commands("t1", custom_only = TRUE, auth = mock_auth)

  args <- mockery::mock_args(mock_api)[[1]]
  expect_true(grepl("custom_only=true", args$endpoint))
})

test_that("list_commands() does not append custom_only when FALSE", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_api <- mockery::mock(data.frame())
  mockery::stub(list_commands, "mattermost_api_request", mock_api)
  mockery::stub(list_commands, "check_mattermost_auth", function(auth) {})

  list_commands("t1", custom_only = FALSE, auth = mock_auth)

  args <- mockery::mock_args(mock_api)[[1]]
  expect_false(grepl("custom_only", args$endpoint))
})

test_that("list_commands() passes verbose flag", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_api <- mockery::mock(data.frame())
  mockery::stub(list_commands, "mattermost_api_request", mock_api)
  mockery::stub(list_commands, "check_mattermost_auth", function(auth) {})

  list_commands("t1", verbose = TRUE, auth = mock_auth)

  args <- mockery::mock_args(mock_api)[[1]]
  expect_true(args$verbose)
})


# ---------- update_command() ----------

test_that("update_command() requires command_id and body", {
  expect_error(update_command(command_id = NULL, body = list()), "command_id")
  expect_error(update_command(command_id = "c1", body = NULL),   "body")
  expect_error(update_command(command_id = "",   body = list()), "command_id")
})

test_that("update_command() validates auth", {
  expect_error(update_command("c1", list(trigger = "x"), auth = "bad"), "mattermost_auth")
})

test_that("update_command() rejects non-list body", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mockery::stub(update_command, "check_mattermost_auth", function(auth) {})

  expect_error(update_command("c1", "not a list", auth = mock_auth),
               "body must be a named list")
})

test_that("update_command() constructs correct PUT request", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  cmd_body <- list(id = "c1", team_id = "t1", trigger = "pnl",
                   url = "http://x", method = "P", description = "Updated")
  mock_response <- cmd_body
  mock_api <- mockery::mock(mock_response)
  mockery::stub(update_command, "mattermost_api_request", mock_api)
  mockery::stub(update_command, "check_mattermost_auth", function(auth) {})

  result <- update_command("c1", body = cmd_body, auth = mock_auth)

  expect_equal(result, mock_response)
  args <- mockery::mock_args(mock_api)[[1]]
  expect_equal(args$endpoint, "/api/v4/commands/c1")
  expect_equal(args$method, "PUT")
  expect_equal(args$body, cmd_body)
})

test_that("update_command() passes verbose flag", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_api <- mockery::mock(list())
  mockery::stub(update_command, "mattermost_api_request", mock_api)
  mockery::stub(update_command, "check_mattermost_auth", function(auth) {})

  update_command("c1", body = list(trigger = "x"), verbose = TRUE, auth = mock_auth)

  args <- mockery::mock_args(mock_api)[[1]]
  expect_true(args$verbose)
})


# ---------- delete_command() ----------

test_that("delete_command() requires command_id", {
  expect_error(delete_command(command_id = NULL), "command_id")
  expect_error(delete_command(command_id = ""),   "command_id")
})

test_that("delete_command() validates auth", {
  expect_error(delete_command("c1", auth = "bad"), "mattermost_auth")
})

test_that("delete_command() constructs correct DELETE request", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_response <- list(status = "OK")
  mock_api <- mockery::mock(mock_response)
  mockery::stub(delete_command, "mattermost_api_request", mock_api)
  mockery::stub(delete_command, "check_mattermost_auth", function(auth) {})

  result <- delete_command("c1", auth = mock_auth)

  expect_equal(result, mock_response)
  args <- mockery::mock_args(mock_api)[[1]]
  expect_equal(args$endpoint, "/api/v4/commands/c1")
  expect_equal(args$method, "DELETE")
})

test_that("delete_command() passes verbose flag", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_api <- mockery::mock(list())
  mockery::stub(delete_command, "mattermost_api_request", mock_api)
  mockery::stub(delete_command, "check_mattermost_auth", function(auth) {})

  delete_command("c1", verbose = TRUE, auth = mock_auth)

  args <- mockery::mock_args(mock_api)[[1]]
  expect_true(args$verbose)
})


# ---------- execute_command() ----------

test_that("execute_command() requires channel_id and command", {
  expect_error(execute_command(channel_id = NULL, command = "/test"), "channel_id")
  expect_error(execute_command(channel_id = "ch1", command = NULL),   "command")
  expect_error(execute_command(channel_id = "",    command = "/test"), "channel_id")
  expect_error(execute_command(channel_id = "ch1", command = ""),     "command")
})

test_that("execute_command() validates auth", {
  expect_error(execute_command("ch1", "/test", auth = "bad"), "mattermost_auth")
})

test_that("execute_command() constructs correct POST request", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_response <- list(ResponseType = "in_channel", Text = "Result")
  mock_api <- mockery::mock(mock_response)
  mockery::stub(execute_command, "mattermost_api_request", mock_api)
  mockery::stub(execute_command, "check_mattermost_auth", function(auth) {})

  result <- execute_command("ch1", "/pnl AAPL", auth = mock_auth)

  expect_equal(result, mock_response)
  args <- mockery::mock_args(mock_api)[[1]]
  expect_equal(args$endpoint, "/api/v4/commands/execute")
  expect_equal(args$method, "POST")
  expect_equal(args$body$channel_id, "ch1")
  expect_equal(args$body$command, "/pnl AAPL")
})

test_that("execute_command() passes verbose flag", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_api <- mockery::mock(list())
  mockery::stub(execute_command, "mattermost_api_request", mock_api)
  mockery::stub(execute_command, "check_mattermost_auth", function(auth) {})

  execute_command("ch1", "/test", verbose = TRUE, auth = mock_auth)

  args <- mockery::mock_args(mock_api)[[1]]
  expect_true(args$verbose)
})


# ---------- regen_command_token() ----------

test_that("regen_command_token() requires command_id", {
  expect_error(regen_command_token(command_id = NULL), "command_id")
  expect_error(regen_command_token(command_id = ""),   "command_id")
})

test_that("regen_command_token() validates auth", {
  expect_error(regen_command_token("c1", auth = "bad"), "mattermost_auth")
})

test_that("regen_command_token() constructs correct PUT request", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_response <- list(token = "new_token_xyz")
  mock_api <- mockery::mock(mock_response)
  mockery::stub(regen_command_token, "mattermost_api_request", mock_api)
  mockery::stub(regen_command_token, "check_mattermost_auth", function(auth) {})

  result <- regen_command_token("c1", auth = mock_auth)

  expect_equal(result, mock_response)
  args <- mockery::mock_args(mock_api)[[1]]
  expect_equal(args$endpoint, "/api/v4/commands/c1/regen_token")
  expect_equal(args$method, "PUT")
})

test_that("regen_command_token() passes verbose flag", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com",
         headers  = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_api <- mockery::mock(list())
  mockery::stub(regen_command_token, "mattermost_api_request", mock_api)
  mockery::stub(regen_command_token, "check_mattermost_auth", function(auth) {})

  regen_command_token("c1", verbose = TRUE, auth = mock_auth)

  args <- mockery::mock_args(mock_api)[[1]]
  expect_true(args$verbose)
})
