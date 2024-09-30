# Load testthat and mockery
library(testthat)
library(mockery)

# Assuming the helper functions are available for mocking
# source("helper.R")

test_that("get_all_teams() works as expected", {

  # 1. Test case: Invalid auth object (missing or invalid token)
  # Mock check_mattermost_auth to throw an error
  mockery::stub(get_all_teams, 'check_mattermost_auth', function(auth) {
    stop("Invalid authentication object.")
  })

  expect_error(get_all_teams(auth = list(base_url = "invalid_url")),
               "Invalid authentication object.")

  # 2. Test case: Successful retrieval of all teams
  # Mock check_mattermost_auth to do nothing (auth is assumed valid)
  mockery::stub(get_all_teams, 'check_mattermost_auth', function(auth) {})

  # Mock mattermost_api_request to simulate a successful API response
  mockery::stub(get_all_teams, 'mattermost_api_request', function(auth, endpoint, method, verbose) {
    list(
      list(id = "team1", name = "Team 1", display_name = "Team One"),
      list(id = "team2", name = "Team 2", display_name = "Team Two")
    )
  })

  # Run the function and check if the result matches expected output
  result <- get_all_teams()

  expect_equal(length(result), 2)
  expect_equal(result[[1]]$id, "team1")
  expect_equal(result[[1]]$name, "Team 1")

  # 3. Test case: No teams found
  # Mock mattermost_api_request to return an empty list
  mockery::stub(get_all_teams, 'mattermost_api_request', function(auth, endpoint, method, verbose) {
    list()
  })

  expect_warning(get_all_teams(),
                 "The user for which the current bearer authentication key is taken is not part of any teams")

})

