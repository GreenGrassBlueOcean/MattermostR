#' Pin a post to its channel
#'
#' Pin a post to the top of the channel it belongs to. This is the semantic
#' endpoint for pinning; the same effect can be achieved via
#' `update_post(post_id, is_pinned = TRUE)`.
#'
#' @param post_id Character. The ID of the post to pin.
#' @param verbose Logical. Print detailed request information? Default `FALSE`.
#' @param auth A `mattermost_auth` object created by
#'   [authenticate_mattermost()]. Defaults to [get_default_auth()].
#'
#' @return A named list with `status = "OK"` on success.
#'
#' @section Permissions:
#' Must be authenticated and have `read_channel` permission for the channel
#' the post is in.
#'
#' @seealso [unpin_post()], [update_post()]
#' @export
#' @examples
#' \dontrun{
#'   pin_post("post_id_abc")
#' }
pin_post <- function(post_id,
                     verbose = FALSE,
                     auth = get_default_auth()) {

  check_not_null(post_id, "post_id")
  check_mattermost_auth(auth)

  endpoint <- paste0("/api/v4/posts/", post_id, "/pin")

  mattermost_api_request(
    auth     = auth,
    endpoint = endpoint,
    method   = "POST",
    verbose  = verbose
  )
}


#' Unpin a post from its channel
#'
#' Remove a post's pinned status from the channel. This is the semantic
#' endpoint for unpinning; the same effect can be achieved via
#' `update_post(post_id, is_pinned = FALSE)`.
#'
#' @param post_id Character. The ID of the post to unpin.
#' @param verbose Logical. Print detailed request information? Default `FALSE`.
#' @param auth A `mattermost_auth` object created by
#'   [authenticate_mattermost()]. Defaults to [get_default_auth()].
#'
#' @return A named list with `status = "OK"` on success.
#'
#' @section Permissions:
#' Must be authenticated and have `read_channel` permission for the channel
#' the post is in.
#'
#' @seealso [pin_post()], [update_post()]
#' @export
#' @examples
#' \dontrun{
#'   unpin_post("post_id_abc")
#' }
unpin_post <- function(post_id,
                       verbose = FALSE,
                       auth = get_default_auth()) {

  check_not_null(post_id, "post_id")
  check_mattermost_auth(auth)

  endpoint <- paste0("/api/v4/posts/", post_id, "/unpin")

  mattermost_api_request(
    auth     = auth,
    endpoint = endpoint,
    method   = "POST",
    verbose  = verbose
  )
}
