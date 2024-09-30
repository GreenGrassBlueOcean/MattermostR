# Test suite for delete_post
test_that("delete_post() works as expected", {

  # 1. Test case: post_id is NULL
  expect_error(delete_post(post_id = NULL),
               "post_id cannot be empty or NULL")

  # 2. Test case: post_id is an empty string
  expect_error(delete_post(post_id = ""),
               "post_id cannot be empty or NULL")

  # 3. Test case: Missing or invalid authentication object
  expect_error(delete_post(post_id = "123", auth = NULL),
               "The provided object is not a valid 'mattermost_auth' object.")

  # 4. Test case: Successful API request
  mock_response <- list(success = TRUE, message = "Post deleted successfully")

  # Mock check_mattermost_auth to do nothing (auth is assumed valid)
  mockery::stub(delete_post, 'check_mattermost_auth', function(auth) {})

  # Mock mattermost_api_request to simulate a successful API response
  mockery::stub(delete_post, 'mattermost_api_request', function(auth, endpoint, method, verbose) {
    mock_response
  })

  result <- delete_post(post_id = "123", auth = mock_auth)
  expect_equal(result, mock_response)

  # 5. Test case: Invalid post_id (simulating a failed API request)
  mockery::stub(delete_post, 'mattermost_api_request', function(auth, endpoint, method, verbose) {
    stop("Post not found")
  })

  expect_error(delete_post(post_id = "invalid-post", auth = mock_auth), "Post not found")
})
