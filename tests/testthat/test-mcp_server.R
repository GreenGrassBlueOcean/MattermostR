library(testthat)

test_that("convert_mattermost_posts_to_dataframe respects order and extracts extended metadata", {
  nested <- list(
    order = list("p2", "p1"),
    posts = list(
      p1 = list(
        id = "p1",
        create_at = 1727787754000,
        update_at = 1727787754000,
        edit_at = 0L,
        delete_at = 0L,
        is_pinned = FALSE,
        user_id = "u1",
        channel_id = "ch1",
        root_id = "",
        message = "Older post",
        type = "",
        props = list(override_username = "EdgarX Signals", from_webhook = "true")
      ),
      p2 = list(
        id = "p2",
        create_at = 1727787760000,
        update_at = 1727787760000,
        edit_at = 0L,
        delete_at = 0L,
        is_pinned = FALSE,
        user_id = "u1",
        channel_id = "ch1",
        root_id = "p1",
        message = "Newer reply",
        type = "",
        props = list()
      )
    )
  )

  df <- convert_mattermost_posts_to_dataframe(nested, include_extended = TRUE)
  expect_equal(df$id, c("p2", "p1"))
  expect_equal(df$root_id, c("p1", ""))
  expect_equal(df$override_username, c("", "EdgarX Signals"))
  expect_equal(df$from_webhook, c(FALSE, TRUE))
})

test_that("get_post and get_post_thread work and sort threads chronologically", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com", headers = "Bearer mock_token"),
    class = "mattermost_auth"
  )

  mock_post <- list(id = "p1", message = "Root message", channel_id = "ch1")
  mockery::stub(get_post, "mattermost_api_request", function(auth, endpoint, method, verbose) {
    expect_equal(endpoint, "/api/v4/posts/p1")
    mock_post
  })
  res_post <- get_post("p1", auth = mock_auth)
  expect_equal(res_post$id, "p1")

  mock_thread <- list(
    order = list("p2", "p1"),
    posts = list(
      p2 = list(
        id = "p2", create_at = 2000000, update_at = 2000000, edit_at = 0L, delete_at = 0L,
        is_pinned = FALSE, user_id = "u2", channel_id = "ch1", root_id = "p1",
        message = "Reply", type = ""
      ),
      p1 = list(
        id = "p1", create_at = 1000000, update_at = 1000000, edit_at = 0L, delete_at = 0L,
        is_pinned = FALSE, user_id = "u1", channel_id = "ch1", root_id = "",
        message = "Root", type = ""
      )
    )
  )
  mockery::stub(get_post_thread, "mattermost_api_request", function(auth, endpoint, method, verbose) {
    expect_equal(endpoint, "/api/v4/posts/p1/thread")
    mock_thread
  })
  thread_df <- get_post_thread("p1", auth = mock_auth)
  expect_equal(thread_df$id, c("p1", "p2"))
  expect_equal(thread_df$root_id, c("", "p1"))
})

test_that("delete_old_messages supports dry_run, pattern filter, and forwards auth", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com", headers = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_messages <- data.frame(
    id = c("m1", "m2", "m3"),
    create_at = as.POSIXct(
      as.numeric(c(Sys.time() - 20 * 86400, Sys.time() - 20 * 86400, Sys.time() - 1 * 86400)),
      origin = "1970-01-01", tz = "UTC"
    ),
    message = c("SPAM: Watchdog Down", "Valid signal BEAT", "SPAM: recent"),
    stringsAsFactors = FALSE
  )

  mockery::stub(delete_old_messages, "get_all_channel_posts", mock_messages)
  state <- new.env(parent = emptyenv())
  state$deleted_calls <- list()
  mockery::stub(delete_old_messages, "delete_post", function(post_id, auth) {
    state$deleted_calls[[length(state$deleted_calls) + 1L]] <- list(post_id = post_id, auth = auth)
    list(status = "OK")
  })

  dry_res <- delete_old_messages("ch1", days = 7, dry_run = TRUE, pattern = "^SPAM:", auth = mock_auth)
  expect_equal(nrow(dry_res), 1L)
  expect_equal(dry_res$message_id, "m1")
  expect_equal(dry_res$delete_status, "DRY_RUN")
  expect_length(state$deleted_calls, 0L)

  live_res <- delete_old_messages("ch1", days = 7, dry_run = FALSE, pattern = "^SPAM:", auth = mock_auth)
  expect_equal(nrow(live_res), 1L)
  expect_equal(live_res$message_id, "m1")
  expect_equal(live_res$delete_status, "OK")
  expect_length(state$deleted_calls, 1L)
  expect_identical(state$deleted_calls[[1L]]$auth, mock_auth)
})

