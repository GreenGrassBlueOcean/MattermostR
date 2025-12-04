library(testthat)
library(mockery)

# Define a mock 'mattermost_auth' object
mock_auth <- structure(
  list(
    base_url = "https://fake-mattermost.com",
    headers = "Bearer faketoken"
  ),
  class = "mattermost_auth"
)

# Helper function to create mock search response
# Note: Timestamps are numeric (no L suffix) to emulate JSON doubles and avoid integer overflow
create_mock_search_response <- function(post_count = 2) {
  posts <- list()
  for (i in 1:post_count) {
    posts[[paste0("post", i)]] <- list(
      id = paste0("post", i),
      create_at = 1727787754562 + (i - 1) * 1000,
      update_at = 1727787754562 + (i - 1) * 1000,
      edit_at = if (i == 2) 1727787760000 else 0,
      delete_at = 0,
      is_pinned = i == 2,
      user_id = paste0("user", i),
      channel_id = paste0("channel", i),
      message = paste("Test message", i),
      type = "text"
    )
  }
  return(list(posts = posts, order = names(posts)))
}

test_that("search_posts() requires terms parameter", {
  expect_error(
    search_posts(terms = NULL, auth = mock_auth),
    "terms cannot be empty or NULL"
  )
})

test_that("search_posts() validates pagination parameters", {
  stub(search_posts, "check_mattermost_auth", function(auth) {})

  expect_error(
    search_posts(terms = "test", per_page = 0, auth = mock_auth),
    "per_page must be between 1 and 200"
  )
  expect_error(
    search_posts(terms = "test", per_page = 201, auth = mock_auth),
    "per_page must be between 1 and 200"
  )
  expect_error(
    search_posts(terms = "test", page = -1, auth = mock_auth),
    "page must be 0 or greater"
  )
})

test_that("search_posts() handles valid responses correctly", {
  stub(search_posts, "check_mattermost_auth", function(auth) {})

  mock_response <- create_mock_search_response(2)
  stub(search_posts, "mattermost_api_request", function(auth, endpoint, method, body, verbose) {
    expect_equal(endpoint, "/api/v4/posts/search")
    expect_equal(method, "POST")
    return(mock_response)
  })

  result <- search_posts(terms = "test query", auth = mock_auth)

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 2)
  expect_true(inherits(result$create_at, "POSIXct"))
})

test_that("search_posts() handles integer overflow in timestamps", {
  stub(search_posts, "check_mattermost_auth", function(auth) {})

  # 3000000000000 is ~ year 2065, definitely overflows 32-bit integer
  mock_response <- list(
    posts = list(p1 = list(id="p1", create_at=3000000000000, message="future")),
    order = list("p1")
  )

  stub(search_posts, "mattermost_api_request", function(...) {
    return(mock_response)
  })

  result <- search_posts("test", auth = mock_auth)

  expect_false(is.na(result$create_at[1]))
  expect_true(inherits(result$create_at, "POSIXct"))
})

test_that("search_posts() provides diagnostics on empty results (verbose)", {
  stub(search_posts, "check_mattermost_auth", function(auth) {})

  # API returns empty
  stub(search_posts, "mattermost_api_request", function(...) {
    return(list(posts = list(), order = list()))
  })

  # Expect hint about team_id if team_id is NULL
  expect_message(
    search_posts("test", team_id = NULL, verbose = TRUE, auth = mock_auth),
    "Try providing a 'team_id'"
  )

  # Expect hint about joining channel if team_id IS provided
  expect_message(
    search_posts("test", team_id = "team1", verbose = TRUE, auth = mock_auth),
    "Ensure the bot user has JOINED"
  )
})

test_that("search_posts() warns about pagination limits", {
  stub(search_posts, "check_mattermost_auth", function(auth) {})

  # User requests 5 per page, API returns 5 results
  stub(search_posts, "mattermost_api_request", function(...) {
    return(create_mock_search_response(5))
  })

  expect_warning(
    search_posts("test", per_page = 5, auth = mock_auth),
    "matches the 'per_page' limit"
  )
})

test_that("convert_date_to_timestamp() returns double/numeric", {
  # This ensures we don't accidentally re-introduce as.integer()
  result <- MattermostR:::convert_date_to_timestamp("2024-01-01")
  expect_type(result, "double")
})
