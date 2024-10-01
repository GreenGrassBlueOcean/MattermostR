# File: tests/testthat/test-get_channel_posts.R

test_that("get_channel_posts() works as expected", {

  # 1. Test case: channel_id is NULL
  expect_error(get_channel_posts(channel_id = NULL),
               "channel_id cannot be empty or NULL")

  # 2. Test case: channel_id is an empty string
  expect_error(get_channel_posts(channel_id = ""),
               "channel_id cannot be empty or NULL")

  # 3. Test case: Missing or invalid authentication object
  expect_error(get_channel_posts(channel_id = "channel1", auth = NULL),
               "The provided object is not a valid 'mattermost_auth' object.")

  # 4. Test case: Successful API request

  # Mock check_mattermost_auth to do nothing (assumes auth is valid)
  mockery::stub(get_channel_posts, 'check_mattermost_auth', function(auth) {})

  # Mock mattermost_api_request to simulate a successful API response
  mockery::stub(get_channel_posts, 'mattermost_api_request', function(auth, endpoint, method, verbose) {
    return(list(posts = list(
      list(id = "1", create_at = 1727787754562, update_at = 1727787754562,
           edit_at = 0L, delete_at = 0L, is_pinned = FALSE,
           user_id = "user1", channel_id = "channel1",
           message = "Hello, World!", type = "text"),
      list(id = "2", create_at = 1727787758206, update_at = 1727787758206,
           edit_at = 1727787760000, delete_at = 0L, is_pinned = TRUE,
           user_id = "user2", channel_id = "channel1",
           message = "This is a test post.", type = "text")
    )))
  })

  Correctoutput <- structure(list(id = c("1", "2"), create_at = structure(c(1727787754.562, 1727787758.206), tzone = "UTC", class = c("POSIXct", "POSIXt"))
                                  , update_at = structure(c(1727787754.562, 1727787758.206), tzone = "UTC", class = c("POSIXct", "POSIXt"))
                                  , edit_at = c(NA, 1727787760), delete_at = c(NA, NA), is_pinned = c(FALSE, TRUE), user_id = c("user1", "user2")
                                  , channel_id = c("channel1", "channel1"), message = c("Hello, World!", "This is a test post."), type = c("text", "text")), row.names = c(NA, -2L), class = "data.frame")



  result <- get_channel_posts(channel_id = "channel1", auth = mock_auth_helper())
  expect_equal(result, Correctoutput)
  # 5. Test case: Verbose output
  result_verbose <- get_channel_posts(channel_id = "channel1", verbose = TRUE, auth = mock_auth_helper())
  expect_equal(result_verbose, Correctoutput)

  # 6. Test case: Invalid channel_id (simulating a failed API request)
  mockery::stub(get_channel_posts, 'mattermost_api_request', function(auth, endpoint, method, verbose) {
    stop("Channel not found")
  })

  expect_error(get_channel_posts(channel_id = "invalid-channel", auth = mock_auth_helper()), "Channel not found")
})
