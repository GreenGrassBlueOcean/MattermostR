library(testthat)
library(mockery)

# Simple mock auth for paginate_api tests (avoid mock_auth_helper's stub_everything)
make_mock_auth <- function() {
  structure(
    list(base_url = "https://mock.mattermost.com", headers = "Bearer mock_token"),
    class = "mattermost_auth"
  )
}

# =============================================================================
# paginate_api() — core pagination logic
# =============================================================================

test_that("paginate_api() returns single page when fewer than per_page rows", {
  mock_auth <- make_mock_auth()
  single_page <- data.frame(id = c("a", "b"), name = c("A", "B"),
                            stringsAsFactors = FALSE)

  mock_req <- mockery::mock(single_page)
  mockery::stub(paginate_api, "mattermost_api_request", mock_req)


  result <- paginate_api(mock_auth, "/api/v4/teams", per_page = 200)

  mockery::expect_called(mock_req, 1)
  expect_equal(nrow(result), 2)
  expect_equal(result$id, c("a", "b"))

  # Verify page=0 was requested
  args <- mockery::mock_args(mock_req)[[1]]
  expect_match(args[[2]], "page=0&per_page=200")
})

test_that("paginate_api() accumulates multiple pages", {
  mock_auth <- make_mock_auth()

  make_page <- function(n, offset = 0) {
    data.frame(id = paste0("r", seq(offset + 1, offset + n)),
               stringsAsFactors = FALSE)
  }

  mock_req <- mockery::mock(
    make_page(200, 0),   # page 0: full
    make_page(200, 200), # page 1: full
    make_page(50, 400)   # page 2: partial → stop
  )
  mockery::stub(paginate_api, "mattermost_api_request", mock_req)

  result <- paginate_api(mock_auth, "/api/v4/teams", per_page = 200)

  mockery::expect_called(mock_req, 3)
  expect_equal(nrow(result), 450)

  # Verify page numbers incremented correctly
  args1 <- mockery::mock_args(mock_req)[[1]]
  args2 <- mockery::mock_args(mock_req)[[2]]
  args3 <- mockery::mock_args(mock_req)[[3]]
  expect_match(args1[[2]], "page=0")
  expect_match(args2[[2]], "page=1")
  expect_match(args3[[2]], "page=2")
})

test_that("paginate_api() returns empty data.frame when first page is empty", {
  mock_auth <- make_mock_auth()

  mock_req <- mockery::mock(data.frame())
  mockery::stub(paginate_api, "mattermost_api_request", mock_req)

  result <- paginate_api(mock_auth, "/api/v4/teams", per_page = 200)

  mockery::expect_called(mock_req, 1)
  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 0)
})

test_that("paginate_api() respects max_pages limit", {
  mock_auth <- make_mock_auth()

  full_page <- data.frame(id = paste0("r", 1:200), stringsAsFactors = FALSE)

  # Return full pages indefinitely
  mock_req <- mockery::mock(full_page, full_page, full_page, full_page)
  mockery::stub(paginate_api, "mattermost_api_request", mock_req)

  result <- paginate_api(mock_auth, "/api/v4/teams", per_page = 200,
                         max_pages = 2)

  # Should stop after 2 pages (page 0 and page 1)
  mockery::expect_called(mock_req, 2)
  expect_equal(nrow(result), 400)
})

test_that("paginate_api() applies transform to each page", {
  mock_auth <- make_mock_auth()

  # Simulate the posts endpoint: raw response is a nested list
  raw_page <- list(
    posts = list(
      list(id = "p1", create_at = 1700000000000, update_at = 1700000000000,
           edit_at = 0, delete_at = 0, is_pinned = FALSE, user_id = "u1",
           channel_id = "ch1", message = "hello", type = ""),
      list(id = "p2", create_at = 1700000001000, update_at = 1700000001000,
           edit_at = 0, delete_at = 0, is_pinned = FALSE, user_id = "u2",
           channel_id = "ch1", message = "world", type = "")
    ),
    order = c("p1", "p2")
  )

  mock_req <- mockery::mock(raw_page)
  mockery::stub(paginate_api, "mattermost_api_request", mock_req)

  result <- paginate_api(mock_auth, "/api/v4/channels/ch1/posts", per_page = 200,
                         transform = convert_mattermost_posts_to_dataframe)

  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 2)
  expect_equal(result$id, c("p1", "p2"))
  expect_equal(result$message, c("hello", "world"))
})

test_that("paginate_api() stops when transform returns empty data.frame", {
  mock_auth <- make_mock_auth()

  full_page <- data.frame(id = paste0("r", 1:200), stringsAsFactors = FALSE)
  empty_nested <- list(posts = list(), order = character(0))

  mock_req <- mockery::mock(
    "ignored",  # page 0 transform returns full
    "ignored"   # page 1 transform returns empty
  )

  call_count <- 0L
  fake_transform <- function(x) {
    call_count <<- call_count + 1L
    if (call_count == 1L) return(full_page)
    return(data.frame())
  }

  mockery::stub(paginate_api, "mattermost_api_request", mock_req)

  result <- paginate_api(mock_auth, "/api/v4/test", per_page = 200,
                         transform = fake_transform)

  # Page 0 returned 200 rows → fetch page 1 → transform returns empty → stop
  mockery::expect_called(mock_req, 2)
  expect_equal(nrow(result), 200)
})

test_that("paginate_api() appends with & when endpoint has existing query string", {
  mock_auth <- make_mock_auth()
  single_page <- data.frame(id = "x", stringsAsFactors = FALSE)

  mock_req <- mockery::mock(single_page)
  mockery::stub(paginate_api, "mattermost_api_request", mock_req)

  paginate_api(mock_auth, "/api/v4/teams?include_total_count=true",
               per_page = 200)

  args <- mockery::mock_args(mock_req)[[1]]
  # Should use & (not ?) since endpoint already has a query string
  expect_match(args[[2]], "\\?include_total_count=true&page=0&per_page=200")
})

test_that("paginate_api() stops on API error response", {
  mock_auth <- make_mock_auth()

  error_response <- list(
    message = "You do not have the appropriate permissions",
    status_code = 403
  )

  mock_req <- mockery::mock(error_response)
  mockery::stub(paginate_api, "mattermost_api_request", mock_req)

  expect_error(
    paginate_api(mock_auth, "/api/v4/teams", per_page = 200),
    "API error during pagination \\(page 0\\)"
  )
})

test_that("paginate_api() handles list results (non-data.frame)", {
  mock_auth <- make_mock_auth()

  # Some endpoints return lists of lists instead of data frames
  page1 <- list(
    list(id = "a", name = "A"),
    list(id = "b", name = "B")
  )

  mock_req <- mockery::mock(page1)
  mockery::stub(paginate_api, "mattermost_api_request", mock_req)

  # length(page1) = 2 < per_page = 200, so stops after one page
  result <- paginate_api(mock_auth, "/api/v4/endpoint", per_page = 200)

  mockery::expect_called(mock_req, 1)
  # Result is the accumulated list (via do.call(rbind, ...))
  expect_equal(length(result), 2)
})

test_that("paginate_api() breaks when result is neither data.frame nor list", {
  mock_auth <- make_mock_auth()

  # Return a raw character vector (not a list or data.frame)
  mock_req <- mockery::mock("unexpected_string_result")
  mockery::stub(paginate_api, "mattermost_api_request", mock_req)

  result <- paginate_api(mock_auth, "/api/v4/endpoint", per_page = 200)

  mockery::expect_called(mock_req, 1)
  # Should hit the else-break and return empty data.frame
  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 0)
})
