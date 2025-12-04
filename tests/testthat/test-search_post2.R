library(testthat)
library(mockery)

# Mock auth object
mock_auth <- structure(
  list(base_url = "https://test.com", headers = "token"),
  class = "mattermost_auth"
)

test_that("search_posts() validation hits error lines", {
  # Line 145: in_channels not character
  expect_error(
    search_posts("term", in_channels = 123, auth = mock_auth),
    "in_channels must be a character vector"
  )

  # Line 150: from_users not character
  expect_error(
    search_posts("term", from_users = 123, auth = mock_auth),
    "from_users must be a character vector"
  )
})

test_that("search_posts() assigns optional parameters correctly", {
  stub(search_posts, "check_mattermost_auth", function(auth) {})

  # Lines 146 (in_channels), 151 (from_users), 160 (before_date)
  stub(search_posts, "mattermost_api_request", function(auth, endpoint, method, body, verbose) {
    expect_equal(body$in_channels, c("ch1", "ch2"))
    expect_equal(body$from_users, c("u1"))
    expect_type(body$before_date, "double") # Checked date conversion
    return(list(posts = list(), order = list()))
  })

  search_posts("term",
               in_channels = c("ch1", "ch2"),
               from_users = c("u1"),
               before_date = "2023-01-01",
               auth = mock_auth)
})

test_that("search_posts() handles NULL API response", {
  stub(search_posts, "check_mattermost_auth", function(auth) {})

  # Lines 181-192: Handle NULL response from API
  stub(search_posts, "mattermost_api_request", function(...) {
    return(NULL)
  })

  res <- search_posts("term", auth = mock_auth)

  expect_s3_class(res, "data.frame")
  expect_equal(nrow(res), 0)
  expect_true("id" %in% names(res))
})

test_that("search_posts() prints verbose diagnostics", {
  stub(search_posts, "check_mattermost_auth", function(auth) {})

  # Case 1: Empty results with in_channels (Line 207)
  stub(search_posts, "mattermost_api_request", function(...) {
    return(list(posts = list(), order = list()))
  })

  expect_message(
    search_posts("term", in_channels = "ch1", verbose = TRUE, auth = mock_auth),
    "Ensure the bot user has JOINED the target channel"
  )

  # Case 2: Success results (Line 222)
  stub(search_posts, "mattermost_api_request", function(...) {
    # Return 1 post
    p <- list(id="1", create_at=1000, update_at=1000)
    return(list(posts = list(p1=p), order = list("p1")))
  })

  expect_message(
    search_posts("term", verbose = TRUE, auth = mock_auth),
    "Found 1 posts"
  )
})

test_that("convert_search_posts_to_dataframe() handles timestamp edge cases", {
  # We test the internal logic via the main function by mocking the response
  stub(search_posts, "check_mattermost_auth", function(auth) {})

  # Line 261: create_at is 0 -> NA
  # Line 272: delete_at is not 0 -> POSIXct
  mock_resp <- list(
    posts = list(
      p1 = list(
        id = "p1",
        create_at = 0,             # Triggers Line 261 (else block)
        update_at = 0,
        edit_at = 0,
        delete_at = 1727787754562  # Triggers Line 272 (if block)
      )
    ),
    order = list("p1")
  )

  stub(search_posts, "mattermost_api_request", function(...) return(mock_resp))

  res <- search_posts("term", auth = mock_auth)

  expect_true(is.na(res$create_at[1])) # Confirms Line 261 hit
  expect_false(is.na(res$delete_at[1])) # Confirms Line 272 hit
  expect_true(inherits(res$delete_at, "POSIXct"))
})

test_that("convert_date_to_timestamp() handles edge cases", {
  # Direct testing of internal helper to ensure specific lines are hit

  # Line 313: Handle Date object
  dt <- as.Date("2023-01-01")
  ts <- MattermostR:::convert_date_to_timestamp(dt)
  expect_type(ts, "double")

  # Line 306: Invalid string format error
  expect_error(
    MattermostR:::convert_date_to_timestamp("not-a-date"),
    "Invalid date format"
  )

  # Line 323: Invalid input type (numeric/integer passed directly)
  expect_error(
    MattermostR:::convert_date_to_timestamp(123456),
    "Date input must be a POSIXct, Date, or character string"
  )
})


test_that("search_posts() hits after_date line (Line 156)", {
  stub(search_posts, "check_mattermost_auth", function(auth) {})

  # Stub API request to verify 'after_date' is in the body
  stub(search_posts, "mattermost_api_request", function(auth, endpoint, method, body, verbose) {
    # Verify Line 156 executed and assigned the value
    expect_true("after_date" %in% names(body))
    expect_type(body$after_date, "double")
    return(list(posts = list(), order = list()))
  })

  # Call with after_date to trigger Line 156
  search_posts("term", after_date = "2023-01-01", auth = mock_auth)
})

test_that("convert_search_posts_to_dataframe() handles valid lists", {
  # This tests the 'if (length(rows_list) > 0)' block, ensuring the happy path works.
  # Note: The 'else' block (Line 287) is unreachable due to the guard clause at the top of the function.

  mock_resp <- list(
    posts = list(
      p1 = list(id = "p1", create_at = 1700000000000, message = "test")
    ),
    order = list("p1")
  )

  # Call the internal function directly
  res <- MattermostR:::convert_search_posts_to_dataframe(mock_resp)

  expect_equal(nrow(res), 1)
  expect_equal(res$id[1], "p1")
})