test_that("run_mcp_stdio handles initialize, tools/list, and tools/call", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com", headers = "Bearer mock_token"),
    class = "mattermost_auth"
  )

  reqs <- c(
    '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}',
    '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}'
  )
  in_con <- textConnection(reqs, open = "r")
  out_text <- character(0)
  out_con <- textConnection("out_text", open = "w", local = TRUE)
  on.exit({
    try(close(in_con), silent = TRUE)
    try(close(out_con), silent = TRUE)
  }, add = TRUE)

  run_mcp_stdio(con = in_con, test_mode = TRUE, auth = mock_auth, silent = TRUE, out_con = out_con)
  expect_length(out_text, 2L)

  r1 <- jsonlite::fromJSON(out_text[1L], simplifyVector = FALSE)
  expect_equal(r1$result$serverInfo$name, "mattermost-ops")

  r2 <- jsonlite::fromJSON(out_text[2L], simplifyVector = FALSE)
  tool_names <- vapply(r2$result$tools, function(x) x$name, character(1))
  expect_true(all(c(
    "mm_list_channels", "mm_get_channel_posts", "mm_get_post_thread",
    "mm_search_posts", "mm_send_message", "mm_update_post",
    "mm_delete_post", "mm_purge_channel_noise"
  ) %in% tool_names))
})

test_that("mm_get_channel_posts defaults include_metadata = TRUE and mm_send_webhook aliases send_webhook_message", {
  expect_identical(mm_send_webhook, send_webhook_message)
  expect_true(isTRUE(formals(mm_get_channel_posts)$include_metadata))
  expect_equal(formals(send_webhook_message)$timeout, 10)
  expect_equal(formals(send_webhook_message)$max_tries, 3)
})

test_that(".mm_mcp_dispatch_tool subsets columns cleanly in mm_list_channels", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com", headers = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  state <- new.env(parent = emptyenv())
  state$auth <- mock_auth

  mock_dt <- data.frame(
    id = c("c1", "c2"),
    name = c("edgarx", "town-square"),
    display_name = c("EdgarX", "Town Square"),
    type = c("O", "O"),
    header = c("Alerts", "General"),
    purpose = c("SEC", "All"),
    delete_at = c(0, 0),
    extra_col = c("x", "y"),
    stringsAsFactors = FALSE
  )
  mockery::stub(.mm_mcp_dispatch_tool, "get_all_teams", function(auth) {
    data.frame(id = "t1", stringsAsFactors = FALSE)
  })
  mockery::stub(.mm_mcp_dispatch_tool, "get_team_channels", function(team_id, auth) {
    mock_dt
  })

  res <- .mm_mcp_dispatch_tool(list(name = "mm_list_channels", arguments = list()), state)
  expect_false(isTRUE(res$isError))
  parsed <- jsonlite::fromJSON(res$content[[1L]]$text)
  expect_equal(nrow(parsed), 2L)
  expect_true(all(c("id", "name", "display_name", "type", "header", "purpose") %in% names(parsed)))
  expect_false("extra_col" %in% names(parsed))
})

test_that(".mm_mcp_resolve_channel_id matches name, #name, and display_name", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com", headers = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  mock_channels <- data.frame(
    id = c("w3pjpw43pjruzxgqzpcq4pzmxc", "k5rh53rwo3bgfpynpme33tnfgc"),
    name = c("edgarx", "town-square"),
    display_name = c("EdgarX", "Town Square"),
    stringsAsFactors = FALSE
  )
  mockery::stub(.mm_mcp_resolve_channel_id, "get_all_teams", function(auth) {
    data.frame(id = "t1", stringsAsFactors = FALSE)
  })
  mockery::stub(.mm_mcp_resolve_channel_id, "get_team_channels", function(team_id, auth) {
    mock_channels
  })

  expect_equal(
    .mm_mcp_resolve_channel_id(channel_name = "edgarx", auth = mock_auth),
    "w3pjpw43pjruzxgqzpcq4pzmxc"
  )
  expect_equal(
    .mm_mcp_resolve_channel_id(channel_name = "#edgarx", auth = mock_auth),
    "w3pjpw43pjruzxgqzpcq4pzmxc"
  )
  expect_equal(
    .mm_mcp_resolve_channel_id(channel_name = "EdgarX", auth = mock_auth),
    "w3pjpw43pjruzxgqzpcq4pzmxc"
  )
})


