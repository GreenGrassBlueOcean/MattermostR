#' Get the Agents Plugin ID
#'
#' Resolves the Mattermost Agents plugin ID from
#' \code{getOption("MattermostR.agents_plugin_id")}. Defaults to
#' \code{"mattermost-ai-agents"}.
#'
#' The plugin ID determines the URL path prefix used when calling plugin
#' endpoints (e.g. \code{/plugins/<plugin_id>/api/v1/...}).
#'
#' @return A single character string containing the plugin ID.
#'
#' @seealso [list_agents()], [invoke_agent()]
#' @export
#' @examples
#' # View the current plugin ID
#' get_agents_plugin_id()
#'
#' \dontrun{
#' # Override for a custom plugin installation
#' options(MattermostR.agents_plugin_id = "com.mattermost.plugin-ai")
#' get_agents_plugin_id()
#' }
get_agents_plugin_id <- function() {
  getOption("MattermostR.agents_plugin_id", "mattermost-ai-agents")
}


#' Make a Mattermost Plugin API Request
#'
#' Internal helper that routes requests through
#' \code{\link{mattermost_api_request}} using the plugin endpoint path
#' prefix \code{/plugins/<plugin_id>/api/v1}.
#'
#' @param auth A \code{mattermost_auth} object.
#' @param plugin_id Character. The plugin identifier.
#' @param path Character. The path within the plugin API
#'   (e.g. \code{"/agents"}, \code{"/agents/abc123/completion"}).
#' @param method Character. HTTP method (\code{"GET"}, \code{"POST"},
#'   \code{"PUT"}, \code{"DELETE"}).
#' @param body Optional list. The JSON request body.
#' @param timeout Numeric or NULL. Request timeout in seconds.
#' @param verbose Logical. Print detailed request information?
#'
#' @return The parsed response from \code{mattermost_api_request}.
#' @noRd
plugin_api_request <- function(auth, plugin_id, path, method = "GET",
                               body = NULL, timeout = NULL, verbose = FALSE) {

  endpoint <- paste0("/plugins/", plugin_id, "/api/v1", path)

  mattermost_api_request(
    auth     = auth,
    endpoint = endpoint,
    method   = method,
    body     = body,
    timeout  = timeout,
    verbose  = verbose
  )
}
