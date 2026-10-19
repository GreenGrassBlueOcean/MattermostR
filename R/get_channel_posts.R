
#' Get posts from a Mattermost channel
#'
#' Retrieves posts from a Mattermost channel with support for pagination.
#' The Mattermost API returns at most `per_page` posts per request (default 60).
#' Use the `page` and `per_page` parameters to paginate through results, or use
#' `since` to retrieve all posts modified after a given timestamp (up to 1000).
#'
#' @param channel_id The Mattermost channel ID.
#' @param page (Integer) The page to select (0-based). Default is 0.
#' @param per_page (Integer) The number of posts per page. Default is 60, maximum is 200.
#' @param since (Optional) A POSIXct, Date, or numeric (Unix time in milliseconds) value.
#'   When provided, returns all posts created or modified after this time, up to a
#'   server-side limit of 1000 posts. **Cannot** be combined with `page` or `per_page`.
#' @param include_metadata Boolean. If `TRUE`, appends `root_id`, `override_username`,
#'   and `from_webhook` columns extracted from post metadata. Default is `FALSE`.
#' @param verbose Boolean. If `TRUE`, the function will print request/response details for more information.
#' @param auth The authentication object created by `authenticate_mattermost()`.
#'
#' @return A data frame of posts from the channel with columns `id`, `create_at`,
#'   `update_at`, `edit_at`, `delete_at`, `is_pinned`, `user_id`, `channel_id`,
#'   `message`, and `type` (plus `root_id`, `override_username`, and `from_webhook`
#'   when `include_metadata = TRUE`). Returns an empty data frame if no posts are found.
#'
#'   A warning is issued when the number of returned posts equals `per_page`,
#'   indicating that additional pages may be available.
#' @export
#' @examples
#' \dontrun{
#'   teams <- get_all_teams()
#'   team_channels <- get_team_channels(team_id = teams$id[1])
#'   channel_id <- get_channel_id_lookup(team_channels, "off-topic")
#'
#'   # Get the first page (default 60 posts)
#'   posts <- get_channel_posts(channel_id)
#'
#'   # Get 200 posts per page, page 0
#'   posts <- get_channel_posts(channel_id, per_page = 200)
#'
#'   # Get page 2
#'   posts <- get_channel_posts(channel_id, page = 2, per_page = 200)
#'
#'   # Get all posts modified since a date (up to 1000)
#'   posts <- get_channel_posts(channel_id, since = as.POSIXct("2024-01-01", tz = "UTC"))
#' }
get_channel_posts <- function(channel_id, page = 0, per_page = 60, since = NULL,
                              include_metadata = FALSE, verbose = FALSE,
                              auth = get_default_auth()) {

  # Check required input for completeness
  check_not_null(channel_id, "channel_id")
  check_mattermost_auth(auth)

  # Validate per_page
  if (!is.null(per_page) && (per_page < 1 || per_page > 200)) {
    stop("per_page must be between 1 and 200.")
  }

  # Validate page
  if (!is.null(page) && page < 0) {
    stop("page must be 0 or greater.")
  }

  # 'since' cannot be combined with page/per_page
  if (!is.null(since) && (page != 0 || per_page != 60)) {
    stop("'since' cannot be combined with non-default 'page' or 'per_page'. Use one approach or the other.")
  }

  # Build query parameters
  query_params <- list()

  if (!is.null(since)) {
    # Convert since to millisecond timestamp
    since_ms <- convert_since_to_ms(since)
    query_params[["since"]] <- since_ms
  } else {
    query_params[["page"]] <- page
    query_params[["per_page"]] <- per_page
  }

  # Build the endpoint with query string
  query_string <- paste0(
    names(query_params), "=", query_params,
    collapse = "&"
  )
  endpoint <- paste0("/api/v4/channels/", channel_id, "/posts?", query_string)

  # Send the request using mattermost_api_request
  response <- mattermost_api_request(
    auth = auth,
    endpoint = endpoint,
    method = "GET",
    verbose = verbose
  )

  result_df <- convert_mattermost_posts_to_dataframe(
    response,
    include_extended = isTRUE(include_metadata)
  )

  # Warn when pagination limit is hit (only for page/per_page mode)
  if (is.null(since) && nrow(result_df) == per_page) {
    warning(sprintf(
      "Returned %d posts, which matches the 'per_page' limit. There may be more posts. Use 'page' to retrieve additional pages.",
      nrow(result_df)
    ))
  }

  return(result_df)
}

#' Get Channel Posts with Extended Webhook and Thread Metadata
#'
#' Convenience wrapper around \code{\link{get_channel_posts}} that defaults
#' \code{include_metadata = TRUE} (extracting \code{root_id},
#' \code{override_username}, and \code{from_webhook}) and preserves
#' Mattermost's reverse-chronological post ordering.
#'
#' @inheritParams get_channel_posts
#' @return A data frame of posts ordered newest-first, including extended
#'   metadata columns (\code{root_id}, \code{override_username},
#'   \code{from_webhook}) when \code{include_metadata = TRUE}.
#' @export
#' @examples
#' \dontrun{
#'   posts <- mm_get_channel_posts("channel_id_here", per_page = 60)
#' }
mm_get_channel_posts <- function(channel_id, page = 0, per_page = 60, since = NULL,
                                 include_metadata = TRUE, verbose = FALSE,
                                 auth = get_default_auth()) {
  get_channel_posts(
    channel_id       = channel_id,
    page             = page,
    per_page         = per_page,
    since            = since,
    include_metadata = include_metadata,
    verbose          = verbose,
    auth             = auth
  )
}

