# test-helpers.R

library(mockery)

# Global helper to mock authentication
mock_auth_helper <- function() {

  auth <- list(base_url = "https://fake-mattermost.com", headers = "Bearer faketoken")
  class(auth) <- "mattermost_auth"

  mock_auth <- mockery::mock(list(base_url = "https://fake-mattermost.com", headers = "Bearer faketoken"))
  mockery::stub_everything("get_default_auth", mock_auth)
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
  class(fake_auth) <- "mattermost_auth"

  # Replace the default auth retrieval function
  mockery::stub_everything("get_default_auth", function(...) fake_auth)

  # Replace the mattermost_api_request function for all HTTP methods
  functions_to_mock <- c("add_reaction", "add_users_to_channel",
                         "assign_bot",
                         "create_bot", "create_channel", "create_command",
                         "create_direct_channel",
                         "delete_channel", "delete_command", "delete_post",
                         "disable_bot", "enable_bot",
                         "execute_command",
                         "get_all_users", "get_bot", "get_bots",
                         "get_channel_info", "get_channel_members", "get_channel_posts",
                         "get_command", "get_mattermost_file",
                         "get_me", "get_reactions", "get_team",
                         "get_user", "get_user_info", "get_user_status",
                         "list_commands",
                         "pin_post", "regen_command_token",
                         "remove_channel_member", "remove_reaction",
                         "send_mattermost_file", "send_mattermost_message",
                         "set_user_status", "unpin_post",
                         "update_bot", "update_command", "update_post")

  for (fun_name in functions_to_mock) {
    mockery::stub(where = fun_name, what = "mattermost_api_request", how = mock_mattermost_api_request)
  }

  # Functions that now delegate to paginate_api() instead of mattermost_api_request()
  mock_paginate_api <- function(auth, endpoint, per_page = 200, max_pages = Inf,
                                transform = NULL, verbose = FALSE) {
    data.frame()
  }
  for (fun_name in c("get_all_teams", "get_team_channels")) {
    mockery::stub(where = fun_name, what = "paginate_api", how = mock_paginate_api)
  }

  # Mock send_webhook_message (uses httr2 directly, not mattermost_api_request)
  mock_webhook_resp <- structure(
    list(status_code = 200L, headers = list(`Content-Type` = "text/plain"), body = charToRaw("ok")),
    class = "httr2_response"
  )
  mockery::stub(where = "send_webhook_message", what = "httr2::req_perform", how = function(...) mock_webhook_resp)

  # Mock specific functions with authentication validation
  mockery::stub(where = "check_mattermost_auth", what = "check_mattermost_auth", how = function(auth) TRUE)

  # Return a confirmation that stubbing is complete
  message("All relevant functions have been stubbed for testing.")
}
