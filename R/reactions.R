#' Add a Reaction to a Mattermost Post
#'
#' Creates a reaction (emoji) on a post.
#'
#' @param user_id The ID of the user adding the reaction.
#' @param post_id The ID of the post to react to.
#' @param emoji_name The name of the emoji to react with (e.g.
#'   \code{"thumbsup"}). Colons are stripped automatically, so
#'   \code{":thumbsup:"} also works.
#' @param verbose (Logical) If \code{TRUE}, detailed information about the
#'   request and response will be printed.
#' @param auth The authentication object created by
#'   \code{\link{authenticate_mattermost}()}. Must be a valid
#'   \code{mattermost_auth} object.
#'
#' @return A named list with the reaction's fields: \code{user_id},
#'   \code{post_id}, \code{emoji_name}, and \code{create_at}.
#'
#' @details
#' The caller must have \code{read_channel} permission for the channel the
#' post is in.
#'
#' @export
#' @examples
#' \dontrun{
#' auth <- authenticate_mattermost()
#' me <- get_me(auth = auth)
#'
#' # React with thumbsup
#' add_reaction(
#'   user_id = me$id,
#'   post_id = "post_abc123",
#'   emoji_name = "thumbsup",
#'   auth = auth
#' )
#'
#' # Colons are stripped automatically
#' add_reaction(
#'   user_id = me$id,
#'   post_id = "post_abc123",
#'   emoji_name = ":white_check_mark:",
#'   auth = auth
#' )
#' }
add_reaction <- function(user_id, post_id, emoji_name, verbose = FALSE,
                         auth = get_default_auth()) {

  check_not_null(user_id, "user_id")
  check_not_null(post_id, "post_id")
  check_not_null(emoji_name, "emoji_name")
  check_mattermost_auth(auth)

  # Strip colons if present (e.g. ":thumbsup:" -> "thumbsup")
  emoji_name <- gsub("^:|:$", "", emoji_name)

  mattermost_api_request(
    auth = auth,
    endpoint = "/api/v4/reactions",
    method = "POST",
    body = list(user_id = user_id, post_id = post_id, emoji_name = emoji_name),
    verbose = verbose
  )
}


#' Get All Reactions on a Mattermost Post
#'
#' Retrieves all reactions made by all users on a given post.
#'
#' @param post_id The ID of the post to get reactions for.
#' @param verbose (Logical) If \code{TRUE}, detailed information about the
#'   request and response will be printed.
#' @param auth The authentication object created by
#'   \code{\link{authenticate_mattermost}()}. Must be a valid
#'   \code{mattermost_auth} object.
#'
#' @return A data frame of reactions with columns \code{user_id},
#'   \code{post_id}, \code{emoji_name}, and \code{create_at}. Returns an
#'   empty result if there are no reactions.
#'
#' @details
#' The caller must have \code{read_channel} permission for the channel the
#' post is in.
#'
#' @export
#' @examples
#' \dontrun{
#' reactions <- get_reactions(post_id = "post_abc123")
#' reactions
#' }
get_reactions <- function(post_id, verbose = FALSE,
                          auth = get_default_auth()) {

  check_not_null(post_id, "post_id")
  check_mattermost_auth(auth)

  mattermost_api_request(
    auth = auth,
    endpoint = paste0("/api/v4/posts/", post_id, "/reactions"),
    method = "GET",
    verbose = verbose
  )
}


#' Remove a Reaction from a Mattermost Post
#'
#' Deletes a specific reaction (emoji) that a user previously added to a post.
#'
#' @param user_id The ID of the user whose reaction to remove.
#' @param post_id The ID of the post to remove the reaction from.
#' @param emoji_name The name of the emoji to remove (e.g.
#'   \code{"thumbsup"}). Colons are stripped automatically.
#' @param verbose (Logical) If \code{TRUE}, detailed information about the
#'   request and response will be printed.
#' @param auth The authentication object created by
#'   \code{\link{authenticate_mattermost}()}. Must be a valid
#'   \code{mattermost_auth} object.
#'
#' @return A named list with the deletion status as returned by the
#'   Mattermost API (typically \code{list(status = "OK")}).
#'
#' @details
#' The caller must be the user who made the reaction or have
#' \code{manage_system} permission.
#'
#' @export
#' @examples
#' \dontrun{
#' auth <- authenticate_mattermost()
#' me <- get_me(auth = auth)
#'
#' # Remove a thumbsup reaction
#' remove_reaction(
#'   user_id = me$id,
#'   post_id = "post_abc123",
#'   emoji_name = "thumbsup",
#'   auth = auth
#' )
#' }
remove_reaction <- function(user_id, post_id, emoji_name, verbose = FALSE,
                            auth = get_default_auth()) {

  check_not_null(user_id, "user_id")
  check_not_null(post_id, "post_id")
  check_not_null(emoji_name, "emoji_name")
  check_mattermost_auth(auth)

  # Strip colons if present
  emoji_name <- gsub("^:|:$", "", emoji_name)

  endpoint <- paste0("/api/v4/users/", user_id,
                     "/posts/", post_id,
                     "/reactions/", emoji_name)

  mattermost_api_request(
    auth = auth,
    endpoint = endpoint,
    method = "DELETE",
    verbose = verbose
  )
}
