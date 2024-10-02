# File: tests/testthat/capture/capture-mattermost_api_request.R

# This script captures HTTP responses for mattermost_api_request() unit tests.

# Load necessary packages
library(MattermostR)
library(httptest2)

# Check if options for base_url and token are set
if (is.null(getOption("mattermost.base_url")) || is.null(getOption("mattermost.token"))) {
  stop("Please set options('mattermost.base_url') and options('mattermost.token') before running this script.")
}

# Authenticate using the function
auth <- authenticate_mattermost(test_connection = TRUE)

# Start capturing HTTP responses
httptest2::start_capturing()

# Run the code that makes HTTP requests

# Test Case 1: Successful GET request to retrieve teams
result_get_teams <- mattermost_api_request(auth = auth, endpoint = "/api/v4/teams")

# Check if we have any teams to work with
if (length(result_get_teams) == 0) {
  stop("No teams found. Please ensure you have access to at least one team.")
}

# Use the first team ID
team_id <- result_get_teams$id

# Test Case 2: Successful GET request to retrieve channels for the team
result_get_channels <- mattermost_api_request(auth = auth, endpoint = paste0("/api/v4/teams/", team_id, "/channels"))

# Test Case 3: Successful POST request to create a channel
channel_data <- list(
  team_id = team_id,
  name = paste0("test-channel-mattermost-unit-test"),
  display_name = "Test Channel",
  type = "P"  # 'O' for public channel, 'P' for private
)

result_post_channel <- mattermost_api_request(
  auth = auth,
  endpoint = "/api/v4/channels",
  method = "POST",
  body = channel_data,
  verbose = TRUE
)

# Clean up by deleting the created channel
 result_delete_channel <- mattermost_api_request(
   auth = auth,
   endpoint = paste0("/api/v4/channels/", result_post_channel$id),
   method = "DELETE"
 )

# Stop capturing HTTP responses
httptest2::stop_capturing()
