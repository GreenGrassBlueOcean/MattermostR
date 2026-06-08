#' List AI agents
#'
#' Retrieve a list of all AI agents configured on the Mattermost server via the
#' Agents v2.0 plugin.
#'
#' @section API Stability:
#' These functions wrap the Mattermost Agents plugin REST API, which is not part
#' of the stable Mattermost REST API v4 specification. Endpoint paths and
#' response schemas may change between plugin versions.
#'
#' @param plugin_id Character. The Agents plugin identifier. Defaults to
#'   \code{\link{get_agents_plugin_id}()}.
#' @param verbose Logical. Print detailed request information? Default \code{FALSE}.
#' @param auth A \code{mattermost_auth} object created by
#'   \code{\link{authenticate_mattermost}()}. Defaults to
#'   \code{get_default_auth()}.
#'
#' @return A data frame of agents. Columns typically include \code{id},
#'   \code{bot_user_id}, \code{display_name}, \code{instructions},
#'   \code{model}, \code{enable_vision}, \code{disable_tools},
#'   \code{reasoning_enabled}, and others depending on the plugin version.
#'   Returns an empty data frame if no agents are configured.
#'
#' @seealso [get_agent()], [create_agent()], [update_agent()],
#'   [delete_agent()], [invoke_agent()]
#' @export
#' @examples
#' \dontrun{
#'   # List all agents
#'   agents <- list_agents()
#'   print(agents)
#'
#'   # Find an agent by display name
#'   grok <- agents[agents$display_name == "Grok", ]
#' }
list_agents <- function(plugin_id = get_agents_plugin_id(),
                        verbose = FALSE,
                        auth = get_default_auth()) {

  check_mattermost_auth(auth)

  result <- plugin_api_request(
    auth      = auth,
    plugin_id = plugin_id,
    path      = "/agents",
    method    = "GET",
    verbose   = verbose
  )

  if (is.null(result) || length(result) == 0L) {
    return(data.frame())
  }

  result
}


#' Get a single AI agent
#'
#' Retrieve the configuration of a specific AI agent by its agent ID.
#'
#' @inheritSection list_agents API Stability
#'
#' @param agent_id Character. The unique identifier of the agent.
#' @param plugin_id Character. The Agents plugin identifier. Defaults to
#'   \code{\link{get_agents_plugin_id}()}.
#' @param verbose Logical. Print detailed request information? Default \code{FALSE}.
#' @param auth A \code{mattermost_auth} object. Defaults to
#'   \code{get_default_auth()}.
#'
#' @return A named list representing the agent, with fields such as \code{id},
#'   \code{bot_user_id}, \code{display_name}, \code{instructions},
#'   \code{model}, \code{enable_vision}, \code{disable_tools},
#'   \code{reasoning_enabled}, \code{reasoning_effort},
#'   \code{thinking_budget}, and \code{structured_output_enabled}.
#'
#' @seealso [list_agents()], [create_agent()], [update_agent()],
#'   [delete_agent()]
#' @export
#' @examples
#' \dontrun{
#'   agent <- get_agent("agent_id_abc")
#'   agent$display_name
#'   agent$model
#' }
get_agent <- function(agent_id,
                      plugin_id = get_agents_plugin_id(),
                      verbose = FALSE,
                      auth = get_default_auth()) {

  check_not_null(agent_id, "agent_id")
  check_mattermost_auth(auth)

  plugin_api_request(
    auth      = auth,
    plugin_id = plugin_id,
    path      = paste0("/agents/", agent_id),
    method    = "GET",
    verbose   = verbose
  )
}


