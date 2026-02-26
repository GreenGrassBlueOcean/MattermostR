# --- Helper: build a fake API response with N posts ---
make_fake_posts_response <- function(n, channel_id = "channel1") {
  posts <- lapply(seq_len(n), function(i) {
    list(
      id = as.character(i),
      create_at = 1727787754562 + (i * 1000),
      update_at = 1727787754562 + (i * 1000),
      edit_at = 0L,
      delete_at = 0L,
      is_pinned = FALSE,
      user_id = paste0("user", i),
      channel_id = channel_id,
      message = paste0("Message ", i),
      type = "text"
    )
  })
  names(posts) <- as.character(seq_len(n))
  list(posts = posts)
}

# =============================================================================
# Input validation
# =============================================================================

test_that("get_channel_posts() rejects NULL channel_id", {
  expect_error(
    get_channel_posts(channel_id = NULL),
    "channel_id cannot be empty or NULL"
  )
})

test_that("get_channel_posts() rejects empty string channel_id", {
  expect_error(
    get_channel_posts(channel_id = ""),
    "channel_id cannot be empty or NULL"
  )
})

test_that("get_channel_posts() rejects invalid auth object", {
  expect_error(
    get_channel_posts(channel_id = "channel1", auth = NULL),
    "The provided object is not a valid 'mattermost_auth' object."
  )
})

test_that("get_channel_posts() rejects per_page out of range", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com", headers = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  expect_error(
    get_channel_posts(channel_id = "ch1", per_page = 0, auth = mock_auth),
    "per_page must be between 1 and 200"
  )
  expect_error(
    get_channel_posts(channel_id = "ch1", per_page = 201, auth = mock_auth),
    "per_page must be between 1 and 200"
  )
})

test_that("get_channel_posts() rejects negative page", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com", headers = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  expect_error(
    get_channel_posts(channel_id = "ch1", page = -1, auth = mock_auth),
    "page must be 0 or greater"
  )
})

test_that("get_channel_posts() rejects since with non-default page/per_page", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com", headers = "Bearer mock_token"),
    class = "mattermost_auth"
  )
  expect_error(
    get_channel_posts(channel_id = "ch1", page = 1, since = 1000, auth = mock_auth),
    "cannot be combined"
  )
  expect_error(
    get_channel_posts(channel_id = "ch1", per_page = 100, since = 1000, auth = mock_auth),
    "cannot be combined"
  )
})

# =============================================================================
# Successful requests — default pagination
# =============================================================================

test_that("get_channel_posts() sends correct default endpoint with page/per_page", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com", headers = "Bearer mock_token"),
    class = "mattermost_auth"
  )

  mock_api <- mockery::mock(make_fake_posts_response(2))
  mockery::stub(get_channel_posts, "mattermost_api_request", mock_api)

  result <- get_channel_posts(channel_id = "channel1", auth = mock_auth)

  mockery::expect_called(mock_api, 1)
  call_args <- mockery::mock_args(mock_api)[[1]]
  expect_equal(call_args$endpoint, "/api/v4/channels/channel1/posts?page=0&per_page=60")
  expect_equal(call_args$method, "GET")
  expect_equal(nrow(result), 2)
  expect_true(is.data.frame(result))
})

test_that("get_channel_posts() sends correct endpoint with custom page/per_page", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com", headers = "Bearer mock_token"),
    class = "mattermost_auth"
  )

  mock_api <- mockery::mock(make_fake_posts_response(5))
  mockery::stub(get_channel_posts, "mattermost_api_request", mock_api)

  result <- get_channel_posts(channel_id = "ch42", page = 3, per_page = 200, auth = mock_auth)

  call_args <- mockery::mock_args(mock_api)[[1]]
  expect_equal(call_args$endpoint, "/api/v4/channels/ch42/posts?page=3&per_page=200")
  expect_equal(nrow(result), 5)
})

test_that("get_channel_posts() passes verbose through", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com", headers = "Bearer mock_token"),
    class = "mattermost_auth"
  )

  mock_api <- mockery::mock(make_fake_posts_response(1))
  mockery::stub(get_channel_posts, "mattermost_api_request", mock_api)

  get_channel_posts(channel_id = "ch1", verbose = TRUE, auth = mock_auth)

  call_args <- mockery::mock_args(mock_api)[[1]]
  expect_true(call_args$verbose)
})

# =============================================================================
# since parameter
# =============================================================================

test_that("get_channel_posts() uses since parameter (numeric ms)", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com", headers = "Bearer mock_token"),
    class = "mattermost_auth"
  )

  mock_api <- mockery::mock(make_fake_posts_response(3))
  mockery::stub(get_channel_posts, "mattermost_api_request", mock_api)

  result <- get_channel_posts(channel_id = "ch1", since = 1727787754562, auth = mock_auth)

  call_args <- mockery::mock_args(mock_api)[[1]]
  expect_equal(call_args$endpoint, "/api/v4/channels/ch1/posts?since=1727787754562")
  expect_equal(nrow(result), 3)
})

test_that("get_channel_posts() uses since parameter (POSIXct)", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com", headers = "Bearer mock_token"),
    class = "mattermost_auth"
  )

  mock_api <- mockery::mock(make_fake_posts_response(1))
  mockery::stub(get_channel_posts, "mattermost_api_request", mock_api)

  ts <- as.POSIXct("2024-10-01 12:00:00", tz = "UTC")
  result <- get_channel_posts(channel_id = "ch1", since = ts, auth = mock_auth)

  call_args <- mockery::mock_args(mock_api)[[1]]
  expected_ms <- as.numeric(ts) * 1000
  expect_equal(call_args$endpoint, paste0("/api/v4/channels/ch1/posts?since=", expected_ms))
})

