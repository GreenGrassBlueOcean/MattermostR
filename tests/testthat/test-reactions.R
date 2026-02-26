# Test suite for reactions: add_reaction, get_reactions, remove_reaction

# --- add_reaction() ---

test_that("add_reaction() validates required parameters", {
  expect_error(add_reaction(user_id = NULL, post_id = "p1", emoji_name = "thumbsup"),
               "user_id cannot be empty or NULL")

  expect_error(add_reaction(user_id = "u1", post_id = NULL, emoji_name = "thumbsup"),
               "post_id cannot be empty or NULL")

  expect_error(add_reaction(user_id = "u1", post_id = "p1", emoji_name = NULL),
               "emoji_name cannot be empty or NULL")

  expect_error(add_reaction(user_id = "u1", post_id = "p1", emoji_name = "thumbsup", auth = NULL),
               "The provided object is not a valid 'mattermost_auth' object.")
})

test_that("add_reaction() strips colons from emoji_name", {
  mock_auth <- structure(
    list(base_url = "https://fake-mattermost.com", headers = "Bearer faketoken"),
    class = "mattermost_auth"
  )
  mock_response <- list(user_id = "u1", post_id = "p1", emoji_name = "thumbsup", create_at = 1234567890)

  mockery::stub(add_reaction, "check_mattermost_auth", function(auth) {})
  mock_api <- mockery::mock(mock_response)
  mockery::stub(add_reaction, "mattermost_api_request", mock_api)

  result <- add_reaction(
    user_id = "u1", post_id = "p1", emoji_name = ":thumbsup:",
    auth = mock_auth
  )

  call_args <- mockery::mock_args(mock_api)[[1]]
  expect_equal(call_args$body$emoji_name, "thumbsup")
})

test_that("add_reaction() sends correct request", {
  mock_auth <- structure(
    list(base_url = "https://fake-mattermost.com", headers = "Bearer faketoken"),
    class = "mattermost_auth"
  )
  mock_response <- list(user_id = "u1", post_id = "p1", emoji_name = "heart", create_at = 1234567890)

  mockery::stub(add_reaction, "check_mattermost_auth", function(auth) {})
  mock_api <- mockery::mock(mock_response)
  mockery::stub(add_reaction, "mattermost_api_request", mock_api)

  result <- add_reaction(
    user_id = "u1", post_id = "p1", emoji_name = "heart",
    auth = mock_auth
  )

  expect_equal(result, mock_response)

  call_args <- mockery::mock_args(mock_api)[[1]]
  expect_equal(call_args$endpoint, "/api/v4/reactions")
  expect_equal(call_args$method, "POST")
  expect_equal(call_args$body, list(user_id = "u1", post_id = "p1", emoji_name = "heart"))
})

test_that("add_reaction() passes verbose through", {
  mock_auth <- structure(
    list(base_url = "https://fake-mattermost.com", headers = "Bearer faketoken"),
    class = "mattermost_auth"
  )

  mockery::stub(add_reaction, "check_mattermost_auth", function(auth) {})
  mock_api <- mockery::mock(list())
  mockery::stub(add_reaction, "mattermost_api_request", mock_api)

  add_reaction(user_id = "u1", post_id = "p1", emoji_name = "smile",
               verbose = TRUE, auth = mock_auth)

  call_args <- mockery::mock_args(mock_api)[[1]]
  expect_true(call_args$verbose)
})

# --- get_reactions() ---

test_that("get_reactions() validates required parameters", {
  expect_error(get_reactions(post_id = NULL),
               "post_id cannot be empty or NULL")

  expect_error(get_reactions(post_id = ""),
               "post_id cannot be empty or NULL")

  expect_error(get_reactions(post_id = "p1", auth = NULL),
               "The provided object is not a valid 'mattermost_auth' object.")
})

