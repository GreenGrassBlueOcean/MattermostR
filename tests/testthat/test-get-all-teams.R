library(testthat)
library(mockery)

test_that("get_all_teams() rejects invalid auth", {
  mockery::stub(get_all_teams, "check_mattermost_auth", function(auth) {
    stop("Invalid authentication object.")
  })

  expect_error(get_all_teams(auth = list(base_url = "invalid_url")),
               "Invalid authentication object.")
})

test_that("get_all_teams() returns teams from paginate_api()", {
  mockery::stub(get_all_teams, "check_mattermost_auth", function(auth) {})

  teams_df <- data.frame(
    id = c("team1", "team2"),
    name = c("Team 1", "Team 2"),
    display_name = c("Team One", "Team Two"),
    stringsAsFactors = FALSE
  )
  mockery::stub(get_all_teams, "paginate_api", function(...) teams_df)

  result <- get_all_teams()

  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 2)
  expect_equal(result$id, c("team1", "team2"))
})

test_that("get_all_teams() warns when no teams found", {
  mockery::stub(get_all_teams, "check_mattermost_auth", function(auth) {})
  mockery::stub(get_all_teams, "paginate_api", function(...) data.frame())

  expect_warning(
    get_all_teams(),
    "The user for which the current bearer authentication key is taken is not part of any teams"
  )
})

test_that("get_all_teams() passes verbose and auth to paginate_api()", {
  mockery::stub(get_all_teams, "check_mattermost_auth", function(auth) {})

  captured_args <- NULL
  mockery::stub(get_all_teams, "paginate_api", function(auth, endpoint, per_page, verbose) {
    captured_args <<- list(endpoint = endpoint, per_page = per_page, verbose = verbose)
    data.frame(id = "t1", stringsAsFactors = FALSE)
  })

  get_all_teams(verbose = TRUE, auth = mock_auth_helper())

  expect_equal(captured_args$endpoint, "/api/v4/teams")
  expect_equal(captured_args$per_page, 200)
  expect_true(captured_args$verbose)
})

