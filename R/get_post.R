#' Retrieve a Single Mattermost Post by ID
#'
#' Fetches the full post object for a specific Mattermost `post_id` via
#' `GET /api/v4/posts/{post_id}`.
#'
#' @param post_id Character string. The ID of the post to retrieve.
#' @param verbose Logical. If `TRUE`, prints request and response details.
#'   Default `FALSE`.
#' @param auth The authentication object created by [authenticate_mattermost()].
#'
#' @return A named list representing the Mattermost post object (including `id`,
#'   `create_at`, `user_id`, `channel_id`, `root_id`, `message`, `props`, etc.).
#' @export
#' @examples
#' \dontrun{
#' auth <- authenticate_mattermost()
#' post <- get_post("post_id_123", auth = auth)
#' }
get_post <- function(post_id = NULL, verbose = FALSE, auth = get_default_auth()) {
  check_not_null(post_id, "post_id")
  check_mattermost_auth(auth)

  endpoint <- paste0("/api/v4/posts/", post_id)
  mattermost_api_request(
    auth = auth,
    endpoint = endpoint,
    method = "GET",
    verbose = verbose
  )
}

#' Retrieve a Mattermost Post Thread by Post ID
#'
#' Fetches the root post and all replies in the thread containing `post_id`
#' via `GET /api/v4/posts/{post_id}/thread`, returning a chronologically
#' ordered data frame.
#'
#' @param post_id Character string. The ID of any post in the thread (typically
#'   the root post).
#' @param per_page Optional integer. Maximum number of posts to return per page.
#' @param from_post Optional character string. Post ID to start pagination from.
#' @param include_metadata Logical. If `TRUE` (default), includes `root_id`,
#'   `override_username`, and `from_webhook` columns.
#' @param verbose Logical. If `TRUE`, prints request and response details.
#'   Default `FALSE`.
#' @param auth The authentication object created by [authenticate_mattermost()].
#'
#' @return A data frame of posts in the thread ordered chronologically by
#'   `create_at` ascending.
#' @export
#' @examples
#' \dontrun{
#' auth <- authenticate_mattermost()
#' thread_df <- get_post_thread("root_post_id_123", auth = auth)
#' }
get_post_thread <- function(post_id = NULL, per_page = NULL, from_post = NULL,
                            include_metadata = TRUE, verbose = FALSE,
                            auth = get_default_auth()) {
  check_not_null(post_id, "post_id")
  check_mattermost_auth(auth)

  query_params <- list()
  if (!is.null(per_page)) {
    query_params[["perPage"]] <- as.integer(per_page)
  }
  if (!is.null(from_post) && nzchar(as.character(from_post))) {
    query_params[["fromPost"]] <- as.character(from_post)
  }

  endpoint <- paste0("/api/v4/posts/", post_id, "/thread")
  if (length(query_params) > 0L) {
    qs <- paste0(names(query_params), "=", query_params, collapse = "&")
    endpoint <- paste0(endpoint, "?", qs)
  }

  response <- mattermost_api_request(
    auth = auth,
    endpoint = endpoint,
    method = "GET",
    verbose = verbose
  )

  df <- convert_mattermost_posts_to_dataframe(
    response,
    include_extended = isTRUE(include_metadata)
  )
  if (nrow(df) > 1L && "create_at" %in% names(df)) {
    df <- df[order(as.numeric(df$create_at)), , drop = FALSE]
    rownames(df) <- NULL
  }
  df
}
