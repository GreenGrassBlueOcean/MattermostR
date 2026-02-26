
#' Send a file to a Mattermost channel
#'
#' This function sends a file to a specified Mattermost channel along with an optional comment.
#' **Note**: Simply sending a file will not make it appear in the channel.
#' To ensure the file appears, it must be combined with a message using `send_mattermost_message()`.
#'
#' @param channel_id The ID of the channel to which the file should be sent.
#' @param file_path The path to the file to be sent.
#' @param comment A comment to accompany the file.
#' @param verbose (Logical) If `TRUE`, detailed information about the request and response will be printed.
#' @param auth A list containing `base_url` and `headers` for authentication.
#'
#' @return The response from the Mattermost API.
#' @noRd
#'
#' @examples
#' \dontrun{
#' # Create a sample text file
#' fileconn <- file("output.txt")
#' writeLines(c("Hello", "world"), fileconn)
#' close(fileconn)
#'
#' teams <- get_all_teams()
#' team_channels <- get_team_channels(team_id = teams$id[1])
#' channel_id <- get_channel_id_lookup(team_channels, "Off-Topic")
#'
#' # Send a file and combine it with a message
#' response <- send_mattermost_message(
#'   channel_id = channel_id,
#'   message = "Here's a simple text file.",
#'   file_path = "output.txt",
#'   verbose = TRUE
#' )
#' print(response)
#' unlink(fileconn)
#' }
send_mattermost_file <- function(channel_id, file_path, comment = NULL, auth = get_default_auth(), verbose = FALSE) {

  # Define the endpoint for sending a file
  endpoint <- "/api/v4/files"

  # Check required input for completeness
  check_not_null(channel_id, "channel_id")
  check_not_null(file_path, "file_path")
  check_mattermost_auth(auth)

  # Check if the file exists
  if (!file.exists(file_path)) {
    stop("The file specified by 'file_path' does not exist.")
  }

  # Build multipart body
  body <- list(
    files = curl::form_file(file_path),
    channel_id = channel_id
  )

  if (!is.null(comment)) {
    body$comment <- comment
  }

  # Delegate to central API handler (provides retry, backoff, error handling, verbose)
  result <- mattermost_api_request(
    auth      = auth,
    endpoint  = endpoint,
    method    = "POST",
    body      = body,
    multipart = TRUE,
    verbose   = verbose
  )

  return(result)
}
