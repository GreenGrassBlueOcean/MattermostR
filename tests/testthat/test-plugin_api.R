# Tests for plugin_api.R — transport layer and plugin ID resolution

test_that("get_agents_plugin_id returns default value", {
  withr::local_options(list(MattermostR.agents_plugin_id = NULL))
  expect_equal(get_agents_plugin_id(), "mattermost-ai-agents")
})

test_that("get_agents_plugin_id respects option override", {
  withr::local_options(list(MattermostR.agents_plugin_id = "com.mattermost.plugin-ai"))
  expect_equal(get_agents_plugin_id(), "com.mattermost.plugin-ai")
})

test_that("plugin_api_request constructs correct endpoint path", {
  fake_auth <- list(base_url = "https://mm.example.com", headers = "Bearer faketoken")
  class(fake_auth) <- "mattermost_auth"

  captured_endpoint <- NULL
  mock_api <- mockery::mock(list(ok = TRUE))
  mockery::stub(plugin_api_request, "mattermost_api_request", function(auth, endpoint, ...) {
    captured_endpoint <<- endpoint
    mock_api(auth, endpoint, ...)
  })

  plugin_api_request(
    auth      = fake_auth,
    plugin_id = "mattermost-ai-agents",
    path      = "/agents",
    method    = "GET"
  )

  expect_equal(captured_endpoint, "/plugins/mattermost-ai-agents/api/v1/agents")
})

test_that("plugin_api_request constructs nested path correctly", {
  fake_auth <- list(base_url = "https://mm.example.com", headers = "Bearer faketoken")
  class(fake_auth) <- "mattermost_auth"

  captured_endpoint <- NULL
  mockery::stub(plugin_api_request, "mattermost_api_request", function(auth, endpoint, ...) {
    captured_endpoint <<- endpoint
    list(message = "response")
  })

  plugin_api_request(
    auth      = fake_auth,
    plugin_id = "my-custom-plugin",
    path      = "/agents/abc123/completion",
    method    = "POST",
    body      = list(posts = list())
  )

  expect_equal(captured_endpoint, "/plugins/my-custom-plugin/api/v1/agents/abc123/completion")
})

test_that("plugin_api_request passes timeout through", {
  fake_auth <- list(base_url = "https://mm.example.com", headers = "Bearer faketoken")
  class(fake_auth) <- "mattermost_auth"

  captured_timeout <- NULL
  mockery::stub(plugin_api_request, "mattermost_api_request",
                function(auth, endpoint, method, body, timeout, verbose) {
    captured_timeout <<- timeout
    list(ok = TRUE)
  })

  plugin_api_request(
    auth      = fake_auth,
    plugin_id = "mattermost-ai-agents",
    path      = "/agents",
    method    = "GET",
    timeout   = 120
  )

  expect_equal(captured_timeout, 120)
})

test_that("plugin_api_request passes NULL timeout by default", {
  fake_auth <- list(base_url = "https://mm.example.com", headers = "Bearer faketoken")
  class(fake_auth) <- "mattermost_auth"

  captured_timeout <- "not_set"
  mockery::stub(plugin_api_request, "mattermost_api_request",
                function(auth, endpoint, method, body, timeout, verbose) {
    captured_timeout <<- timeout
    list(ok = TRUE)
  })

  plugin_api_request(
    auth      = fake_auth,
    plugin_id = "mattermost-ai-agents",
    path      = "/agents",
    method    = "GET"
  )

  expect_null(captured_timeout)
})

test_that("plugin_api_request propagates errors from mattermost_api_request", {
  fake_auth <- list(base_url = "https://mm.example.com", headers = "Bearer faketoken")
  class(fake_auth) <- "mattermost_auth"

  mockery::stub(plugin_api_request, "mattermost_api_request",
                function(...) stop("Connection refused"))

  expect_error(
    plugin_api_request(
      auth      = fake_auth,
      plugin_id = "mattermost-ai-agents",
      path      = "/agents",
      method    = "GET"
    ),
    "Connection refused"
  )
})