#' Create an AI agent
#'
#' Create a new AI agent on the Mattermost server. The agent is backed by an
#' existing Mattermost bot account and configured via the Agents v2.0 plugin.
#'
#' @inheritSection list_agents API Stability
#'
#' @details
#' The \code{reasoning_enabled} parameter defaults to \code{TRUE}, matching the
#' Agents v2.0 server-side default. When reasoning is enabled, the LLM may take
#' significantly longer to respond (30--120+ seconds). Use the \code{timeout}
#' parameter on \code{\link{invoke_agent}()} accordingly.
#'
#' \strong{Mutual exclusivity:} Some LLM providers (notably Anthropic) do not
#' support \code{structured_output_enabled = TRUE} simultaneously with
#' extended thinking (\code{reasoning_enabled = TRUE}). The server will reject
#' the payload if both are set. Consult your LLM provider documentation.
#'
#' \strong{Headless pipelines:} If the agent will be invoked from automated
#' scripts (Airflow DAGs, cron jobs, etc.), set \code{disable_tools = TRUE} to
#' prevent the LLM from attempting tool calls that require interactive UI
#' approval (the "MCP tool approval trap").
#'
#' @param bot_user_id Character. The Mattermost bot user ID to bind to this
#'   agent. The bot must already exist (see \code{\link{create_bot}()}).
#' @param display_name Character. Optional display name for the agent.
#' @param instructions Character. Optional system instructions (system prompt)
#'   for the agent.
#' @param model Character. Optional LLM model identifier
#'   (e.g. \code{"grok-3"}, \code{"gemini-2.0-flash"}).
#' @param enable_vision Logical. Enable vision capabilities? Default \code{FALSE}.
#' @param disable_tools Logical. Disable all tool/MCP calls? Default
#'   \code{FALSE}. Set to \code{TRUE} for headless automation.
#' @param enabled_native_tools Character vector or NULL. List of native tool
#'   names to enable. When \code{NULL}, uses the plugin default.
#' @param reasoning_enabled Logical. Enable extended thinking/reasoning?
#'   Default \code{TRUE} (v2.0 server default).
#' @param reasoning_effort Character or NULL. Reasoning effort level
#'   (provider-specific, e.g. \code{"low"}, \code{"medium"}, \code{"high"}).
#' @param thinking_budget Integer or NULL. Token budget for the reasoning
#'   phase.
#' @param structured_output_enabled Logical. Enable structured (JSON) output?
#'   Default \code{FALSE}. Cannot be combined with
#'   \code{reasoning_enabled = TRUE} on some providers.
#' @param plugin_id Character. The Agents plugin identifier. Defaults to
#'   \code{\link{get_agents_plugin_id}()}.
#' @param verbose Logical. Print detailed request information? Default \code{FALSE}.
#' @param auth A \code{mattermost_auth} object. Defaults to
#'   \code{get_default_auth()}.
#'
#' @return A named list representing the created agent.
#'
#' @seealso [list_agents()], [get_agent()], [update_agent()],
#'   [delete_agent()], [invoke_agent()], [create_bot()]
#' @export
#' @examples
#' \dontrun{
#'   # Create a simple agent
#'   agent <- create_agent(
#'     bot_user_id  = "bot_user_id_abc",
#'     display_name = "Quant Copilot",
#'     instructions = "You are a quantitative finance assistant.",
#'     model        = "grok-3"
#'   )
#'
#'   # Create an agent for headless pipelines (no tool approval prompts)
#'   pipeline_agent <- create_agent(
#'     bot_user_id   = "bot_user_id_abc",
#'     display_name  = "Pipeline Analyst",
#'     instructions  = "Summarize financial news in 3 bullet points.",
#'     model         = "grok-3",
#'     disable_tools = TRUE
#'   )
#' }
create_agent <- function(bot_user_id,
                         display_name = NULL,
                         instructions = NULL,
                         model = NULL,
                         enable_vision = FALSE,
                         disable_tools = FALSE,
                         enabled_native_tools = NULL,
                         reasoning_enabled = TRUE,
                         reasoning_effort = NULL,
                         thinking_budget = NULL,
                         structured_output_enabled = FALSE,
                         plugin_id = get_agents_plugin_id(),
                         verbose = FALSE,
                         auth = get_default_auth()) {

  check_not_null(bot_user_id, "bot_user_id")
  check_mattermost_auth(auth)

  body <- list(bot_user_id = bot_user_id)
  if (!is.null(display_name))         body$display_name             <- display_name
  if (!is.null(instructions))         body$instructions             <- instructions
  if (!is.null(model))                body$model                    <- model
  if (!is.null(enabled_native_tools)) body$enabled_native_tools     <- enabled_native_tools
  if (!is.null(reasoning_effort))     body$reasoning_effort         <- reasoning_effort
  if (!is.null(thinking_budget))      body$thinking_budget          <- as.integer(thinking_budget)

  # Boolean fields — always include to be explicit with the server

  body$enable_vision             <- enable_vision
  body$disable_tools             <- disable_tools
  body$reasoning_enabled         <- reasoning_enabled
  body$structured_output_enabled <- structured_output_enabled

  plugin_api_request(
    auth      = auth,
    plugin_id = plugin_id,
    path      = "/agents",
    method    = "POST",
    body      = body,
    verbose   = verbose
  )
}