test_that("get_reactions() sends correct request and returns data", {
  mock_auth <- structure(
    list(base_url = "https://fake-mattermost.com", headers = "Bearer faketoken"),
    class = "mattermost_auth"
  )
  mock_response <- data.frame(
    user_id = c("u1", "u2"),
    post_id = c("p1", "p1"),
    emoji_name = c("thumbsup", "heart"),
    create_at = c(1234567890, 1234567891),
    stringsAsFactors = FALSE
  )

  mockery::stub(get_reactions, "check_mattermost_auth", function(auth) {})
  mock_api <- mockery::mock(mock_response)
  mockery::stub(get_reactions, "mattermost_api_request", mock_api)

  result <- get_reactions(post_id = "p1", auth = mock_auth)

  expect_equal(result, mock_response)

  call_args <- mockery::mock_args(mock_api)[[1]]
  expect_equal(call_args$endpoint, "/api/v4/posts/p1/reactions")
  expect_equal(call_args$method, "GET")
})

# --- remove_reaction() ---

test_that("remove_reaction() validates required parameters", {
  expect_error(remove_reaction(user_id = NULL, post_id = "p1", emoji_name = "thumbsup"),
               "user_id cannot be empty or NULL")

  expect_error(remove_reaction(user_id = "u1", post_id = NULL, emoji_name = "thumbsup"),
               "post_id cannot be empty or NULL")

  expect_error(remove_reaction(user_id = "u1", post_id = "p1", emoji_name = NULL),
               "emoji_name cannot be empty or NULL")

  expect_error(remove_reaction(user_id = "u1", post_id = "p1", emoji_name = "thumbsup", auth = NULL),
               "The provided object is not a valid 'mattermost_auth' object.")
})

test_that("remove_reaction() strips colons from emoji_name", {
  mock_auth <- structure(
    list(base_url = "https://fake-mattermost.com", headers = "Bearer faketoken"),
    class = "mattermost_auth"
  )
  mock_response <- list(status = "OK")

  mockery::stub(remove_reaction, "check_mattermost_auth", function(auth) {})
  mock_api <- mockery::mock(mock_response)
  mockery::stub(remove_reaction, "mattermost_api_request", mock_api)

  remove_reaction(
    user_id = "u1", post_id = "p1", emoji_name = ":thumbsup:",
    auth = mock_auth
  )

  call_args <- mockery::mock_args(mock_api)[[1]]
  expect_match(call_args$endpoint, "/reactions/thumbsup$")
})

test_that("remove_reaction() sends correct request", {
  mock_auth <- structure(
    list(base_url = "https://fake-mattermost.com", headers = "Bearer faketoken"),
    class = "mattermost_auth"
  )
  mock_response <- list(status = "OK")

  mockery::stub(remove_reaction, "check_mattermost_auth", function(auth) {})
  mock_api <- mockery::mock(mock_response)
  mockery::stub(remove_reaction, "mattermost_api_request", mock_api)

  result <- remove_reaction(
    user_id = "u1", post_id = "p1", emoji_name = "heart",
    auth = mock_auth
  )

  expect_equal(result, mock_response)

  call_args <- mockery::mock_args(mock_api)[[1]]
  expect_equal(call_args$endpoint, "/api/v4/users/u1/posts/p1/reactions/heart")
  expect_equal(call_args$method, "DELETE")
})

test_that("remove_reaction() passes verbose through", {
  mock_auth <- structure(
    list(base_url = "https://fake-mattermost.com", headers = "Bearer faketoken"),
    class = "mattermost_auth"
  )

  mockery::stub(remove_reaction, "check_mattermost_auth", function(auth) {})
  mock_api <- mockery::mock(list(status = "OK"))
  mockery::stub(remove_reaction, "mattermost_api_request", mock_api)

  remove_reaction(user_id = "u1", post_id = "p1", emoji_name = "smile",
                  verbose = TRUE, auth = mock_auth)

  call_args <- mockery::mock_args(mock_api)[[1]]
  expect_true(call_args$verbose)
})
