# Test suite for send_mattermost_file
test_that("send_mattermost_file() works as expected", {

  # 1. Test case: channel_id is NULL
  expect_error(send_mattermost_file(channel_id = NULL, file_path = "path/to/file.txt"),
               "channel_id cannot be empty or NULL")

  # 2. Test case: file_path is NULL
  expect_error(send_mattermost_file(channel_id = "123", file_path = NULL),
               "file_path cannot be empty or NULL")

  # 3. Test case: Missing or invalid authentication object
  expect_error(send_mattermost_file(channel_id = "123", file_path = "path/to/file.txt", auth = NULL),
               "The provided object is not a valid 'mattermost_auth' object.")

  # 4. Test case: Successful file send
  mock_response <- list(id = "file123", channel_id = "123", comment = "File uploaded successfully.")

  # Mock check_mattermost_auth to do nothing (auth is assumed valid)
  mockery::stub(send_mattermost_file, 'check_mattermost_auth', function(auth) {})

  # Mock httr2::req_perform to simulate a successful file send
  mockery::stub(send_mattermost_file, 'httr2::req_perform', function(req) {
    # Simulate a response object with necessary content
    response <- list(status_code = 200, body = jsonlite::toJSON(mock_response))
    class(response) <- c("httr2_response", "list")  # Give it a class for method dispatch
    return(response)
  })
#
#   result <- send_mattermost_file(channel_id = "123", file_path = "path/to/file.txt"
#                                 , auth = mock_auth)
#   expect_equal(result, mock_response)

  # 5. Test case: Failed file send (simulating a failed API request)
#   mockery::stub(send_mattermost_file, 'httr2::req_perform', function(req) {
#     stop("Failed to upload file")
#   })
#
#   expect_error(send_mattermost_file(channel_id = "123", file_path = "path/to/file.txt", auth = mock_auth), "Failed to upload file")
#
})
