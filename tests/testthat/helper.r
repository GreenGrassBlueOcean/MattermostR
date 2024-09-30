# test-helpers.R

library(mockery)

# Global helper to mock authentication
mock_auth_helper <- function() {

  auth <- list(base_url = "https://fake-mattermost.com", headers = "Bearer faketoken")
  class(auth) <- "mattermost_auth"

  mock_auth <- mockery::mock(list(base_url = "https://fake-mattermost.com", headers = "Bearer faketoken"))
  mockery::stub_everything("authenticate_mattermost", mock_auth)
  return(mock_auth)
}

# Global helper to mock API requests
mock_api_request_helper <- function(fake_data = list()) {
  mock_request <- mockery::mock(fake_data)
  mockery::stub_everything("mattermost_api_request", mock_request)
  return(mock_request)
}

sub_everything <- function() {
  # Helper function to mock Mattermost API responses
  mock_mattermost_api_request <- function(auth, endpoint, method = "GET", body = NULL, multipart = FALSE, verbose = FALSE) {
    list(
      success = TRUE,
      method = method,
      endpoint = endpoint,
      body = body
    )
  }

  # Mock authentication object
  fake_auth <- list(base_url = "https://fake-url.com", headers = "Bearer fake-token")

  # Replace the authentication function
  mockery::stub(where = "authenticate_mattermost", what = "authenticate_mattermost", how = function(...) fake_auth)

  # Replace the mattermost_api_request function for all HTTP methods
  functions_to_mock <- c("create_channel", "delete_channel", "delete_post", "get_all_teams", "get_all_users",
                         "get_channel_info", "get_channel_posts", "get_mattermost_file", "get_me", "get_team",
                         "get_team_channels", "get_user", "get_user_info", "send_mattermost_file", "send_mattermost_message")

  for (fun_name in functions_to_mock) {
    mockery::stub(where = fun_name, what = "mattermost_api_request", how = mock_mattermost_api_request)
  }

  # Mock specific functions with authentication validation
  mockery::stub(where = "check_mattermost_auth", what = "check_mattermost_auth", how = function(auth) TRUE)

  # Return a confirmation that stubbing is complete
  message("All relevant functions have been stubbed for testing.")
}
