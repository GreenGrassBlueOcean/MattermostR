# Get a single AI agent

Retrieve the configuration of a specific AI agent by its agent ID.

## Usage

``` r
get_agent(
  agent_id,
  plugin_id = get_agents_plugin_id(),
  verbose = FALSE,
  auth = get_default_auth()
)
```

## Arguments

- agent_id:

  Character. The unique identifier of the agent.

- plugin_id:

  Character. The Agents plugin identifier. Defaults to
  [`get_agents_plugin_id()`](https://greengrassblueocean.github.io/MattermostR/reference/get_agents_plugin_id.md).

- verbose:

  Logical. Print detailed request information? Default `FALSE`.

- auth:

  A `mattermost_auth` object. Defaults to `get_default_auth()`.

## Value

A named list representing the agent, with fields such as `id`,
`bot_user_id`, `display_name`, `instructions`, `model`, `enable_vision`,
`disable_tools`, `reasoning_enabled`, `reasoning_effort`,
`thinking_budget`, and `structured_output_enabled`.

## API Stability

These functions wrap the Mattermost Agents plugin REST API, which is not
part of the stable Mattermost REST API v4 specification. Endpoint paths
and response schemas may change between plugin versions.

## See also

\[list_agents()\], \[create_agent()\], \[update_agent()\],
\[delete_agent()\]

## Examples

``` r
if (FALSE) { # \dontrun{
  agent <- get_agent("agent_id_abc")
  agent$display_name
  agent$model
} # }
```