test_that("get_channel_posts() uses since parameter (character date)", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com", headers = "Bearer mock_token"),
    class = "mattermost_auth"
  )

  mock_api <- mockery::mock(make_fake_posts_response(1))
  mockery::stub(get_channel_posts, "mattermost_api_request", mock_api)

  result <- get_channel_posts(channel_id = "ch1", since = "2024-10-01", auth = mock_auth)

  call_args <- mockery::mock_args(mock_api)[[1]]
  expected_ms <- as.numeric(as.POSIXct("2024-10-01", tz = "UTC")) * 1000
  expect_equal(call_args$endpoint, paste0("/api/v4/channels/ch1/posts?since=", expected_ms))
})

test_that("get_channel_posts() uses since parameter (Date)", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com", headers = "Bearer mock_token"),
    class = "mattermost_auth"
  )

  mock_api <- mockery::mock(make_fake_posts_response(1))
  mockery::stub(get_channel_posts, "mattermost_api_request", mock_api)

  result <- get_channel_posts(channel_id = "ch1", since = as.Date("2024-10-01"), auth = mock_auth)

  call_args <- mockery::mock_args(mock_api)[[1]]
  expected_ms <- as.numeric(as.POSIXct(as.Date("2024-10-01"), tz = "UTC")) * 1000
  expect_equal(call_args$endpoint, paste0("/api/v4/channels/ch1/posts?since=", expected_ms))
})

# =============================================================================
# convert_since_to_ms validation
# =============================================================================

test_that("convert_since_to_ms() rejects invalid types", {
  expect_error(convert_since_to_ms(TRUE), "must be a POSIXct")
  expect_error(convert_since_to_ms(list()), "must be a POSIXct")
})

test_that("convert_since_to_ms() rejects invalid date strings", {
  expect_error(convert_since_to_ms("not-a-date"), "Invalid 'since' date format")
})

# =============================================================================
# Pagination warning
# =============================================================================

test_that("get_channel_posts() warns when result count equals per_page", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com", headers = "Bearer mock_token"),
    class = "mattermost_auth"
  )

  # Return exactly per_page posts (using per_page = 5 for ease)
  mock_api <- mockery::mock(make_fake_posts_response(5))
  mockery::stub(get_channel_posts, "mattermost_api_request", mock_api)

  expect_warning(
    get_channel_posts(channel_id = "ch1", per_page = 5, auth = mock_auth),
    "matches the 'per_page' limit"
  )
})

test_that("get_channel_posts() does NOT warn when result count < per_page", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com", headers = "Bearer mock_token"),
    class = "mattermost_auth"
  )

  mock_api <- mockery::mock(make_fake_posts_response(3))
  mockery::stub(get_channel_posts, "mattermost_api_request", mock_api)

  expect_no_warning(
    get_channel_posts(channel_id = "ch1", per_page = 60, auth = mock_auth)
  )
})

test_that("get_channel_posts() does NOT warn when using since mode", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com", headers = "Bearer mock_token"),
    class = "mattermost_auth"
  )

  # Even if 60 posts returned (matching default per_page), since mode skips warning
  mock_api <- mockery::mock(make_fake_posts_response(60))
  mockery::stub(get_channel_posts, "mattermost_api_request", mock_api)

  expect_no_warning(
    get_channel_posts(channel_id = "ch1", since = 1000, auth = mock_auth)
  )
})

# =============================================================================
# Data frame conversion (preserved from original tests)
# =============================================================================

test_that("get_channel_posts() returns correct data frame structure", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com", headers = "Bearer mock_token"),
    class = "mattermost_auth"
  )

  fake_response <- list(posts = list(
    list(id = "1", create_at = 1727787754562, update_at = 1727787754562,
         edit_at = 0L, delete_at = 0L, is_pinned = FALSE,
         user_id = "user1", channel_id = "channel1",
         message = "Hello, World!", type = "text"),
    list(id = "2", create_at = 1727787758206, update_at = 1727787758206,
         edit_at = 1727787760000, delete_at = 0L, is_pinned = TRUE,
         user_id = "user2", channel_id = "channel1",
         message = "This is a test post.", type = "text")
  ))

  mock_api <- mockery::mock(fake_response)
  mockery::stub(get_channel_posts, "mattermost_api_request", mock_api)

  result <- get_channel_posts(channel_id = "channel1", auth = mock_auth)

  expect_equal(nrow(result), 2)
  expect_equal(result$id, c("1", "2"))
  expect_equal(result$message, c("Hello, World!", "This is a test post."))
  expect_true(inherits(result$create_at, "POSIXct"))
  expect_equal(result$is_pinned, c(FALSE, TRUE))
  # edit_at = 0 should become NA
  expect_true(is.na(result$edit_at[1]))
  expect_false(is.na(result$edit_at[2]))
})

test_that("get_channel_posts() returns empty data frame when no posts", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com", headers = "Bearer mock_token"),
    class = "mattermost_auth"
  )

  mock_api <- mockery::mock(list(posts = list()))
  mockery::stub(get_channel_posts, "mattermost_api_request", mock_api)

  result <- get_channel_posts(channel_id = "ch1", auth = mock_auth)
  expect_equal(nrow(result), 0)
  expect_true(is.data.frame(result))
})

# =============================================================================
# Error propagation
# =============================================================================

test_that("get_channel_posts() propagates API errors", {
  mock_auth <- structure(
    list(base_url = "https://mock.mattermost.com", headers = "Bearer mock_token"),
    class = "mattermost_auth"
  )

  mock_api <- mockery::mock(stop("Channel not found"))
  mockery::stub(get_channel_posts, "mattermost_api_request", mock_api)

  expect_error(
    get_channel_posts(channel_id = "invalid-channel", auth = mock_auth),
    "Channel not found"
  )
})
