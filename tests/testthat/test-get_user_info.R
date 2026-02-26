#
# get_user_info() is deprecated in favour of get_user().
# These tests verify backward compatibility and the deprecation warning.

library(testthat)
library(mockery)

test_that("get_user_info() delegates to get_user() with deprecation warning", {
  mock_auth <- structure(
    list(base_url = "https://fake-mattermost.com", headers = "Bearer faketoken"),
    class = "mattermost_auth"
  )
  mock_response <- list(id = "123", username = "testuser", email = "test@example.com")

  # Stub get_user inside get_user_info
  mockery::stub(get_user_info, "get_user", function(user_id, auth) {
    mock_response
  })

  lifecycle::expect_deprecated(
    result <- get_user_info(user_id = "123", auth = mock_auth)
  )
  expect_equal(result, mock_response)
})

test_that("get_user_info() still validates user_id (via get_user())", {
  mock_auth <- structure(
    list(base_url = "https://fake-mattermost.com", headers = "Bearer faketoken"),
    class = "mattermost_auth"
  )

  # lifecycle::deprecate_warn fires first, then get_user() validates user_id.
  # We suppress the deprecation warning to test the underlying validation.
  expect_error(
    suppressWarnings(get_user_info(user_id = NULL, auth = mock_auth)),
    "user_id cannot be empty or NULL"
  )
})
