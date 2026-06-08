# Tests for agents.R — Agent CRUD operations

# --- Shared fixtures ---
fake_auth <- list(base_url = "https://mm.example.com", headers = "Bearer faketoken")
class(fake_auth) <- "mattermost_auth"

mock_agent_response <- list(
  id                       = "agent_001",
  bot_user_id              = "bot_user_abc",
  display_name             = "Quant Copilot",
  instructions             = "You are a quant assistant.",
  model                    = "grok-3",
  enable_vision            = FALSE,
  disable_tools            = TRUE,
  reasoning_enabled        = TRUE,
  reasoning_effort         = "medium",
  thinking_budget          = 4096L,
  structured_output_enabled = FALSE
)


# ============================================================================
# list_agents
# ============================================================================

test_that("list_agents calls plugin_api_request with correct path", {
  captured_path <- NULL
  mockery::stub(list_agents, "plugin_api_request",
                function(auth, plugin_id, path, method, ...) {
    captured_path <<- path
    data.frame(id = "agent_001", display_name = "Copilot", stringsAsFactors = FALSE)
  })

  result <- list_agents(auth = fake_auth)
  expect_equal(captured_path, "/agents")
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 1L)
})

test_that("list_agents returns empty data frame when no agents exist", {
  mockery::stub(list_agents, "plugin_api_request",
                function(...) NULL)

  result <- list_agents(auth = fake_auth)
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 0L)
})

test_that("list_agents returns empty data frame for empty list", {
  mockery::stub(list_agents, "plugin_api_request",
                function(...) list())

  result <- list_agents(auth = fake_auth)
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 0L)
})

test_that("list_agents validates auth", {
  expect_error(list_agents(auth = "not_auth"), "not a valid")
})


# ============================================================================
# get_agent
# ============================================================================

test_that("get_agent calls correct path with agent_id", {
  captured_path <- NULL
  mockery::stub(get_agent, "plugin_api_request",
                function(auth, plugin_id, path, method, ...) {
    captured_path <<- path
    mock_agent_response
  })

  result <- get_agent("agent_001", auth = fake_auth)
  expect_equal(captured_path, "/agents/agent_001")
  expect_equal(result$display_name, "Quant Copilot")
})

test_that("get_agent validates agent_id is not null", {
  expect_error(get_agent(NULL, auth = fake_auth), "agent_id")
})

test_that("get_agent validates auth", {
  expect_error(get_agent("agent_001", auth = "bad"), "not a valid")
})


# ============================================================================
# create_agent
# ============================================================================

test_that("create_agent sends correct body with v2.0 fields", {
  captured_body <- NULL
  mockery::stub(create_agent, "plugin_api_request",
                function(auth, plugin_id, path, method, body, ...) {
    captured_body <<- body
    mock_agent_response
  })

  result <- create_agent(
    bot_user_id              = "bot_user_abc",
    display_name             = "Quant Copilot",
    instructions             = "You are a quant assistant.",
    model                    = "grok-3",
    enable_vision            = FALSE,
    disable_tools            = TRUE,
    reasoning_enabled        = TRUE,
    reasoning_effort         = "medium",
    thinking_budget          = 4096,
    structured_output_enabled = FALSE,
    auth                     = fake_auth
  )

  expect_equal(captured_body$bot_user_id, "bot_user_abc")
  expect_equal(captured_body$display_name, "Quant Copilot")
  expect_equal(captured_body$instructions, "You are a quant assistant.")
  expect_equal(captured_body$model, "grok-3")
  expect_false(captured_body$enable_vision)
  expect_true(captured_body$disable_tools)
  expect_true(captured_body$reasoning_enabled)
  expect_equal(captured_body$reasoning_effort, "medium")
  expect_equal(captured_body$thinking_budget, 4096L)
  expect_false(captured_body$structured_output_enabled)
})

test_that("create_agent uses POST method on /agents", {
  captured_method <- NULL
  captured_path <- NULL
  mockery::stub(create_agent, "plugin_api_request",
                function(auth, plugin_id, path, method, body, ...) {
    captured_method <<- method
    captured_path <<- path
    mock_agent_response
  })

  create_agent(bot_user_id = "bot_user_abc", auth = fake_auth)
  expect_equal(captured_method, "POST")
  expect_equal(captured_path, "/agents")
})

test_that("create_agent validates bot_user_id is not null", {
  expect_error(create_agent(NULL, auth = fake_auth), "bot_user_id")
})

test_that("create_agent validates auth", {
  expect_error(create_agent("bot_abc", auth = "bad"), "not a valid")
})

