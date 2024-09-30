# File: tests/testthat/test-get_channel_posts.R

test_that("get_channel_posts() works as expected", {

  # 1. Test case: channel_id is NULL
  expect_error(get_channel_posts(channel_id = NULL),
               "channel_id cannot be empty or NULL")

  # 2. Test case: channel_id is an empty string
  expect_error(get_channel_posts(channel_id = ""),
               "channel_id cannot be empty or NULL")

  # 3. Test case: Missing or invalid authentication object
  expect_error(get_channel_posts(channel_id = "123", auth = NULL),
               "The provided object is not a valid 'mattermost_auth' object.")

  # 4. Test case: Successful API request

  # Mock check_mattermost_auth to do nothing (assumes auth is valid)
  mockery::stub(get_channel_posts, 'check_mattermost_auth', function(auth) {})

  # Mock mattermost_api_request to simulate a successful API response
  mockery::stub(get_channel_posts, 'mattermost_api_request', function(auth, endpoint, method, verbose) {
    list(posts = list(post1 = "Test post 1", post2 = "Test post 2"))
  })

  result <- get_channel_posts(channel_id = "123", auth = mock_auth_helper())
  expect_equal(result, list(posts = list(post1 = "Test post 1", post2 = "Test post 2")))

  # 5. Test case: Verbose output
  result_verbose <- get_channel_posts(channel_id = "123", verbose = TRUE, auth = mock_auth_helper())
  expect_equal(result_verbose, list(posts = list(post1 = "Test post 1", post2 = "Test post 2")))

  # 6. Test case: Invalid channel_id (simulating a failed API request)
  mockery::stub(get_channel_posts, 'mattermost_api_request', function(auth, endpoint, method, verbose) {
    stop("Channel not found")
  })

  expect_error(get_channel_posts(channel_id = "invalid-channel", auth = mock_auth_helper()), "Channel not found")
})
