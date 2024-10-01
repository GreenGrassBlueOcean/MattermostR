test_that("delete_old_messages works correctly", {

  # Mock responses for getting messages
  mock_messages <- data.frame(
      id = c("msg1", "msg2", "msg3"),
      create_at = as.POSIXct(as.numeric(c(Sys.time() - 10 * 86400, Sys.time() - 16 * 86400, Sys.time() - 20 * 86400)), origin = "1970-01-01", tz = "UTC"), # 10 days, 5 days, 20 days old
      stringsAsFactors = FALSE
    )

  # Set up the mock to return the mock messages
  mockery::stub(delete_old_messages, "get_channel_posts", mock_messages)

  # Mock delete_message function
  mockery::stub(delete_old_messages, "delete_post", function(post_id){
    return(list(status = "OK"))
  })

  # Mock check_mattermost_auth to do nothing (assumes auth is valid)
  mockery::stub(delete_old_messages, 'check_mattermost_auth', function(auth) {})

  # Test deleting messages older than 15 days
  deleted_messages <- delete_old_messages("channel_id", 15)

  expect_equal(deleted_messages, structure(list(message_id = c("msg2", "msg3"), delete_status = c("OK", "OK")), class = "data.frame", row.names = c(NA, -2L)))  # Should delete messages older than 15 days

  # Test when there are no messages to delete
  expect_message(deleted_messages_no_delete <- delete_old_messages("channel_id", 30))
  expect_equal(deleted_messages_no_delete, data.frame())

})
