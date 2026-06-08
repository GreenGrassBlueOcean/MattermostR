# List AI agents

Retrieve a list of all AI agents configured on the Mattermost server via
the Agents v2.0 plugin.

## Usage

``` r
list_agents(
  plugin_id = get_agents_plugin_id(),
  verbose = FALSE,
  auth = get_default_auth()
)
```

## Arguments

- plugin_id:

  Character. The Agents plugin identifier. Defaults to
  [`get_agents_plugin_id()`](https://greengrassblueocean.github.io/MattermostR/reference/get_agents_plugin_id.md).

- verbose:

  Logical. Print detailed request information? Default `FALSE`.

- auth:

  A `mattermost_auth` object created by
  [`authenticate_mattermost()`](https://greengrassblueocean.github.io/MattermostR/reference/authenticate_mattermost.md).
  Defaults to `get_default_auth()`.

## Value

A data frame of agents. Columns typically include `id`, `bot_user_id`,
`display_name`, `instructions`, `model`, `enable_vision`,
`disable_tools`, `reasoning_enabled`, and others depending on the plugin
version. Returns an empty data frame if no agents are configured.

## API Stability

These functions wrap the Mattermost Agents plugin REST API, which is not
part of the stable Mattermost REST API v4 specification. Endpoint paths
and response schemas may change between plugin versions.

## See also

\[get_agent()\], \[create_agent()\], \[update_agent()\],
\[delete_agent()\], \[invoke_agent()\]

## Examples

``` r
if (FALSE) { # \dontrun{
  # List all agents
  agents <- list_agents()
  print(agents)

  # Find an agent by display name
  grok <- agents[agents$display_name == "Grok", ]
} # }
```