test_that("create_agent sets boolean defaults correctly", {
  captured_body <- NULL
  mockery::stub(create_agent, "plugin_api_request",
                function(auth, plugin_id, path, method, body, ...) {
    captured_body <<- body
    mock_agent_response
  })

  create_agent(bot_user_id = "bot_abc", auth = fake_auth)

  # Default booleans

  expect_false(captured_body$enable_vision)
  expect_false(captured_body$disable_tools)
  expect_true(captured_body$reasoning_enabled)
  expect_false(captured_body$structured_output_enabled)

  # Optional fields should NOT be in the body when NULL
  expect_null(captured_body$display_name)
  expect_null(captured_body$instructions)
  expect_null(captured_body$model)
  expect_null(captured_body$enabled_native_tools)
  expect_null(captured_body$reasoning_effort)
  expect_null(captured_body$thinking_budget)
})

test_that("create_agent coerces thinking_budget to integer", {
  captured_body <- NULL
  mockery::stub(create_agent, "plugin_api_request",
                function(auth, plugin_id, path, method, body, ...) {
    captured_body <<- body
    mock_agent_response
  })

  create_agent(bot_user_id = "bot_abc", thinking_budget = 8192.5, auth = fake_auth)
  expect_true(is.integer(captured_body$thinking_budget))
  expect_equal(captured_body$thinking_budget, 8192L)
})


# ============================================================================
# update_agent
# ============================================================================

test_that("update_agent sends correct path and method", {
  captured_path <- NULL
  captured_method <- NULL
  mockery::stub(update_agent, "plugin_api_request",
                function(auth, plugin_id, path, method, body, ...) {
    captured_path <<- path
    captured_method <<- method
    mock_agent_response
  })

  update_agent(agent_id = "agent_001", display_name = "New Name", auth = fake_auth)
  expect_equal(captured_path, "/agents/agent_001")
  expect_equal(captured_method, "PUT")
})

test_that("update_agent sends only provided fields", {
  captured_body <- NULL
  mockery::stub(update_agent, "plugin_api_request",
                function(auth, plugin_id, path, method, body, ...) {
    captured_body <<- body
    mock_agent_response
  })

  update_agent(
    agent_id      = "agent_001",
    model         = "grok-3-mini",
    disable_tools = TRUE,
    auth          = fake_auth
  )

  expect_equal(captured_body$model, "grok-3-mini")
  expect_true(captured_body$disable_tools)
  # Fields not provided should be absent
  expect_null(captured_body$display_name)
  expect_null(captured_body$instructions)
  expect_null(captured_body$enable_vision)
  expect_null(captured_body$reasoning_enabled)
})

test_that("update_agent errors when no fields provided", {
  expect_error(update_agent(agent_id = "agent_001", auth = fake_auth),
               "At least one field")
})

test_that("update_agent validates agent_id is not null", {
  expect_error(update_agent(NULL, display_name = "X", auth = fake_auth), "agent_id")
})

test_that("update_agent validates auth", {
  expect_error(update_agent("agent_001", display_name = "X", auth = "bad"),
               "not a valid")
})


# ============================================================================
# delete_agent
# ============================================================================

test_that("delete_agent sends DELETE to correct path", {
  captured_path <- NULL
  captured_method <- NULL
  mockery::stub(delete_agent, "plugin_api_request",
                function(auth, plugin_id, path, method, ...) {
    captured_path <<- path
    captured_method <<- method
    NULL
  })

  result <- delete_agent("agent_001", auth = fake_auth)
  expect_equal(captured_path, "/agents/agent_001")
  expect_equal(captured_method, "DELETE")
})

test_that("delete_agent validates agent_id", {
  expect_error(delete_agent(NULL, auth = fake_auth), "agent_id")
})

test_that("delete_agent validates auth", {
  expect_error(delete_agent("agent_001", auth = "bad"), "not a valid")
})

test_that("create_agent passes enabled_native_tools", {
  captured_body <- NULL
  mockery::stub(create_agent, "plugin_api_request",
                function(auth, plugin_id, path, method, body, ...) {
    captured_body <<- body
    mock_agent_response
  })

  create_agent(
    bot_user_id = "bot_abc",
    enabled_native_tools = c("web_search", "fetch_url"),
    auth = fake_auth
  )
  expect_equal(captured_body$enabled_native_tools, c("web_search", "fetch_url"))
})

test_that("update_agent sends all optional fields when provided", {
  captured_body <- NULL
  mockery::stub(update_agent, "plugin_api_request",
                function(auth, plugin_id, path, method, body, ...) {
    captured_body <<- body
    mock_agent_response
  })

  update_agent(
    agent_id                  = "agent_001",
    instructions              = "System prompt override",
    enable_vision             = TRUE,
    enabled_native_tools      = c("web_search"),
    reasoning_enabled         = FALSE,
    reasoning_effort          = "low",
    thinking_budget           = 1024,
    structured_output_enabled = TRUE,
    auth                      = fake_auth
  )

  expect_equal(captured_body$instructions, "System prompt override")
  expect_true(captured_body$enable_vision)
  expect_equal(captured_body$enabled_native_tools, c("web_search"))
  expect_false(captured_body$reasoning_enabled)
  expect_equal(captured_body$reasoning_effort, "low")
  expect_equal(captured_body$thinking_budget, 1024L)
  expect_true(captured_body$structured_output_enabled)
})

