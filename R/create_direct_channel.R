#' Create a Direct Message or Group Message Channel
#'
#' Creates a direct message channel (2 users) or a group message channel
#' (3--8 users). If the channel already exists, the existing channel is
#' returned (the operation is idempotent).
#'
#' After creating the channel, use
#' \code{\link{send_mattermost_message}(channel_id = result$id, ...)} to
#' send messages to it.
#'
#' @param user_ids A character vector of Mattermost user IDs.
#'   \itemize{
#'     \item Exactly 2 IDs creates a \strong{direct message} channel
#'       (\code{POST /api/v4/channels/direct}).
#'     \item 3--8 IDs creates a \strong{group message} channel
#'       (\code{POST /api/v4/channels/group}).
#'   }
#' @param verbose (Logical) If \code{TRUE}, detailed information about the
#'   request and response will be printed.
#' @param auth The authentication object created by
#'   \code{\link{authenticate_mattermost}()}. Must be a valid
#'   \code{mattermost_auth} object.
#'
#' @return A named list with the channel's fields (e.g. \code{id}, \code{name},
#'   \code{type}). Direct message channels have \code{type = "D"}; group
#'   message channels have \code{type = "G"}.
#'
#' @export
#' @examples
#' \dontrun{
#' auth <- authenticate_mattermost()
#'
#' # Create a direct message channel between two users
#' dm <- create_direct_channel(
#'   user_ids = c("user_id_1", "user_id_2"),
#'   auth = auth
#' )
#' send_mattermost_message(channel_id = dm$id, message = "Hello!", auth = auth)
#'
#' # Create a group message channel with three users
#' gm <- create_direct_channel(
#'   user_ids = c("user_id_1", "user_id_2", "user_id_3"),
#'   auth = auth
#' )
#' send_mattermost_message(channel_id = gm$id, message = "Hi team!", auth = auth)
#' }
create_direct_channel <- function(user_ids, verbose = FALSE,
                                  auth = get_default_auth()) {

  # Validate user_ids

  if (!is.character(user_ids) || length(user_ids) < 2) {
    stop("'user_ids' must be a character vector with at least 2 user IDs.")
  }
  if (length(user_ids) > 8) {
    stop("'user_ids' must contain at most 8 user IDs (Mattermost group message limit).")
  }
  check_mattermost_auth(auth)

  # 2 IDs → direct message; 3–8 IDs → group message
  endpoint <- if (length(user_ids) == 2) {
    "/api/v4/channels/direct"
  } else {
    "/api/v4/channels/group"
  }

  mattermost_api_request(
    auth = auth,
    endpoint = endpoint,
    method = "POST",
    body = user_ids,
    verbose = verbose
  )
}
