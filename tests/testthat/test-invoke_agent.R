# Tests for invoke_agent.R — AI agent invocation

# --- Shared fixtures ---
fake_auth <- list(base_url = "https://mm.example.com", headers = "Bearer faketoken")
class(fake_auth) <- "mattermost_auth"

mock_completion_response <- list(
  message = "The ECB cut rates by 25bp, weakening EUR/USD by 50 pips."
)


# ============================================================================
# Single-turn invocation
# ============================================================================

test_that("invoke_agent sends correct path and method", {
  captured_path <- NULL
  captured_method <- NULL
  mockery::stub(invoke_agent, "plugin_api_request",
                function(auth, plugin_id, path, method, body, timeout, ...) {
    captured_path <<- path
    captured_method <<- method
    mock_completion_response
  })

  result <- invoke_agent(
    bot_user_id = "bot_abc",
    message     = "What is the ECB rate?",
    auth        = fake_auth
  )

  expect_equal(captured_path, "/agents/bot_abc/completion")
  expect_equal(captured_method, "POST")
  expect_equal(result$message, mock_completion_response$message)
})

test_that("invoke_agent builds posts array with user message", {
  captured_body <- NULL
  mockery::stub(invoke_agent, "plugin_api_request",
                function(auth, plugin_id, path, method, body, timeout, ...) {
    captured_body <<- body
    mock_completion_response
  })

  invoke_agent(bot_user_id = "bot_abc", message = "Hello!", auth = fake_auth)

  expect_true(is.list(captured_body$posts))
  expect_length(captured_body$posts, 1L)
  expect_equal(captured_body$posts[[1]]$role, "user")
  expect_equal(captured_body$posts[[1]]$content, "Hello!")
})


# ============================================================================
# System prompt
# ============================================================================

test_that("invoke_agent prepends system prompt", {
  captured_body <- NULL
  mockery::stub(invoke_agent, "plugin_api_request",
                function(auth, plugin_id, path, method, body, timeout, ...) {
    captured_body <<- body
    mock_completion_response
  })

  invoke_agent(
    bot_user_id   = "bot_abc",
    message       = "Summarize.",
    system_prompt = "You are a quant assistant.",
    auth          = fake_auth
  )

  expect_length(captured_body$posts, 2L)
  expect_equal(captured_body$posts[[1]]$role, "system")
  expect_equal(captured_body$posts[[1]]$content, "You are a quant assistant.")
  expect_equal(captured_body$posts[[2]]$role, "user")
  expect_equal(captured_body$posts[[2]]$content, "Summarize.")
})

test_that("invoke_agent skips empty system prompt", {
  captured_body <- NULL
  mockery::stub(invoke_agent, "plugin_api_request",
                function(auth, plugin_id, path, method, body, timeout, ...) {
    captured_body <<- body
    mock_completion_response
  })

  invoke_agent(
    bot_user_id   = "bot_abc",
    message       = "Hello",
    system_prompt = "",
    auth          = fake_auth
  )

  expect_length(captured_body$posts, 1L)
  expect_equal(captured_body$posts[[1]]$role, "user")
})


# ============================================================================
# Multi-turn context
# ============================================================================

test_that("invoke_agent includes context messages in correct order", {
  captured_body <- NULL
  mockery::stub(invoke_agent, "plugin_api_request",
                function(auth, plugin_id, path, method, body, timeout, ...) {
    captured_body <<- body
    mock_completion_response
  })

  invoke_agent(
    bot_user_id = "bot_abc",
    message     = "What about fixed income?",
    context     = list(
      list(role = "user",      content = "Tell me about FX."),
      list(role = "assistant", content = "EUR/USD dropped 50 pips.")
    ),
    auth = fake_auth
  )

  expect_length(captured_body$posts, 3L)
  expect_equal(captured_body$posts[[1]]$role, "user")
  expect_equal(captured_body$posts[[1]]$content, "Tell me about FX.")
  expect_equal(captured_body$posts[[2]]$role, "assistant")
  expect_equal(captured_body$posts[[3]]$role, "user")
  expect_equal(captured_body$posts[[3]]$content, "What about fixed income?")
})

test_that("invoke_agent orders: system, context, user message", {
  captured_body <- NULL
  mockery::stub(invoke_agent, "plugin_api_request",
                function(auth, plugin_id, path, method, body, timeout, ...) {
    captured_body <<- body
    mock_completion_response
  })

  invoke_agent(
    bot_user_id   = "bot_abc",
    message       = "Follow-up question",
    system_prompt = "Be concise.",
    context       = list(
      list(role = "user", content = "Prior question")
    ),
    auth = fake_auth
  )

  expect_length(captured_body$posts, 3L)
  expect_equal(captured_body$posts[[1]]$role, "system")
  expect_equal(captured_body$posts[[2]]$role, "user")
  expect_equal(captured_body$posts[[2]]$content, "Prior question")
  expect_equal(captured_body$posts[[3]]$role, "user")
  expect_equal(captured_body$posts[[3]]$content, "Follow-up question")
})


