# Get the Agents Plugin ID

Resolves the Mattermost Agents plugin ID from
`getOption("MattermostR.agents_plugin_id")`. Defaults to
`"mattermost-ai-agents"`.

## Usage

``` r
get_agents_plugin_id()
```

## Value

A single character string containing the plugin ID.

## Details

The plugin ID determines the URL path prefix used when calling plugin
endpoints (e.g. `/plugins/<plugin_id>/api/v1/...`).

## See also

\[list_agents()\], \[invoke_agent()\]

## Examples

``` r
# View the current plugin ID
get_agents_plugin_id()
#> [1] "mattermost-ai-agents"

if (FALSE) { # \dontrun{
# Override for a custom plugin installation
options(MattermostR.agents_plugin_id = "com.mattermost.plugin-ai")
get_agents_plugin_id()
} # }
```