#' Update an AI agent
#'
#' Update the configuration of an existing AI agent. Only the provided fields
#' are updated; omitted fields remain unchanged.
#'
#' @inheritSection list_agents API Stability
#' @inheritParams create_agent
#'
#' @param agent_id Character. The unique identifier of the agent to update.
#'
#' @return A named list representing the updated agent.
#'
#' @seealso [create_agent()], [get_agent()], [delete_agent()]
#' @export
#' @examples
#' \dontrun{
#'   # Update the model and disable tools
#'   updated <- update_agent(
#'     agent_id      = "agent_id_abc",
#'     model         = "grok-3-mini",
#'     disable_tools = TRUE
#'   )
#'
#'   # Change the system prompt
#'   updated <- update_agent(
#'     agent_id     = "agent_id_abc",
#'     instructions = "Be concise. Max 2 sentences per response."
#'   )
#' }
update_agent <- function(agent_id,
                         display_name = NULL,
                         instructions = NULL,
                         model = NULL,
                         enable_vision = NULL,
                         disable_tools = NULL,
                         enabled_native_tools = NULL,
                         reasoning_enabled = NULL,
                         reasoning_effort = NULL,
                         thinking_budget = NULL,
                         structured_output_enabled = NULL,
                         plugin_id = get_agents_plugin_id(),
                         verbose = FALSE,
                         auth = get_default_auth()) {

  check_not_null(agent_id, "agent_id")
  check_mattermost_auth(auth)

  body <- list()
  if (!is.null(display_name))             body$display_name             <- display_name
  if (!is.null(instructions))             body$instructions             <- instructions
  if (!is.null(model))                    body$model                    <- model
  if (!is.null(enable_vision))            body$enable_vision            <- enable_vision
  if (!is.null(disable_tools))            body$disable_tools            <- disable_tools
  if (!is.null(enabled_native_tools))     body$enabled_native_tools     <- enabled_native_tools
  if (!is.null(reasoning_enabled))        body$reasoning_enabled        <- reasoning_enabled
  if (!is.null(reasoning_effort))         body$reasoning_effort         <- reasoning_effort
  if (!is.null(thinking_budget))          body$thinking_budget          <- as.integer(thinking_budget)
  if (!is.null(structured_output_enabled)) body$structured_output_enabled <- structured_output_enabled

  if (length(body) == 0L) {
    stop("At least one field must be provided to update.", call. = FALSE)
  }

  plugin_api_request(
    auth      = auth,
    plugin_id = plugin_id,
    path      = paste0("/agents/", agent_id),
    method    = "PUT",
    body      = body,
    verbose   = verbose
  )
}


#' Delete an AI agent
#'
#' Remove an AI agent from the Mattermost server. This deletes the agent
#' configuration; the underlying Mattermost bot account is not affected.
#'
#' @inheritSection list_agents API Stability
#'
#' @param agent_id Character. The unique identifier of the agent to delete.
#' @param plugin_id Character. The Agents plugin identifier. Defaults to
#'   \code{\link{get_agents_plugin_id}()}.
#' @param verbose Logical. Print detailed request information? Default \code{FALSE}.
#' @param auth A \code{mattermost_auth} object. Defaults to
#'   \code{get_default_auth()}.
#'
#' @return \code{NULL}, invisibly. The agent is removed from the server.
#'
#' @seealso [create_agent()], [get_agent()], [list_agents()]
#' @export
#' @examples
#' \dontrun{
#'   delete_agent("agent_id_abc")
#' }
delete_agent <- function(agent_id,
                         plugin_id = get_agents_plugin_id(),
                         verbose = FALSE,
                         auth = get_default_auth()) {

  check_not_null(agent_id, "agent_id")
  check_mattermost_auth(auth)

  plugin_api_request(
    auth      = auth,
    plugin_id = plugin_id,
    path      = paste0("/agents/", agent_id),
    method    = "DELETE",
    verbose   = verbose
  )
}
