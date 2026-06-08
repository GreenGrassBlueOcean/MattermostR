#' Invoke an AI agent
#'
#' Send a prompt to a Mattermost AI agent and receive a synchronous response.
#' The agent is identified by its Mattermost bot user ID and invoked via the
#' Agents v2.0 plugin completion endpoint.
#'
#' @section API Stability:
#' This function wraps the Mattermost Agents plugin REST API, which is not part
#' of the stable Mattermost REST API v4 specification. Endpoint paths and
#' response schemas may change between plugin versions.
#'
#' @section Timeouts:
#' LLM completion calls routinely take 30--120+ seconds, especially when
#' reasoning is enabled on the agent. The default \code{timeout = 120} seconds
#' is generous but may need increasing for complex prompts or models with
#' high thinking budgets. If the request times out, a
#' \code{mattermost_error} condition is raised.
#'
#' @section Headless Pipelines:
#' When invoking agents from automated scripts (Airflow DAGs, cron jobs, etc.),
#' ensure the agent was created with \code{disable_tools = TRUE} (see
#' \code{\link{create_agent}()}). Otherwise, the LLM may attempt to use MCP
#' tools that require interactive UI approval, causing the request to hang or
#' return a tool-approval payload instead of a text response.
#'
#' @param bot_user_id Character. The Mattermost bot user ID of the agent to
#'   invoke. Retrieve available agents with \code{\link{list_agents}()}.
#' @param message Character. The user message (prompt) to send to the agent.
#' @param system_prompt Character or NULL. An optional system prompt that
#'   overrides the agent's configured instructions for this request only.
#' @param context List or NULL. A list of prior messages for multi-turn
#'   conversation context. Each element must be a list with \code{role}
#'   (\code{"user"} or \code{"assistant"}) and \code{content} (character)
#'   fields. Messages are prepended to the request in order.
#' @param channel_id Character or NULL. An optional channel ID to provide
#'   channel context to the agent (some agents use channel-specific tools
#'   or context).
#' @param timeout Numeric. Request timeout in seconds. Default \code{120}.
#'   Set higher for models with large thinking budgets or complex prompts.
#' @param plugin_id Character. The Agents plugin identifier. Defaults to
#'   \code{\link{get_agents_plugin_id}()}.
#' @param verbose Logical. Print detailed request information? Default \code{FALSE}.
#' @param auth A \code{mattermost_auth} object created by
#'   \code{\link{authenticate_mattermost}()}. Defaults to
#'   \code{get_default_auth()}.
#' @param ... Additional named arguments to include in the JSON request body.
#'   Useful for experimental or newly added plugin API fields (e.g.
#'   \code{conversation_id}).
#'
#' @return A named list containing the full parsed JSON response from the
#'   plugin. At minimum, the list includes a \code{message} field with the
#'   agent's text response. Additional fields (e.g. tool-call results,
#'   metadata) depend on the plugin version and agent configuration.
#'
#' @seealso [list_agents()], [get_agent()], [create_agent()]
#' @export
#' @examples
#' \dontrun{
#'   # 1. Discover available agents
#'   agents <- list_agents()
#'   print(agents)
#'
#'   # 2. Simple single-turn invocation
#'   response <- invoke_agent(
#'     bot_user_id = "bot_user_id_abc",
#'     message     = "What is the current Fed funds rate?"
#'   )
#'   cat(response$message)
#'
#'   # 3. With a custom system prompt
#'   response <- invoke_agent(
#'     bot_user_id   = "bot_user_id_abc",
#'     message       = "Summarize the ECB rate decision impact on EUR/USD",
#'     system_prompt = "You are a quant portfolio manager's assistant."
#'   )
#'
#'   # 4. Multi-turn conversation
#'   response <- invoke_agent(
#'     bot_user_id = "bot_user_id_abc",
#'     message     = "What about the impact on fixed income?",
#'     context     = list(
#'       list(role = "user",      content = "Summarize the ECB rate decision."),
#'       list(role = "assistant", content = "The ECB cut rates by 25bp...")
#'     )
#'   )
#'
#'   # 5. Extended timeout for reasoning models
#'   response <- invoke_agent(
#'     bot_user_id = "bot_user_id_abc",
#'     message     = "Build a DCF model for Boeing.",
#'     timeout     = 300
#'   )
#' }
invoke_agent <- function(bot_user_id,
                         message,
                         system_prompt = NULL,
                         context = NULL,
                         channel_id = NULL,
                         timeout = 120,
                         plugin_id = get_agents_plugin_id(),
                         verbose = FALSE,
                         auth = get_default_auth(),
                         ...) {

  # --- Input validation ---
  check_not_null(bot_user_id, "bot_user_id")
  check_not_null(message, "message")
  check_mattermost_auth(auth)

  # --- Build the posts array ---
  posts <- list()

  # System prompt (prepended first)
  if (!is.null(system_prompt) && nzchar(system_prompt)) {
    posts[[length(posts) + 1L]] <- list(role = "system", content = system_prompt)
  }

  # Multi-turn context (appended in order)
  if (!is.null(context)) {
    if (!is.list(context)) {
      stop("'context' must be a list of message lists with 'role' and 'content' fields.",
           call. = FALSE)
    }
    for (msg in context) {
      if (!is.list(msg) || is.null(msg$role) || is.null(msg$content)) {
        stop("Each element of 'context' must be a list with 'role' and 'content' fields.",
             call. = FALSE)
      }
      posts[[length(posts) + 1L]] <- list(role = msg$role, content = msg$content)
    }
  }

  # Current user message (appended last)
  posts[[length(posts) + 1L]] <- list(role = "user", content = message)

  # --- Build request body ---
  body <- list(posts = posts)

  if (!is.null(channel_id)) {
    body$channel_id <- channel_id
  }

  # Merge any additional experimental fields from ...
  extra_args <- list(...)
  if (length(extra_args) > 0L) {
    for (nm in names(extra_args)) {
      body[[nm]] <- extra_args[[nm]]
    }
  }

  # --- Verbose output ---
  if (verbose) {
    cat("invoke_agent request body:\n",
        jsonlite::toJSON(body, auto_unbox = TRUE, pretty = TRUE), "\n")
  }

  # --- Execute completion ---
  path <- paste0("/agents/", bot_user_id, "/completion")

  plugin_api_request(
    auth      = auth,
    plugin_id = plugin_id,
    path      = path,
    method    = "POST",
    body      = body,
    timeout   = timeout,
    verbose   = verbose
  )
}
