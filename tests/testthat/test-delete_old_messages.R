# =============================================================================
# delete_old_messages() — input validation
# =============================================================================

test_that("delete_old_messages() rejects NULL channel_id", {
  expect_error(
    delete_old_messages(channel_id = NULL, days = 7),
    "channel_id cannot be empty or NULL"
  )
})

test_that("delete_old_messages() rejects invalid auth", {
  expect_error(
    delete_old_messages(channel_id = "ch1", days = 7, auth = NULL),
    "The provided object is not a valid 'mattermost_auth' object."
  )
})

# =============================================================================
# delete_old_messages() — core behaviour
# =============================================================================

test_that("delete_old_messages() deletes messages older than cutoff", {
  mock_messages <- data.frame(
    id = c("msg1", "msg2", "msg3"),
    create_at = as.POSIXct(
      as.numeric(c(Sys.time() - 10 * 86400, Sys.time() - 16 * 86400, Sys.time() - 20 * 86400)),
      origin = "1970-01-01", tz = "UTC"
    ),
    stringsAsFactors = FALSE
  )

  mockery::stub(delete_old_messages, "get_all_channel_posts", mock_messages)
  mockery::stub(delete_old_messages, "delete_post", function(post_id) list(status = "OK"))
  mockery::stub(delete_old_messages, "check_mattermost_auth", function(auth) {})

  # msg2 (16 days) and msg3 (20 days) should be deleted; msg1 (10 days) kept

  result <- delete_old_messages("channel_id", 15)

  expect_equal(
    result,
    structure(
      list(message_id = c("msg2", "msg3"), delete_status = c("OK", "OK")),
      class = "data.frame", row.names = c(NA, -2L)
    )
  )
})

test_that("delete_old_messages() returns empty data.frame when no old messages", {
  mock_messages <- data.frame(
    id = c("msg1", "msg2", "msg3"),
    create_at = as.POSIXct(
      as.numeric(c(Sys.time() - 10 * 86400, Sys.time() - 16 * 86400, Sys.time() - 20 * 86400)),
      origin = "1970-01-01", tz = "UTC"
    ),
    stringsAsFactors = FALSE
  )

  mockery::stub(delete_old_messages, "get_all_channel_posts", mock_messages)
  mockery::stub(delete_old_messages, "delete_post", function(post_id) list(status = "OK"))
  mockery::stub(delete_old_messages, "check_mattermost_auth", function(auth) {})

  expect_message(
    result <- delete_old_messages("channel_id", 30),
    "No messages older than 30 days"
  )
  expect_equal(result, data.frame())
})

test_that("delete_old_messages() returns empty data.frame for empty channel", {
  mockery::stub(delete_old_messages, "get_all_channel_posts", data.frame())
  mockery::stub(delete_old_messages, "check_mattermost_auth", function(auth) {})

  expect_message(
    result <- delete_old_messages("channel_id", 7),
    "No messages older than 7 days"
  )
  expect_equal(result, data.frame())
})

# =============================================================================
# get_all_channel_posts() — delegates to paginate_api()
# =============================================================================

test_that("get_all_channel_posts() passes correct endpoint and transform to paginate_api()", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com", headers = "Bearer mock_token"),
    class = "mattermost_auth"
  )

  captured_args <- NULL
  mockery::stub(get_all_channel_posts, "paginate_api", function(auth, endpoint, per_page, transform) {
    captured_args <<- list(endpoint = endpoint, per_page = per_page, transform = transform)
    data.frame(id = "p1", create_at = Sys.time(), stringsAsFactors = FALSE)
  })

  result <- get_all_channel_posts(channel_id = "ch1", auth = mock_auth)

  expect_equal(captured_args$endpoint, "/api/v4/channels/ch1/posts")
  expect_equal(captured_args$per_page, 200)
  expect_true(is.function(captured_args$transform))
  expect_true(is.data.frame(result))
})

test_that("get_all_channel_posts() returns empty data.frame from paginate_api()", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com", headers = "Bearer mock_token"),
    class = "mattermost_auth"
  )

  mockery::stub(get_all_channel_posts, "paginate_api", function(...) data.frame())

  result <- get_all_channel_posts(channel_id = "ch1", auth = mock_auth)

  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 0)
})
