# File: R/get_channel_posts.R

#' Get posts from a Mattermost channel
#'
#' @param channel_id The Mattermost channel ID.
#' @param verbose Boolean. If `TRUE`, the function will print request/response details for more information.
#' @param auth The authentication object created by `authenticate_mattermost()`.
#'
#' @return Parsed JSON response with posts from the channel.
#' @export
#' @examples
#' \dontrun{
#'   teams <- get_all_teams()
#'   team_channels <- get_team_channels(team_id = teams$id[1])
#'   channel_id <- get_channel_id_lookup(team_channels, name = "off-topic")
#'   posts <- get_channel_posts(channel_id)
#' }
get_channel_posts <- function(channel_id, verbose = FALSE, auth = authenticate_mattermost()) {

  # Check required input for completeness
  check_not_null(channel_id, "channel_id")
  check_mattermost_auth(auth)

  endpoint <- paste0("/api/v4/channels/", channel_id, "/posts")

  # Send the request using mattermost_api_request
  response <- mattermost_api_request(
    auth = auth,
    endpoint = endpoint,
    method = "GET",
    verbose = verbose
  )

  response <- convert_mattermost_posts_to_dataframe(response)

  return(response)
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

