# =============================================================================
# mcp_server.R — Model Context Protocol (MCP) Server for MattermostR
# =============================================================================

`%||%` <- function(x, y) if (is.null(x)) y else x
.datatable.aware <- TRUE

.mm_empty_object <- function() {
  stats::setNames(list(), character(0L))
}

#' Run the MattermostR MCP Server over stdio
#'
#' Starts a blocking JSON-RPC 2.0 reading loop on standard input, dispatching
#' Mattermost channel inspection, search, messaging, and noise-purge tools.
#'
#' @param con Connection to read from (default: stdin).
#' @param test_mode Logical. If `TRUE`, exits on EOF (default: `FALSE`).
#' @param auth Optional `mattermost_auth` object for testing or explicit auth.
#' @param silent Logical. If `TRUE`, suppresses startup messages. Default `FALSE`.
#' @param out_con Connection to write JSON-RPC responses to (default: `stderr()`
#'   for `3>&1 1>&2 2>&3` OS wrapper compatibility).
#' @return Invisibly returns `NULL` when the loop terminates.
#' @export
#' @examples
#' \dontrun{
#' run_mcp_stdio(silent = TRUE)
#' }
run_mcp_stdio <- function(con = NULL, test_mode = FALSE, auth = NULL,
                          silent = FALSE, out_con = stderr()) {
  if (!test_mode) {
    sink(stderr(), type = "output")
    on.exit(sink(NULL, type = "output"), add = TRUE)
  }

  state <- new.env(parent = emptyenv())
  state$auth <- auth
  state$silent <- silent

  if (!silent) {
    message("[MattermostR MCP] Ready.")
  }

  if (is.null(con)) {
    con <- file("stdin", open = "r")
    on.exit(close(con), add = TRUE)
  }

  while (TRUE) {
    line <- readLines(con, n = 1L, warn = FALSE)
    if (length(line) == 0L) {
      if (test_mode) break
      Sys.sleep(0.1)
      next
    }
    if (!nzchar(trimws(line))) next

    tryCatch({
      req <- jsonlite::fromJSON(line, simplifyVector = FALSE)
      if (!is.null(req$method)) {
        if (is.null(req$id)) next
        res <- .mm_mcp_handle_request(req, state)
        cat(as.character(jsonlite::toJSON(res, auto_unbox = TRUE)), "\n",
            file = out_con, sep = "")
        utils::flush.console()
      }
    }, error = function(e) {
      err_response <- list(
        jsonrpc = "2.0",
        id = NULL,
        error = list(code = -32700L, message = paste("Parse error:", e$message))
      )
      cat(as.character(jsonlite::toJSON(err_response, auto_unbox = TRUE)), "\n",
          file = out_con, sep = "")
      utils::flush.console()
    })
  }
  invisible(NULL)
}

#' @keywords internal
#' @noRd
.mm_mcp_resolve_auth <- function(state) {
  if (!is.null(state$auth) && inherits(state$auth, "mattermost_auth")) {
    return(state$auth)
  }
  state$auth <- get_default_auth()
  state$auth
}

#' @keywords internal
#' @noRd
.mm_mcp_resolve_channel_id <- function(channel_id = NULL, channel_name = NULL,
                                       team_id = NULL, auth) {
  if (!is.null(channel_id) && nzchar(as.character(channel_id)[1L])) {
    return(as.character(channel_id)[1L])
  }
  if (is.null(channel_name) || !nzchar(as.character(channel_name)[1L])) {
    stop("Either 'channel_id' or 'channel_name' must be provided.")
  }
  if (is.null(team_id) || !nzchar(as.character(team_id)[1L])) {
    teams <- get_all_teams(auth = auth)
    if (!is.data.frame(teams) || nrow(teams) == 0L) {
      stop("No Mattermost teams found for authenticated user.")
    }
    team_id <- as.character(teams$id[1L])
  }
  channels <- get_team_channels(team_id = team_id, auth = auth)
  cn_raw <- trimws(as.character(channel_name)[1L])
  cn_clean <- sub("^#+", "", cn_raw)
  cid <- tryCatch(
    get_channel_id_lookup(channels, name = cn_clean),
    error = function(e) {
      tryCatch(
        get_channel_id_lookup(channels, display_name = cn_raw),
        error = function(e2) {
          if (is.data.frame(channels) && all(c("id", "name", "display_name") %in% names(channels))) {
            idx <- which(
              tolower(channels$name) == tolower(cn_clean) |
              tolower(sub("^#+", "", channels$display_name)) == tolower(cn_clean)
            )
            if (length(idx) >= 1L) return(as.character(channels$id[idx[1L]]))
          }
          NULL
        }
      )
    }
  )
  if (is.null(cid) || is.na(cid) || !nzchar(as.character(cid)[1L])) {
    stop(sprintf("Channel '%s' not found in team '%s'.", channel_name, team_id))
  }
  as.character(cid)[1L]
}

