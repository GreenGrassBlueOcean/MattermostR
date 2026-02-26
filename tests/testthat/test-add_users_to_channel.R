library(testthat)
library(mockery)

mock_auth <- structure(
  list(base_url = "https://fake-mattermost.com", headers = "Bearer faketoken"),
  class = "mattermost_auth"
)

# --- Input validation ---

test_that("add_users_to_channel() rejects NULL channel_id", {
  expect_error(
    add_users_to_channel(channel_id = NULL, user_ids = "u1", auth = mock_auth),
    "channel_id cannot be empty or NULL"
  )
})

test_that("add_users_to_channel() rejects empty user_ids", {
  expect_error(
    add_users_to_channel("c1", user_ids = character(0), auth = mock_auth),
    "user_ids must be a non-empty character vector"
  )
})

test_that("add_users_to_channel() rejects non-character user_ids", {
  expect_error(
    add_users_to_channel("c1", user_ids = 123, auth = mock_auth),
    "user_ids must be a non-empty character vector"
  )
})

test_that("add_users_to_channel() rejects > 1000 user_ids", {
  expect_error(
    add_users_to_channel("c1", user_ids = paste0("u", seq_len(1001)), auth = mock_auth),
    "maximum of 1000 users"
  )
})

test_that("add_users_to_channel() rejects invalid auth", {
  expect_error(
    add_users_to_channel("c1", user_ids = "u1", auth = NULL),
    "not a valid 'mattermost_auth' object"
  )
})

# --- Batch add with resolve_names = FALSE (default) ---

test_that("add_users_to_channel() sends single POST with user_ids body", {
  stub(add_users_to_channel, "check_mattermost_auth", function(auth) {})

  api_mock <- mockery::mock(list(channel_id = "c1"))
  stub(add_users_to_channel, "mattermost_api_request", api_mock)

  ids <- c("u1", "u2", "u3")

  expect_message(
    result <- add_users_to_channel("c1", ids, auth = mock_auth),
    "Success: 3 user\\(s\\) added to channel 'c1'"
  )

  # Exactly 1 API call

  expect_called(api_mock, 1)

  # Verify the call arguments
  call_args <- mockery::mock_args(api_mock)[[1]]
  expect_equal(call_args$method, "POST")
  expect_true(grepl("/members$", call_args$endpoint))
  expect_equal(call_args$body, list(user_ids = ids))
})

# --- Batch add with resolve_names = TRUE ---

test_that("add_users_to_channel() with resolve_names = TRUE resolves names", {
  stub(add_users_to_channel, "check_mattermost_auth", function(auth) {})

  # First call: add members. Second call: batch user lookup.
  api_mock <- mockery::mock(
    list(channel_id = "c1"),                                      # add members
    data.frame(id = c("u1", "u2"), username = c("alice", "bob"),  # user lookup
               stringsAsFactors = FALSE)
  )
  stub(add_users_to_channel, "mattermost_api_request", api_mock)

  stub(add_users_to_channel, "get_channel_info", function(channel_id, verbose, auth) {
    list(display_name = "Town Square")
  })

  expect_message(
    result <- add_users_to_channel("c1", c("u1", "u2"),
                                   resolve_names = TRUE, auth = mock_auth),
    "Success: 2 user\\(s\\) added to channel 'Town Square': alice, bob"
  )

  # 2 calls to mattermost_api_request (add + user lookup)
  expect_called(api_mock, 2)
})

test_that("add_users_to_channel() with resolve_names = TRUE truncates > 5 names", {
  stub(add_users_to_channel, "check_mattermost_auth", function(auth) {})

  users_df <- data.frame(
    id = paste0("u", 1:7),
    username = paste0("user", 1:7),
    stringsAsFactors = FALSE
  )

  api_mock <- mockery::mock(
    list(channel_id = "c1"),
    users_df
  )
  stub(add_users_to_channel, "mattermost_api_request", api_mock)
  stub(add_users_to_channel, "get_channel_info", function(channel_id, verbose, auth) {
    list(display_name = "General")
  })

  expect_message(
    add_users_to_channel("c1", paste0("u", 1:7),
                         resolve_names = TRUE, auth = mock_auth),
    "\\.\\.\\."
  )
})

test_that("add_users_to_channel() with resolve_names = TRUE falls back to user_ids when lookup returns unexpected format", {
  stub(add_users_to_channel, "check_mattermost_auth", function(auth) {})

  # First call: add members. Second call: user lookup returns list without username column.
  api_mock <- mockery::mock(
    list(channel_id = "c1"),                                         # add members
    list(id = c("u1", "u2"), email = c("a@b.com", "c@d.com"))       # no username column
  )
  stub(add_users_to_channel, "mattermost_api_request", api_mock)

  stub(add_users_to_channel, "get_channel_info", function(channel_id, verbose, auth) {
    list(display_name = "General")
  })

  # Should fall back to raw user_ids in the message
  expect_message(
    add_users_to_channel("c1", c("u1", "u2"),
                         resolve_names = TRUE, auth = mock_auth),
    "Success: 2 user\\(s\\) added to channel 'General': u1, u2"
  )
})

# --- Error propagation ---

test_that("add_users_to_channel() propagates API errors", {
  stub(add_users_to_channel, "check_mattermost_auth", function(auth) {})

  stub(add_users_to_channel, "mattermost_api_request", function(...) {
    stop("403 Forbidden")
  })

  expect_error(
    add_users_to_channel("c1", c("u1", "u2"), auth = mock_auth),
    "403 Forbidden"
  )
})
