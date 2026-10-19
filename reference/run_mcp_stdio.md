# Run the MattermostR MCP Server over stdio

Starts a blocking JSON-RPC 2.0 reading loop on standard input,
dispatching Mattermost channel inspection, search, messaging, and
noise-purge tools.

## Usage

``` r
run_mcp_stdio(
  con = NULL,
  test_mode = FALSE,
  auth = NULL,
  silent = FALSE,
  out_con = stderr()
)
```

## Arguments

- con:

  Connection to read from (default: stdin).

- test_mode:

  Logical. If \`TRUE\`, exits on EOF (default: \`FALSE\`).

- auth:

  Optional \`mattermost_auth\` object for testing or explicit auth.

- silent:

  Logical. If \`TRUE\`, suppresses startup messages. Default \`FALSE\`.

- out_con:

  Connection to write JSON-RPC responses to (default: \`stderr()\` for
  \`3\>&1 1\>&2 2\>&3\` OS wrapper compatibility).

## Value

Invisibly returns \`NULL\` when the loop terminates.

## Examples

``` r
if (FALSE) { # \dontrun{
run_mcp_stdio(silent = TRUE)
} # }
```
