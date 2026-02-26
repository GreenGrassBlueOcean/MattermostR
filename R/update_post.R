#' Update (Patch) an Existing Mattermost Post
#'
#' Partially updates a post by providing only the fields to change. Omitted
#' fields are left unchanged. Uses the \code{PATCH} endpoint
#' (\code{PUT /api/v4/posts/\{post_id\}/patch}).
#'
#' @param post_id The ID of the post to update. Must be a non-empty string.
#' @param message Optional. The new message text (supports Markdown).
#' @param is_pinned Optional. Set to \code{TRUE} to pin the post to the
#'   channel, or \code{FALSE} to unpin it.
#' @param props Optional. A named list of properties to attach to the post.
#' @param verbose (Logical) If \code{TRUE}, detailed information about the
#'   request and response will be printed.
#' @param auth The authentication object created by
#'   \code{\link{authenticate_mattermost}()}. Must be a valid
#'   \code{mattermost_auth} object.
#'
#' @return A named list containing the updated post's fields (e.g. \code{id},
#'   \code{message}, \code{channel_id}, \code{is_pinned}).
#'
#' @details
#' At least one of \code{message}, \code{is_pinned}, or \code{props} must be
#' provided. The caller must have \code{edit_post} permission for the channel
#' the post is in.
#'
#' @seealso [pin_post()] and [unpin_post()] for dedicated pin/unpin endpoints.
#' @export
#' @examples
#' \dontrun{
#' auth <- authenticate_mattermost()
#'
#' # Edit a message
#' update_post(post_id = "abc123", message = "Updated text", auth = auth)
#'
#' # Pin a post
#' update_post(post_id = "abc123", is_pinned = TRUE, auth = auth)
#'
#' # Edit message and pin in one call
#' update_post(
#'   post_id = "abc123",
#'   message = "Important update",
#'   is_pinned = TRUE,
#'   auth = auth
#' )
#' }
update_post <- function(post_id, message = NULL, is_pinned = NULL,
                        props = NULL, verbose = FALSE,
                        auth = get_default_auth()) {

  check_not_null(post_id, "post_id")
  check_mattermost_auth(auth)

  # Build body from non-NULL fields only
  body <- list()
  if (!is.null(message))   body$message   <- message
  if (!is.null(is_pinned)) body$is_pinned <- is_pinned
  if (!is.null(props))     body$props     <- props

  if (length(body) == 0) {
    stop("At least one of 'message', 'is_pinned', or 'props' must be provided.")
  }

  endpoint <- paste0("/api/v4/posts/", post_id, "/patch")

  mattermost_api_request(
    auth = auth,
    endpoint = endpoint,
    method = "PUT",
    body = body,
    verbose = verbose
  )
}
