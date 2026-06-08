# Create an AI agent

Create a new AI agent on the Mattermost server. The agent is backed by
an existing Mattermost bot account and configured via the Agents v2.0
plugin.

## Usage

``` r
create_agent(
  bot_user_id,
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
  auth = get_default_auth()
)
```

## Arguments

- bot_user_id:

  Character. The Mattermost bot user ID to bind to this agent. The bot
  must already exist (see
  [`create_bot()`](https://greengrassblueocean.github.io/MattermostR/reference/create_bot.md)).

- display_name:

  Character. Optional display name for the agent.

- instructions:

  Character. Optional system instructions (system prompt) for the agent.

- model:

  Character. Optional LLM model identifier (e.g. `"grok-3"`,
  `"gemini-2.0-flash"`).

- enable_vision:

  Logical. Enable vision capabilities? Default `FALSE`.

- disable_tools:

  Logical. Disable all tool/MCP calls? Default `FALSE`. Set to `TRUE`
  for headless automation.

- enabled_native_tools:

  Character vector or NULL. List of native tool names to enable. When
  `NULL`, uses the plugin default.

- reasoning_enabled:

  Logical. Enable extended thinking/reasoning? Default `TRUE` (v2.0
  server default).

- reasoning_effort:

  Character or NULL. Reasoning effort level (provider-specific, e.g.
  `"low"`, `"medium"`, `"high"`).

- thinking_budget:

  Integer or NULL. Token budget for the reasoning phase.

- structured_output_enabled:

  Logical. Enable structured (JSON) output? Default `FALSE`. Cannot be
  combined with `reasoning_enabled = TRUE` on some providers.

- plugin_id:

  Character. The Agents plugin identifier. Defaults to
  [`get_agents_plugin_id()`](https://greengrassblueocean.github.io/MattermostR/reference/get_agents_plugin_id.md).

- verbose:

  Logical. Print detailed request information? Default `FALSE`.

- auth:

  A `mattermost_auth` object. Defaults to `get_default_auth()`.

## Value

A named list representing the created agent.

## Details

The `reasoning_enabled` parameter defaults to `TRUE`, matching the
Agents v2.0 server-side default. When reasoning is enabled, the LLM may
take significantly longer to respond (30–120+ seconds). Use the
`timeout` parameter on
[`invoke_agent()`](https://greengrassblueocean.github.io/MattermostR/reference/invoke_agent.md)
accordingly.

**Mutual exclusivity:** Some LLM providers (notably Anthropic) do not
support `structured_output_enabled = TRUE` simultaneously with extended
thinking (`reasoning_enabled = TRUE`). The server will reject the
payload if both are set. Consult your LLM provider documentation.

**Headless pipelines:** If the agent will be invoked from automated
scripts (Airflow DAGs, cron jobs, etc.), set `disable_tools = TRUE` to
prevent the LLM from attempting tool calls that require interactive UI
approval (the "MCP tool approval trap").

## API Stability

These functions wrap the Mattermost Agents plugin REST API, which is not
part of the stable Mattermost REST API v4 specification. Endpoint paths
and response schemas may change between plugin versions.

## See also

\[list_agents()\], \[get_agent()\], \[update_agent()\],
\[delete_agent()\], \[invoke_agent()\], \[create_bot()\]

## Examples

``` r
if (FALSE) { # \dontrun{
  # Create a simple agent
  agent <- create_agent(
    bot_user_id  = "bot_user_id_abc",
    display_name = "Quant Copilot",
    instructions = "You are a quantitative finance assistant.",
    model        = "grok-3"
  )

  # Create an agent for headless pipelines (no tool approval prompts)
  pipeline_agent <- create_agent(
    bot_user_id   = "bot_user_id_abc",
    display_name  = "Pipeline Analyst",
    instructions  = "Summarize financial news in 3 bullet points.",
    model         = "grok-3",
    disable_tools = TRUE
  )
} # }
```
