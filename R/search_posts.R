#' Search for posts in Mattermost
#'
#' This function searches for posts across Mattermost based on specified search terms and filters.
#' It allows you to search by keywords, filter by channels, users, dates, and more.
#'
#' @section Important - Bot Permissions:
#' Mattermost Search typically **only returns results from channels the bot has joined**.
#' Even if a channel is public, you must use `add_user_to_channel()` to add the bot
#' before its posts will appear in search results.
#'
#' @param terms A character string containing the search terms. This is the main search query.
#' @param team_id (Optional) The ID of the team to search within. **Recommended.**
#'        Global searches (NULL team_id) often return incomplete results depending on server configuration.
#' @param in_channels (Optional) A character vector of channel IDs to limit the search to specific channels.
#' @param from_users (Optional) A character vector of user IDs to limit the search to posts from specific users.
#' @param after_date (Optional) A POSIXct date object or character string (YYYY-MM-DD) to search for posts after this date.
#' @param before_date (Optional) A POSIXct date object or character string (YYYY-MM-DD) to search for posts before this date.
#' @param is_or_search (Logical) If `TRUE`, posts matching any of the search terms will be returned (OR search).
#'                      If `FALSE` (default), posts must match all search terms (AND search).
#' @param page (Integer) The page number for pagination (0-based, default is 0).
#' @param per_page (Integer) The number of posts per page. Defaults to **200** (max) to capture most results.
#' @param time_zone_offset (Integer) Time zone offset in hours from UTC (default is 0).
#' @param verbose (Logical) If `TRUE`, detailed information about the request and response will be printed.
#' @param auth The authentication object created by `authenticate_mattermost()`.
#'
#' @return A data frame containing the search results with columns:
#'   - `id`: Post ID
#'   - `create_at`: Creation timestamp (POSIXct)
#'   - `update_at`: Last update timestamp (POSIXct)
#'   - `edit_at`: Last edit timestamp (POSIXct)
#'   - `delete_at`: Deletion timestamp (POSIXct) if deleted
#'   - `is_pinned`: Whether the post is pinned
#'   - `user_id`: ID of the user who created the post
#'   - `channel_id`: ID of the channel containing the post
#'   - `message`: The post message content
#'   - `type`: Post type
#'
#'   To get channel information (e.g., display name), use `get_channel_info()` with the `channel_id`.
#'
#' @export
#' @examples
#' \dontrun{
#'   # 1. Authenticate
#'   auth <- authenticate_mattermost(
#'     base_url = "https://yourmattermost.server.com",
#'     token = "your-token"
#'   )
#'
#'   # 2. Basic Team Search (Recommended)
#'   # Search results are usually scoped to a team.
#'   teams <- get_all_teams(auth = auth)
#'   team_id <- teams$id[1] # Use the first team
#'
#'   results <- search_posts(
#'     terms = "project deadline",
#'     team_id = team_id,
#'     verbose = TRUE,
#'     auth = auth
#'   )
#'
#'   # 3. Search in a Specific Channel (Ensuring Bot Access)
#'   # Note: Bots must usually JOIN a channel to search inside it.
#'
#'   # a. Find the channel ID
#'   channels <- get_team_channels(team_id = team_id, auth = auth)
#'   channel_id <- get_channel_id_lookup(channels, name = "off-topic")
#'
#'   # b. Add the bot to the channel (safe to run even if already a member)
#'   me <- get_user_info("me", auth = auth)
#'   add_user_to_channel(channel_id, me$id, auth = auth)
#'
#'   # c. Perform the search
#'   results <- search_posts(
#'     terms = "lunch",
#'     team_id = team_id,
#'     in_channels = channel_id,
#'     auth = auth
#'   )
#'
#'   # 4. Search with Date Filters
#'   results <- search_posts(
#'     terms = "error",
#'     team_id = team_id,
#'     after_date = "2024-01-01",
#'     before_date = Sys.Date(),
#'     auth = auth
#'   )
#'
#'   # 5. Advanced: Combined Filter with Pagination
#'   # Search for "urgent" OR "critical" from specific users
#'   results <- search_posts(
#'     terms = "urgent critical",
#'     team_id = team_id,
#'     is_or_search = TRUE,
#'     per_page = 200,
#'     auth = auth
#'   )
#' }
search_posts <- function(terms,
                         team_id = NULL,
                         in_channels = NULL,
                         from_users = NULL,
                         after_date = NULL,
                         before_date = NULL,
                         is_or_search = FALSE,
                         page = 0,
                         per_page = 200,
                         time_zone_offset = 0,
                         verbose = FALSE,
                         auth = authenticate_mattermost()) {

  # Check required input for completeness
  check_not_null(terms, "terms")
  check_mattermost_auth(auth)

  # Validate per_page parameter
  if (!is.null(per_page) && (per_page < 1 || per_page > 200)) {
    stop("per_page must be between 1 and 200.")
  }

  # Validate page parameter
  if (!is.null(page) && page < 0) {
    stop("page must be 0 or greater.")
  }

  # Build the endpoint based on whether team_id is provided
  if (!is.null(team_id)) {
    endpoint <- paste0("/api/v4/teams/", team_id, "/posts/search")
  } else {
    endpoint <- "/api/v4/posts/search"
    if (verbose) message("Note: Searching globally (no team_id). This may return fewer results than expected depending on server settings.")
  }

  # Prepare the request body
  body <- list(
    terms = terms,
    is_or_search = is_or_search,
    time_zone_offset = time_zone_offset,
    page = page,
    per_page = per_page
  )

  # Add optional filters
  if (!is.null(in_channels)) {
    if (!is.character(in_channels)) stop("in_channels must be a character vector of channel IDs.")
    body$in_channels <- in_channels
  }

  if (!is.null(from_users)) {
    if (!is.character(from_users)) stop("from_users must be a character vector of user IDs.")
    body$from_users <- from_users
  }

  # Handle date filters
  if (!is.null(after_date)) {
    body$after_date <- convert_date_to_timestamp(after_date)
  }

  if (!is.null(before_date)) {
    body$before_date <- convert_date_to_timestamp(before_date)
  }

  # For debugging: print the body
  if (verbose) {
    cat("Search Request Body:\n", jsonlite::toJSON(body, auto_unbox = TRUE, pretty = TRUE), "\n")
  }

  # Send the POST request
  response <- mattermost_api_request(
    auth = auth,
    endpoint = endpoint,
    method = "POST",
    body = body,
    verbose = verbose
  )

  # Convert response to data frame
  if (!is.null(response)) {
    result_df <- convert_search_posts_to_dataframe(response)
  } else {
    result_df <- data.frame(
      id = character(),
      create_at = as.POSIXct(character()),
      update_at = as.POSIXct(character()),
      edit_at = as.POSIXct(character()),
      delete_at = as.POSIXct(character()),
      is_pinned = logical(),
      user_id = character(),
      channel_id = character(),
      message = character(),
      type = character(),
      stringsAsFactors = FALSE
    )
  }

  # --- Diagnostics & Warnings (ASCII only) ---
  num_results <- nrow(result_df)

  # Case 1: No results found - Provide Hints
  if (num_results == 0 && verbose) {
    message("No results found.")
    message("Diagnostic Hints:")
    if (is.null(team_id)) {
      message("  - Try providing a 'team_id'. Global search is often restricted on Mattermost servers.")
    }
    if (!is.null(in_channels)) {
      message("  - Ensure the bot user has JOINED the target channel(s). Search typically does not index channels the user is not in.")
    } else {
      message("  - Ensure the bot user has JOINED the relevant channels.")
    }
  }

  # Case 2: Pagination Limit Hit
  if (num_results == per_page) {
    warning(sprintf(
      "Returned %d results, which matches the 'per_page' limit. There may be more results. Try increasing 'per_page' or requesting the next 'page'.",
      num_results
    ))
  }

  if (verbose && num_results > 0) {
    message(sprintf("Found %d posts.", num_results))
  }

  return(result_df)
}