# ============================================================================
# Context validation
# ============================================================================

test_that("invoke_agent errors when context is not a list", {
  expect_error(
    invoke_agent(bot_user_id = "bot_abc", message = "Hi",
                 context = "not a list", auth = fake_auth),
    "context.*must be a list"
  )
})

test_that("invoke_agent errors when context element lacks role or content", {
  expect_error(
    invoke_agent(bot_user_id = "bot_abc", message = "Hi",
                 context = list(list(role = "user")), auth = fake_auth),
    "role.*content"
  )

  expect_error(
    invoke_agent(bot_user_id = "bot_abc", message = "Hi",
                 context = list(list(content = "no role")), auth = fake_auth),
    "role.*content"
  )
})


# ============================================================================
# Channel ID and extra args
# ============================================================================

test_that("invoke_agent includes channel_id when provided", {
  captured_body <- NULL
  mockery::stub(invoke_agent, "plugin_api_request",
                function(auth, plugin_id, path, method, body, timeout, ...) {
    captured_body <<- body
    mock_completion_response
  })

  invoke_agent(bot_user_id = "bot_abc", message = "Hi",
               channel_id = "ch_123", auth = fake_auth)

  expect_equal(captured_body$channel_id, "ch_123")
})

test_that("invoke_agent omits channel_id when NULL", {
  captured_body <- NULL
  mockery::stub(invoke_agent, "plugin_api_request",
                function(auth, plugin_id, path, method, body, timeout, ...) {
    captured_body <<- body
    mock_completion_response
  })

  invoke_agent(bot_user_id = "bot_abc", message = "Hi", auth = fake_auth)

  expect_null(captured_body$channel_id)
})

test_that("invoke_agent merges extra ... args into body", {
  captured_body <- NULL
  mockery::stub(invoke_agent, "plugin_api_request",
                function(auth, plugin_id, path, method, body, timeout, ...) {
    captured_body <<- body
    mock_completion_response
  })

  invoke_agent(
    bot_user_id     = "bot_abc",
    message         = "Hi",
    auth            = fake_auth,
    conversation_id = "conv_xyz",
    temperature     = 0.7
  )

  expect_equal(captured_body$conversation_id, "conv_xyz")
  expect_equal(captured_body$temperature, 0.7)
})


# ============================================================================
# Timeout
# ============================================================================

test_that("invoke_agent passes timeout to plugin_api_request", {
  captured_timeout <- NULL
  mockery::stub(invoke_agent, "plugin_api_request",
                function(auth, plugin_id, path, method, body, timeout, ...) {
    captured_timeout <<- timeout
    mock_completion_response
  })

  invoke_agent(bot_user_id = "bot_abc", message = "Hi",
               timeout = 300, auth = fake_auth)

  expect_equal(captured_timeout, 300)
})

test_that("invoke_agent defaults timeout to 120 seconds", {
  captured_timeout <- NULL
  mockery::stub(invoke_agent, "plugin_api_request",
                function(auth, plugin_id, path, method, body, timeout, ...) {
    captured_timeout <<- timeout
    mock_completion_response
  })

  invoke_agent(bot_user_id = "bot_abc", message = "Hi", auth = fake_auth)

  expect_equal(captured_timeout, 120)
})


# ============================================================================
# Return value
# ============================================================================

test_that("invoke_agent returns full parsed JSON response", {
  full_response <- list(
    message   = "Response text",
    tool_call = list(name = "web_search", result = "data"),
    tokens    = 42L
  )
  mockery::stub(invoke_agent, "plugin_api_request",
                function(...) full_response)

  result <- invoke_agent(bot_user_id = "bot_abc", message = "Hi", auth = fake_auth)

  expect_equal(result$message, "Response text")
  expect_equal(result$tool_call$name, "web_search")
  expect_equal(result$tokens, 42L)
})


# ============================================================================
# Input validation
# ============================================================================

test_that("invoke_agent validates bot_user_id", {
  expect_error(invoke_agent(NULL, message = "Hi", auth = fake_auth), "bot_user_id")
})

test_that("invoke_agent validates message", {
  expect_error(invoke_agent("bot_abc", message = NULL, auth = fake_auth), "message")
})

test_that("invoke_agent validates auth", {
  expect_error(invoke_agent("bot_abc", message = "Hi", auth = "bad"), "not a valid")
})

test_that("invoke_agent prints request body when verbose = TRUE", {
  mockery::stub(invoke_agent, "plugin_api_request", function(...) mock_completion_response)

  output <- capture.output({
    invoke_agent(
      bot_user_id = "bot_abc",
      message     = "Hi",
      verbose     = TRUE,
      auth        = fake_auth
    )
  })

  expect_true(any(grepl("invoke_agent request body:", output)))
  expect_true(any(grepl("posts", output)))
  expect_true(any(grepl("Hi", output)))
})

