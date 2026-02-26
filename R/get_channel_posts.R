
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
#' @param verbose Boolean. If `TRUE`, the function will print request/response details for more information.
#' @param auth The authentication object created by `authenticate_mattermost()`.
#'
#' @return A data frame of posts from the channel with columns `id`, `create_at`,
#'   `update_at`, `edit_at`, `delete_at`, `is_pinned`, `user_id`, `channel_id`,
#'   `message`, and `type`. Returns an empty data frame if no posts are found.
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
                              verbose = FALSE, auth = get_default_auth()) {

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

  result_df <- convert_mattermost_posts_to_dataframe(response)

  # Warn when pagination limit is hit (only for page/per_page mode)
  if (is.null(since) && nrow(result_df) == per_page) {
    warning(sprintf(
      "Returned %d posts, which matches the 'per_page' limit. There may be more posts. Use 'page' to retrieve additional pages.",
      nrow(result_df)
    ))
  }

  return(result_df)
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
#' as POSIXct.
#'
#' @param nested_list A nested list containing posts from Mattermost,
#'                    structured as returned by the Mattermost API.
#'
#' @return A data frame with each post represented as a row, and attributes
#'         of the posts as columns.
#' @noRd
convert_mattermost_posts_to_dataframe <- function(nested_list) {
  # Extract the posts list
  posts <- nested_list$posts

  # Initialize an empty list to store the rows
  rows_list <- list()

  # Loop through each post and extract relevant fields
  for (post in posts) {
    rows_list[[length(rows_list) + 1]] <- data.frame(
      id = post$id,
      create_at = if(post$create_at != 0) { as.POSIXct(post$create_at / 1000, origin = "1970-01-01", tz = "UTC") } else { NA },
      update_at = if(post$update_at != 0) { as.POSIXct(post$update_at / 1000, origin = "1970-01-01", tz = "UTC") } else { NA },
      edit_at = if(post$edit_at != 0) { as.POSIXct(post$edit_at / 1000, origin = "1970-01-01", tz = "UTC") } else { NA },
      delete_at = if(post$delete_at != 0) { as.POSIXct(post$delete_at / 1000, origin = "1970-01-01", tz = "UTC") } else { NA },
      is_pinned = post$is_pinned,
      user_id = post$user_id,
      channel_id = post$channel_id,
      message = post$message,
      type = post$type,
      stringsAsFactors = FALSE
    )
  }

  # Combine all rows into a single data.frame
  if(length(rows_list) > 0 ){
    posts_df <- do.call(rbind, rows_list)
  } else {
    posts_df <- data.frame()
  }

  return(posts_df)
}
