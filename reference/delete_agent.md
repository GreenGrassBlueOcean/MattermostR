# Delete an AI agent

Remove an AI agent from the Mattermost server. This deletes the agent
configuration; the underlying Mattermost bot account is not affected.

## Usage

``` r
delete_agent(
  agent_id,
  plugin_id = get_agents_plugin_id(),
  verbose = FALSE,
  auth = get_default_auth()
)
```

## Arguments

- agent_id:

  Character. The unique identifier of the agent to delete.

- plugin_id:

  Character. The Agents plugin identifier. Defaults to
  [`get_agents_plugin_id()`](https://greengrassblueocean.github.io/MattermostR/reference/get_agents_plugin_id.md).

- verbose:

  Logical. Print detailed request information? Default `FALSE`.

- auth:

  A `mattermost_auth` object. Defaults to `get_default_auth()`.

## Value

`NULL`, invisibly. The agent is removed from the server.

## API Stability

These functions wrap the Mattermost Agents plugin REST API, which is not
part of the stable Mattermost REST API v4 specification. Endpoint paths
and response schemas may change between plugin versions.

## See also

\[create_agent()\], \[get_agent()\], \[list_agents()\]

## Examples

``` r
if (FALSE) { # \dontrun{
  delete_agent("agent_id_abc")
} # }
```
