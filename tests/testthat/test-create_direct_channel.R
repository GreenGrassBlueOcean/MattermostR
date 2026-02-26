# Test suite for create_direct_channel

test_that("create_direct_channel() validates user_ids type and length", {
  # NULL user_ids
  expect_error(
    create_direct_channel(user_ids = NULL),
    "'user_ids' must be a character vector with at least 2 user IDs."
  )

  # Single user ID (too few)
  expect_error(
    create_direct_channel(user_ids = "user1"),
    "'user_ids' must be a character vector with at least 2 user IDs."
  )

  # Numeric vector (wrong type)
  expect_error(
    create_direct_channel(user_ids = c(1, 2)),
    "'user_ids' must be a character vector with at least 2 user IDs."
  )

  # Too many user IDs (> 8)
  expect_error(
    create_direct_channel(user_ids = paste0("user", 1:9)),
    "'user_ids' must contain at most 8 user IDs"
  )
})

test_that("create_direct_channel() validates auth", {
  expect_error(
    create_direct_channel(user_ids = c("u1", "u2"), auth = NULL),
    "The provided object is not a valid 'mattermost_auth' object."
  )
})

test_that("create_direct_channel() routes 2 user IDs to /channels/direct", {
  mock_auth <- structure(
    list(base_url = "https://fake-mattermost.com", headers = "Bearer faketoken"),
    class = "mattermost_auth"
  )
  mock_response <- list(id = "dm_channel_123", type = "D", name = "u1__u2")

  mockery::stub(create_direct_channel, "check_mattermost_auth", function(auth) {})
  mock_api <- mockery::mock(mock_response)
  mockery::stub(create_direct_channel, "mattermost_api_request", mock_api)

  result <- create_direct_channel(
    user_ids = c("user_id_1", "user_id_2"),
    auth = mock_auth
  )

  expect_equal(result, mock_response)
  expect_equal(result$type, "D")

  # Verify the correct endpoint was called
  call_args <- mockery::mock_args(mock_api)[[1]]
  expect_equal(call_args$endpoint, "/api/v4/channels/direct")
  expect_equal(call_args$method, "POST")
  expect_equal(call_args$body, c("user_id_1", "user_id_2"))
})

test_that("create_direct_channel() routes 3+ user IDs to /channels/group", {
  mock_auth <- structure(
    list(base_url = "https://fake-mattermost.com", headers = "Bearer faketoken"),
    class = "mattermost_auth"
  )
  mock_response <- list(id = "gm_channel_456", type = "G", name = "")

  mockery::stub(create_direct_channel, "check_mattermost_auth", function(auth) {})
  mock_api <- mockery::mock(mock_response)
  mockery::stub(create_direct_channel, "mattermost_api_request", mock_api)

  result <- create_direct_channel(
    user_ids = c("u1", "u2", "u3"),
    auth = mock_auth
  )

  expect_equal(result, mock_response)
  expect_equal(result$type, "G")

  # Verify the correct endpoint was called
  call_args <- mockery::mock_args(mock_api)[[1]]
  expect_equal(call_args$endpoint, "/api/v4/channels/group")
  expect_equal(call_args$method, "POST")
  expect_equal(call_args$body, c("u1", "u2", "u3"))
})

test_that("create_direct_channel() accepts exactly 8 user IDs (boundary)", {
  mock_auth <- structure(
    list(base_url = "https://fake-mattermost.com", headers = "Bearer faketoken"),
    class = "mattermost_auth"
  )
  mock_response <- list(id = "gm_channel_789", type = "G")

  mockery::stub(create_direct_channel, "check_mattermost_auth", function(auth) {})
  mockery::stub(create_direct_channel, "mattermost_api_request", function(...) mock_response)

  result <- create_direct_channel(
    user_ids = paste0("user", 1:8),
    auth = mock_auth
  )

  expect_equal(result$id, "gm_channel_789")
})

test_that("create_direct_channel() passes verbose to mattermost_api_request", {
  mock_auth <- structure(
    list(base_url = "https://fake-mattermost.com", headers = "Bearer faketoken"),
    class = "mattermost_auth"
  )

  mockery::stub(create_direct_channel, "check_mattermost_auth", function(auth) {})
  mock_api <- mockery::mock(list(id = "ch1"))
  mockery::stub(create_direct_channel, "mattermost_api_request", mock_api)

  create_direct_channel(
    user_ids = c("u1", "u2"),
    verbose = TRUE,
    auth = mock_auth
  )

  call_args <- mockery::mock_args(mock_api)[[1]]
  expect_true(call_args$verbose)
})
