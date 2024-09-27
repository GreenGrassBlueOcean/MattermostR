# File: R/delete_post.R

#' Delete a specific post in Mattermost
#'
#' @param post_id The ID of the post to delete.
#' @param verbose Boolean. If `TRUE`, the function will print request/response details for more information.
#' @param auth The authentication object created by `authenticate_mattermost()`.
#'
#' @return Parsed JSON response confirming deletion.
#' @export
#' @examples
#'
#' \dontrun{
#'  delete_post(post_id = "fake_id")
#' }
delete_post <- function(post_id = NULL, verbose = FALSE,auth = authenticate_mattermost()) {

  # Check required input for completeness
  check_not_null(post_id, "post_id")
  check_mattermost_auth(auth)

  endpoint <- paste0("/api/v4/posts/", post_id)

  # Send the request using mattermost_api_request
  response <- mattermost_api_request(
    auth = auth,
    endpoint = endpoint,
    method = "DELETE",
    verbose = verbose
   )

  return(response)
}
