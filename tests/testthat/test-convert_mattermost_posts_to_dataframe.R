library(testthat)

# Define a mock nested list for testing
mock_nested_list <- list(
  posts = list(
    post1 = list(id = "1", create_at = 1727787754562, update_at = 1727787754562,
                 edit_at = 0L, delete_at = 0L, is_pinned = FALSE,
                 user_id = "user1", channel_id = "channel1",
                 message = "Hello, World!", type = "text"),
    post2 = list(id = "2", create_at = 1727787758206, update_at = 1727787758206,
                 edit_at = 1727787760000, delete_at = 0L, is_pinned = TRUE,
                 user_id = "user2", channel_id = "channel1",
                 message = "This is a test post.", type = "text")
  )
)

# Unit tests for convert_mattermost_posts_to_dataframe
test_that("convert_mattermost_posts_to_dataframe converts nested list to data frame correctly", {
  result <- convert_mattermost_posts_to_dataframe(mock_nested_list)

  # Check the number of rows and columns
  expect_equal(nrow(result), 2)
  expect_equal(colnames(result), c("id", "create_at", "update_at", "edit_at", "delete_at", "is_pinned", "user_id", "channel_id", "message", "type"))

  # Check specific values
  expect_equal(result$id[1], "1")
  expect_equal(result$message[2], "This is a test post.")
  expect_true(is.na(result$edit_at[1]))  # Check if edit_at is NA for post1
  expect_false(result$is_pinned[1])      # Check if is_pinned is FALSE for post1
  expect_true(result$is_pinned[2])       # Check if is_pinned is TRUE for post2
})

test_that("convert_mattermost_posts_to_dataframe handles empty posts list correctly", {
  empty_nested_list <- list(posts = list())
  result <- convert_mattermost_posts_to_dataframe(empty_nested_list)

  # Result should have no rows
  expect_equal(nrow(result), 0)
})

# Test for correct date conversion
test_that("convert_mattermost_posts_to_dataframe converts timestamps correctly", {
  result <- convert_mattermost_posts_to_dataframe(mock_nested_list)

  # Check that the created_at and updated_at are converted to POSIXct
  expect_true(inherits(result$create_at, "POSIXct"))
  expect_true(inherits(result$update_at, "POSIXct"))
  expect_true(inherits(result$edit_at, "POSIXct") || is.na(result$edit_at[1]))  # Either POSIXct or NA
})