#' @keywords internal
#' @noRd
.mm_mcp_tool_definitions <- function() {
  list(
    list(
      name = "mm_list_channels",
      description = "List Mattermost channels for a team (defaults to primary team) with id, name, display_name, type, and header.",
      inputSchema = list(
        type = "object",
        properties = list(
          team_id = list(type = "string", description = "Optional Mattermost team ID. Defaults to the first team."),
          include_archived = list(type = "boolean", description = "Include archived channels. Default FALSE.")
        )
      )
    ),
    list(
      name = "mm_get_channel_posts",
      description = "Retrieve recent posts from a Mattermost channel by channel_id or channel_name (e.g. 'edgarx'), ordered newest-first with webhook/thread metadata.",
      inputSchema = list(
        type = "object",
        properties = list(
          channel_id = list(type = "string", description = "Channel ID (optional if channel_name is given)."),
          channel_name = list(type = "string", description = "Channel name or display name (e.g. 'edgarx')."),
          limit = list(type = "integer", description = "Number of posts to fetch (1-200). Default 60."),
          since = list(type = "string", description = "Optional ISO-8601 / YYYY-MM-DD timestamp to fetch posts modified since."),
          page = list(type = "integer", description = "0-based page index. Default 0.")
        )
      )
    ),
    list(
      name = "mm_get_post_thread",
      description = "Retrieve the full conversation thread (root post and all replies in chronological order) for a post_id.",
      inputSchema = list(
        type = "object",
        properties = list(
          post_id = list(type = "string", description = "Post ID of any message in the thread.")
        ),
        required = list("post_id")
      )
    ),
    list(
      name = "mm_search_posts",
      description = "Search posts across Mattermost channels using Mattermost search syntax (supports in:channel, from:user, terms).",
      inputSchema = list(
        type = "object",
        properties = list(
          terms = list(type = "string", description = "Search query terms."),
          team_id = list(type = "string", description = "Optional team ID (defaults to first team)."),
          is_or_search = list(type = "boolean", description = "Use OR matching instead of AND. Default FALSE.")
        ),
        required = list("terms")
      )
    ),
    list(
      name = "mm_send_message",
      description = "Send a Markdown message to a Mattermost channel (or reply to a thread via root_id).",
      inputSchema = list(
        type = "object",
        properties = list(
          channel_id = list(type = "string", description = "Target channel ID (optional if channel_name is given)."),
          channel_name = list(type = "string", description = "Target channel name or display name (e.g. 'edgarx')."),
          message = list(type = "string", description = "Markdown message content."),
          root_id = list(type = "string", description = "Optional post_id to reply to as a thread.")
        ),
        required = list("message")
      )
    ),
    list(
      name = "mm_update_post",
      description = "Patch an existing Mattermost post's message body or pin state.",
      inputSchema = list(
        type = "object",
        properties = list(
          post_id = list(type = "string", description = "Post ID to update."),
          message = list(type = "string", description = "Updated Markdown message text."),
          is_pinned = list(type = "boolean", description = "Optional pin state (TRUE/FALSE).")
        ),
        required = list("post_id")
      )
    ),
    list(
      name = "mm_delete_post",
      description = "Delete a specific Mattermost post by post_id.",
      inputSchema = list(
        type = "object",
        properties = list(
          post_id = list(type = "string", description = "Post ID to delete.")
        ),
        required = list("post_id")
      )
    ),
    list(
      name = "mm_purge_channel_noise",
      description = "Audit or delete old/noisy posts in a channel older than `days` matching an optional regex `pattern`. Defaults to dry_run = TRUE.",
      inputSchema = list(
        type = "object",
        properties = list(
          channel_id = list(type = "string", description = "Channel ID (optional if channel_name is given)."),
          channel_name = list(type = "string", description = "Channel name (e.g. 'edgarx')."),
          days = list(type = "number", description = "Delete messages older than this many days (0 = all matching messages). Default 7."),
          pattern = list(type = "string", description = "Optional regex pattern on message text to target specific spam."),
          dry_run = list(type = "boolean", description = "When TRUE (default), lists matching post IDs without deleting.")
        )
      )
    )
  )
}