#' Convert a since value to Unix timestamp in milliseconds
#'
#' Accepts POSIXct, Date, character (YYYY-MM-DD), or numeric (already in ms).
#' @param since The since value to convert.
#' @return Numeric Unix timestamp in milliseconds.
#' @noRd
convert_since_to_ms <- function(since) {
  if (is.numeric(since)) {
    return(since)
  }
  if (is.character(since)) {
    since <- tryCatch(
      as.POSIXct(since, tz = "UTC"),
      error = function(e) stop("Invalid 'since' date format. Use YYYY-MM-DD, POSIXct, or numeric milliseconds.")
    )
  }
  if (inherits(since, "Date")) {
    since <- as.POSIXct(since, tz = "UTC")
  }
  if (inherits(since, "POSIXct")) {
    return(as.numeric(since) * 1000)
  }
  stop("'since' must be a POSIXct, Date, character (YYYY-MM-DD), or numeric (Unix ms).")
}

#' Convert Mattermost Posts Nested List to Data Frame
#'
#' This function transforms a nested list of posts retrieved from Mattermost
#' into a data frame. Each post's attributes are converted into corresponding
#' columns in the data frame, including timestamp fields which are formatted
#' as POSIXct. When `nested_list$order` is present, rows are ordered according
#' to `nested_list$order`.
#'
#' @param nested_list A nested list containing posts from Mattermost,
#'                    structured as returned by the Mattermost API.
#' @param include_extended Logical. When `TRUE`, includes `root_id`,
#'   `override_username`, and `from_webhook` columns.
#'
#' @return A data frame with each post represented as a row, and attributes
#'         of the posts as columns.
#' @noRd
convert_mattermost_posts_to_dataframe <- function(nested_list, include_extended = FALSE) {
  # Extract the posts list
  posts <- nested_list$posts
  if (is.null(posts) || length(posts) == 0L) {
    return(data.frame())
  }

  # Respect Mattermost's `order` array when present (newest-first IDs)
  ord <- nested_list$order
  if (!is.null(ord) && length(ord) > 0L) {
    ord_ids <- as.character(unlist(ord, use.names = FALSE))
    by_id <- list()
    for (p in posts) {
      if (!is.null(p$id)) by_id[[as.character(p$id)]] <- p
    }
    ordered_posts <- list()
    seen <- character(0)
    for (pid in ord_ids) {
      if (!is.null(by_id[[pid]])) {
        ordered_posts[[length(ordered_posts) + 1L]] <- by_id[[pid]]
        seen <- c(seen, pid)
      }
    }
    for (p in posts) {
      pid <- as.character(p$id)
      if (!pid %in% seen) {
        ordered_posts[[length(ordered_posts) + 1L]] <- p
      }
    }
    posts <- ordered_posts
  }

  # Initialize an empty list to store the rows
  rows_list <- list()

  # Loop through each post and extract relevant fields
  for (post in posts) {
    msg_text <- if (!is.null(post$message)) as.character(post$message) else ""
    if (!nzchar(trimws(msg_text)) && !is.null(post$props) &&
        !is.null(post$props$attachments) && length(post$props$attachments) > 0L) {
      att_parts <- vapply(post$props$attachments, function(att) {
        if (!is.list(att)) return("")
        pieces <- character(0)
        if (!is.null(att$title) && nzchar(as.character(att$title))) {
          pieces <- c(pieces, as.character(att$title))
        }
        if (!is.null(att$text) && nzchar(as.character(att$text))) {
          pieces <- c(pieces, as.character(att$text))
        }
        if (length(pieces) == 0L && !is.null(att$fallback) && nzchar(as.character(att$fallback))) {
          pieces <- c(pieces, as.character(att$fallback))
        }
        paste(pieces, collapse = "\n")
      }, character(1L))
      att_parts <- att_parts[nzchar(att_parts)]
      if (length(att_parts) > 0L) {
        msg_text <- paste(att_parts, collapse = "\n")
      }
    }

    row_df <- data.frame(
      id = post$id,
      create_at = if (post$create_at != 0) { as.POSIXct(post$create_at / 1000, origin = "1970-01-01", tz = "UTC") } else { NA },
      update_at = if (post$update_at != 0) { as.POSIXct(post$update_at / 1000, origin = "1970-01-01", tz = "UTC") } else { NA },
      edit_at = if (post$edit_at != 0) { as.POSIXct(post$edit_at / 1000, origin = "1970-01-01", tz = "UTC") } else { NA },
      delete_at = if (post$delete_at != 0) { as.POSIXct(post$delete_at / 1000, origin = "1970-01-01", tz = "UTC") } else { NA },
      is_pinned = post$is_pinned,
      user_id = post$user_id,
      channel_id = post$channel_id,
      message = msg_text,
      type = post$type,
      stringsAsFactors = FALSE
    )
    if (isTRUE(include_extended)) {
      row_df$root_id <- if (!is.null(post$root_id)) as.character(post$root_id) else ""
      row_df$override_username <- if (!is.null(post$props) && !is.null(post$props$override_username)) {
        as.character(post$props$override_username)
      } else {
        ""
      }
      row_df$from_webhook <- isTRUE(post$props$from_webhook) ||
        identical(as.character(post$props$from_webhook), "true")
    }
    rows_list[[length(rows_list) + 1L]] <- row_df
  }

  # Combine all rows into a single data.frame
  if (length(rows_list) > 0L) {
    posts_df <- do.call(rbind, rows_list)
    rownames(posts_df) <- NULL
  } else {
    posts_df <- data.frame()
  }

  return(posts_df)
}
