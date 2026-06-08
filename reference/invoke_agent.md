# Invoke an AI agent

Send a prompt to a Mattermost AI agent and receive a synchronous
response. The agent is identified by its Mattermost bot user ID and
invoked via the Agents v2.0 plugin completion endpoint.

## Usage

``` r
invoke_agent(
  bot_user_id,
  message,
  system_prompt = NULL,
  context = NULL,
  channel_id = NULL,
  timeout = 120,
  plugin_id = get_agents_plugin_id(),
  verbose = FALSE,
  auth = get_default_auth(),
  ...
)
```

## Arguments

- bot_user_id:

  Character. The Mattermost bot user ID of the agent to invoke. Retrieve
  available agents with
  [`list_agents()`](https://greengrassblueocean.github.io/MattermostR/reference/list_agents.md).

- message:

  Character. The user message (prompt) to send to the agent.

- system_prompt:

  Character or NULL. An optional system prompt that overrides the
  agent's configured instructions for this request only.

- context:

  List or NULL. A list of prior messages for multi-turn conversation
  context. Each element must be a list with `role` (`"user"` or
  `"assistant"`) and `content` (character) fields. Messages are
  prepended to the request in order.

- channel_id:

  Character or NULL. An optional channel ID to provide channel context
  to the agent (some agents use channel-specific tools or context).

- timeout:

  Numeric. Request timeout in seconds. Default `120`. Set higher for
  models with large thinking budgets or complex prompts.

- plugin_id:

  Character. The Agents plugin identifier. Defaults to
  [`get_agents_plugin_id()`](https://greengrassblueocean.github.io/MattermostR/reference/get_agents_plugin_id.md).

- verbose:

  Logical. Print detailed request information? Default `FALSE`.

- auth:

  A `mattermost_auth` object created by
  [`authenticate_mattermost()`](https://greengrassblueocean.github.io/MattermostR/reference/authenticate_mattermost.md).
  Defaults to `get_default_auth()`.

- ...:

  Additional named arguments to include in the JSON request body. Useful
  for experimental or newly added plugin API fields (e.g.
  `conversation_id`).

## Value

A named list containing the full parsed JSON response from the plugin.
At minimum, the list includes a `message` field with the agent's text
response. Additional fields (e.g. tool-call results, metadata) depend on
the plugin version and agent configuration.

## API Stability

This function wraps the Mattermost Agents plugin REST API, which is not
part of the stable Mattermost REST API v4 specification. Endpoint paths
and response schemas may change between plugin versions.

## Timeouts

LLM completion calls routinely take 30–120+ seconds, especially when
reasoning is enabled on the agent. The default `timeout = 120` seconds
is generous but may need increasing for complex prompts or models with
high thinking budgets. If the request times out, a `mattermost_error`
condition is raised.

## Headless Pipelines

When invoking agents from automated scripts (Airflow DAGs, cron jobs,
etc.), ensure the agent was created with `disable_tools = TRUE` (see
[`create_agent()`](https://greengrassblueocean.github.io/MattermostR/reference/create_agent.md)).
Otherwise, the LLM may attempt to use MCP tools that require interactive
UI approval, causing the request to hang or return a tool-approval
payload instead of a text response.

## See also

\[list_agents()\], \[get_agent()\], \[create_agent()\]

## Examples

``` r
if (FALSE) { # \dontrun{
  # 1. Discover available agents
  agents <- list_agents()
  print(agents)

  # 2. Simple single-turn invocation
  response <- invoke_agent(
    bot_user_id = "bot_user_id_abc",
    message     = "What is the current Fed funds rate?"
  )
  cat(response$message)

  # 3. With a custom system prompt
  response <- invoke_agent(
    bot_user_id   = "bot_user_id_abc",
    message       = "Summarize the ECB rate decision impact on EUR/USD",
    system_prompt = "You are a quant portfolio manager's assistant."
  )

  # 4. Multi-turn conversation
  response <- invoke_agent(
    bot_user_id = "bot_user_id_abc",
    message     = "What about the impact on fixed income?",
    context     = list(
      list(role = "user",      content = "Summarize the ECB rate decision."),
      list(role = "assistant", content = "The ECB cut rates by 25bp...")
    )
  )

  # 5. Extended timeout for reasoning models
  response <- invoke_agent(
    bot_user_id = "bot_user_id_abc",
    message     = "Build a DCF model for Boeing.",
    timeout     = 300
  )
} # }
```
