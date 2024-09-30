# Load testthat and mockery
library(testthat)
library(mockery)

test_that("get_team() works as expected", {

  # 1. Test case: team_id is NULL
  expect_error(get_team(team_id = NULL),
               "team_id cannot be empty or NULL")

  # 2. Test case: Invalid auth object (missing or invalid token)
  # Mock check_mattermost_auth to throw an error
  mockery::stub(get_team, 'check_mattermost_auth', function(auth) {
    stop("Invalid authentication object.")
  })

  expect_error(get_team(team_id = "team123", auth = list(base_url = "invalid_url")),
               "Invalid authentication object.")

  # 3. Test case: Successful retrieval of team info
  # Mock check_mattermost_auth to do nothing (auth is assumed valid)
  mockery::stub(get_team, 'check_mattermost_auth', function(auth) {})

  # Mock mattermost_api_request to simulate a successful API response
  mockery::stub(get_team, 'mattermost_api_request', function(auth, endpoint, method, verbose) {
    list(id = "team123", name = "Test Team", display_name = "Test Team Display")
  })

  # Run the function and check if the result matches expected output
  result <- get_team(team_id = "team123")

  expect_equal(result$id, "team123")
  expect_equal(result$name, "Test Team")
  expect_equal(result$display_name, "Test Team Display")

  # 4. Test case: Failure in API request (team not found)
  # Mock mattermost_api_request to return a failure response
  mockery::stub(get_team, 'mattermost_api_request', function(auth, endpoint, method, verbose) {
    stop("Team not found.")
  })

  expect_error(get_team(team_id = "non_existing_team"),
               "Team not found.")

})
