# Update an AI agent

Update the configuration of an existing AI agent. Only the provided
fields are updated; omitted fields remain unchanged.

## Usage

``` r
update_agent(
  agent_id,
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
  auth = get_default_auth()
)
```

## Arguments

- agent_id:

  Character. The unique identifier of the agent to update.

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

A named list representing the updated agent.

## API Stability

These functions wrap the Mattermost Agents plugin REST API, which is not
part of the stable Mattermost REST API v4 specification. Endpoint paths
and response schemas may change between plugin versions.

## See also

\[create_agent()\], \[get_agent()\], \[delete_agent()\]

## Examples

``` r
if (FALSE) { # \dontrun{
  # Update the model and disable tools
  updated <- update_agent(
    agent_id      = "agent_id_abc",
    model         = "grok-3-mini",
    disable_tools = TRUE
  )

  # Change the system prompt
  updated <- update_agent(
    agent_id     = "agent_id_abc",
    instructions = "Be concise. Max 2 sentences per response."
  )
} # }
```
