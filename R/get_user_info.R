#' Get information about a specific Mattermost user
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' `get_user_info()` was renamed to [get_user()] in MattermostR 0.2.0 to
#' provide a more consistent API. It will be removed in a future release.
#'
#' @inheritParams get_user
#'
#' @return A named list with user fields returned by the Mattermost API
#'   (e.g. `id`, `username`, `email`, `roles`).
#' @export
#' @examples
#' \dontrun{
#'   # Prefer get_user() instead:
#'   user <- get_user("xb123abc456...")
#' }
get_user_info <- function(user_id = NULL, auth = get_default_auth()) {
  lifecycle::deprecate_warn("0.2.0", "get_user_info()", "get_user()")
  get_user(user_id = user_id, auth = auth)
}
