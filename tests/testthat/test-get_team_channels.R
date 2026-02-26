test_that("get_team_channels() rejects NULL team_id", {
  expect_error(get_team_channels(team_id = NULL),
               "team_id cannot be empty or NULL")
})

test_that("get_team_channels() rejects empty string team_id", {
  expect_error(get_team_channels(team_id = ""),
               "team_id cannot be empty or NULL")
})

test_that("get_team_channels() rejects invalid auth", {
  expect_error(get_team_channels(team_id = "team123", auth = NULL),
               "The provided object is not a valid 'mattermost_auth' object.")
})

test_that("get_team_channels() returns channels from paginate_api()", {
  mockery::stub(get_team_channels, "check_mattermost_auth", function(auth) {})

  channels_df <- data.frame(
    id = c("channel1", "channel2"),
    name = c("Channel One", "Channel Two"),
    stringsAsFactors = FALSE
  )
  mockery::stub(get_team_channels, "paginate_api", function(...) channels_df)

  result <- get_team_channels(team_id = "team123", auth = mock_auth_helper())
  expect_equal(result, channels_df)
})

test_that("get_team_channels() passes correct endpoint and params to paginate_api()", {
  mockery::stub(get_team_channels, "check_mattermost_auth", function(auth) {})

  captured_args <- NULL
  mockery::stub(get_team_channels, "paginate_api", function(auth, endpoint, per_page, verbose) {
    captured_args <<- list(endpoint = endpoint, per_page = per_page, verbose = verbose)
    data.frame(id = "ch1", stringsAsFactors = FALSE)
  })

  get_team_channels(team_id = "myteam", verbose = TRUE, auth = mock_auth_helper())

  expect_equal(captured_args$endpoint, "/api/v4/teams/myteam/channels")
  expect_equal(captured_args$per_page, 200)
  expect_true(captured_args$verbose)
})

test_that("get_team_channels() propagates paginate_api() errors", {
  mockery::stub(get_team_channels, "check_mattermost_auth", function(auth) {})
  mockery::stub(get_team_channels, "paginate_api", function(...) {
    stop("Team not found")
  })

  expect_error(get_team_channels(team_id = "invalid-team", auth = mock_auth_helper()),
               "Team not found")
})