#' @keywords internal
#' @noRd
.mm_mcp_dispatch_tool <- function(params, state) {
  .SD <- NULL
  tool_name <- params$name
  args <- params$arguments %||% list()

  tryCatch({
    auth <- suppressWarnings(suppressMessages(.mm_mcp_resolve_auth(state)))
    payload <- suppressWarnings(suppressMessages(switch(
      tool_name,
      mm_list_channels = {
        tid <- args$team_id
        if (is.null(tid) || !nzchar(as.character(tid)[1L])) {
          teams <- get_all_teams(auth = auth)
          if (!is.data.frame(teams) || nrow(teams) == 0L) {
            stop("No Mattermost teams found.")
          }
          tid <- as.character(teams$id[1L])
        }
        ch <- get_team_channels(team_id = tid, auth = auth)
        if (!isTRUE(args$include_archived) && is.data.frame(ch) && "delete_at" %in% names(ch)) {
          ch <- ch[is.na(ch$delete_at) | ch$delete_at == 0, , drop = FALSE]
        }
        keep_cols <- intersect(c("id", "name", "display_name", "type", "header", "purpose"), names(ch))
        if (length(keep_cols) > 0L) {
          ch <- as.data.frame(ch)[, keep_cols, drop = FALSE]
        }
        ch
      },
      mm_get_channel_posts = {
        cid <- .mm_mcp_resolve_channel_id(args$channel_id, args$channel_name, args$team_id, auth)
        lim <- as.integer(args$limit %||% 60L)
        if (is.na(lim) || lim < 1L) lim <- 60L
        if (lim > 200L) lim <- 200L
        pg <- as.integer(args$page %||% 0L)
        if (!is.null(args$since) && nzchar(as.character(args$since)[1L])) {
          get_channel_posts(channel_id = cid, since = args$since, include_metadata = TRUE, auth = auth)
        } else {
          get_channel_posts(channel_id = cid, page = pg, per_page = lim, include_metadata = TRUE, auth = auth)
        }
      },
      mm_get_post_thread = {
        get_post_thread(post_id = args$post_id, include_metadata = TRUE, auth = auth)
      },
      mm_search_posts = {
        tid <- args$team_id
        if (is.null(tid) || !nzchar(as.character(tid)[1L])) {
          teams <- get_all_teams(auth = auth)
          if (is.data.frame(teams) && nrow(teams) > 0L) tid <- as.character(teams$id[1L])
        }
        search_posts(
          terms = args$terms,
          team_id = tid,
          is_or_search = isTRUE(args$is_or_search),
          auth = auth
        )
      },
      mm_send_message = {
        cid <- .mm_mcp_resolve_channel_id(args$channel_id, args$channel_name, args$team_id, auth)
        send_mattermost_message(
          channel_id = cid,
          message = args$message,
          root_id = args$root_id,
          auth = auth
        )
      },
      mm_update_post = {
        update_post(
          post_id = args$post_id,
          message = args$message,
          is_pinned = args$is_pinned,
          auth = auth
        )
      },
      mm_delete_post = {
        delete_post(post_id = args$post_id, auth = auth)
      },
      mm_purge_channel_noise = {
        cid <- .mm_mcp_resolve_channel_id(args$channel_id, args$channel_name, args$team_id, auth)
        days <- as.numeric(args$days %||% 7)
        dry_run <- if (is.null(args$dry_run)) TRUE else isTRUE(args$dry_run)
        delete_old_messages(
          channel_id = cid,
          days = days,
          dry_run = dry_run,
          pattern = args$pattern,
          auth = auth
        )
      },
      stop(sprintf("Unknown tool: %s", tool_name))
    )))

    list(
      content = list(
        list(
          type = "text",
          text = as.character(jsonlite::toJSON(payload, auto_unbox = TRUE, pretty = TRUE, POSIXt = "ISO8601"))
        )
      ),
      isError = FALSE
    )
  }, error = function(e) {
    list(
      content = list(
        list(
          type = "text",
          text = paste("MattermostR MCP error:", conditionMessage(e))
        )
      ),
      isError = TRUE
    )
  })
}

#' @keywords internal
#' @noRd
.mm_mcp_handle_request <- function(req, state) {
  res <- list(
    jsonrpc = "2.0",
    id = req$id
  )

  if (identical(req$method, "initialize")) {
    res$result <- list(
      protocolVersion = "2024-11-05",
      serverInfo = list(
        name = "mattermost-ops",
        version = "0.2.0"
      ),
      capabilities = list(
        tools = list(listChanged = FALSE)
      )
    )
  } else if (identical(req$method, "tools/list")) {
    res$result <- list(tools = .mm_mcp_tool_definitions())
  } else if (identical(req$method, "tools/call")) {
    res$result <- .mm_mcp_dispatch_tool(req$params, state)
  } else {
    res$error <- list(
      code = -32601L,
      message = paste("Method not found:", req$method)
    )
  }

  res
}
