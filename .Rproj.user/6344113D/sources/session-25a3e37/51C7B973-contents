

test_that("Authentication object is correctly identified", {
  auth <- authenticate_mattermost(base_url = "https://mattermost.stackhero-network.com", token = "valid_token", test_connection = FALSE)

  expect_s3_class(auth, "mattermost_auth")

  expect_error(check_mattermost_auth(list(base_url = "https://mattermost.stackhero-network.com")),
               "The provided object is not a valid 'mattermost_auth' object.")
})