#' Convert Search Posts Response to Data Frame
#'
#' @param search_response A nested list containing search results.
#' @return A data frame with post details.
#' @noRd
convert_search_posts_to_dataframe <- function(search_response) {

  if (is.null(search_response$posts) || length(search_response$posts) == 0) {
    return(data.frame(
      id = character(),
      create_at = as.POSIXct(character()),
      update_at = as.POSIXct(character()),
      edit_at = as.POSIXct(character()),
      delete_at = as.POSIXct(character()),
      is_pinned = logical(),
      user_id = character(),
      channel_id = character(),
      message = character(),
      type = character(),
      stringsAsFactors = FALSE
    ))
  }

  posts <- search_response$posts
  rows_list <- list()

  for (post in posts) {
    rows_list[[length(rows_list) + 1]] <- data.frame(
      id = if (!is.null(post$id)) post$id else NA_character_,

      # Use as.numeric() to avoid integer overflow on millisecond timestamps
      create_at = if (!is.null(post$create_at) && post$create_at != 0) {
        as.POSIXct(as.numeric(post$create_at) / 1000, origin = "1970-01-01", tz = "UTC")
      } else { as.POSIXct(NA) },

      update_at = if (!is.null(post$update_at) && post$update_at != 0) {
        as.POSIXct(as.numeric(post$update_at) / 1000, origin = "1970-01-01", tz = "UTC")
      } else { as.POSIXct(NA) },

      edit_at = if (!is.null(post$edit_at) && post$edit_at != 0) {
        as.POSIXct(as.numeric(post$edit_at) / 1000, origin = "1970-01-01", tz = "UTC")
      } else { as.POSIXct(NA) },

      delete_at = if (!is.null(post$delete_at) && post$delete_at != 0) {
        as.POSIXct(as.numeric(post$delete_at) / 1000, origin = "1970-01-01", tz = "UTC")
      } else { as.POSIXct(NA) },

      is_pinned = if (!is.null(post$is_pinned)) post$is_pinned else FALSE,
      user_id = if (!is.null(post$user_id)) post$user_id else NA_character_,
      channel_id = if (!is.null(post$channel_id)) post$channel_id else NA_character_,
      message = if (!is.null(post$message)) post$message else NA_character_,
      type = if (!is.null(post$type)) post$type else NA_character_,
      stringsAsFactors = FALSE
    )
  }

  posts_df <- do.call(rbind, rows_list)

  return(posts_df)
}

#' Convert Date to Unix Timestamp in Milliseconds
#'
#' @param date_input A POSIXct, Date, or character string.
#' @return Numeric timestamp (milliseconds).
#' @noRd
convert_date_to_timestamp <- function(date_input) {
  # Handle character string dates
  if (is.character(date_input)) {
    date_input <- tryCatch(
      {
        as.POSIXct(date_input, tz = "UTC")
      },
      error = function(e) {
        stop("Invalid date format. Please use YYYY-MM-DD or POSIXct format.")
      }
    )
  }

  # Handle Date objects
  if (inherits(date_input, "Date")) {
    date_input <- as.POSIXct(date_input, tz = "UTC")
  }

  # Handle POSIXct objects
  if (inherits(date_input, "POSIXct")) {
    # Use numeric instead of integer to avoid overflow for millisecond timestamps
    timestamp_ms <- as.numeric(date_input) * 1000
    return(timestamp_ms)
  }

  stop("Date input must be a POSIXct, Date, or character string (YYYY-MM-DD).")
}
