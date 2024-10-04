# File: R/send_message.R

#' Send a text message to a Mattermost channel, optionally with multiple attachments
#'
#' This function sends a text message to a Mattermost channel, optionally including one or more attachment files.
#'
#' @param channel_id The ID of the Mattermost channel.
#' @param message The message content.
#' @param priority A string specifying the priority of the message. Must be one of:
#'   - "Normal" (default)
#'   - "High"
#'   - "Low"
#' @param verbose Boolean. If `TRUE`, the function will print request/response details for more information.
#' @param file_path A vector of file paths to be sent as attachments.
#' @param comment A comment to accompany the attachment files.
#' @param auth The authentication object created by `authenticate_mattermost()`.
#'
#' @return Parsed response from the Mattermost server.
#' @export
#' @examples
#' \dontrun{
#' # Define channel ID and message
#' authenticate_mattermost()
#' teams <- get_all_teams()
#' team_channels <- get_team_channels(team_id = teams$id[1])
#' channel_id <- get_channel_id_lookup(team_channels, "Off-Topic")
#'
#' message <- paste("Hello, Mattermost! This is a test message at", Sys.time())
#'
#' # Send the message with a plot attachment
#' tmp_plot <- tempfile(fileext = ".png")
#' plot <- ggplot2::ggplot(cars, ggplot2::aes(x = speed, y = dist)) +
#'   ggplot2::geom_point()
#'
#' ggplot2::ggsave(filename = tmp_plot, plot = plot)
#'
#' response <- send_mattermost_message(
#'   channel_id = channel_id,
#'   message = message,
#'   priority = "High",
#'   file_path = tmp_plot,
#'   verbose = TRUE
#' )
#' print(response)
#'
#'
#' # Send message with a text file attachment
#' fileconn <- file("output.txt")
#' writeLines(c("Hello", "world"), fileconn)
#' close(fileconn)
#'
#' response <- send_mattermost_message(
#'   channel_id = channel_id,
#'   message = message,
#'   file_path = c("output.txt", tmp_plot),
#'   verbose = TRUE,
#'   priority = "High"
#' )
#' print(response)
#' unlink("output.txt")
#' unlink(tmp_plot)
#' }
send_mattermost_message <- function(channel_id, message, priority = "Normal",
                                    file_path = NULL, comment = NULL,
                                    verbose = FALSE, auth = authenticate_mattermost()) {

  # Check required input for completeness
  check_not_null(channel_id, "channel_id")
  check_not_null(message, "message")
  check_mattermost_auth(auth)

  # Set priority to "Normal" if it is NULL
  if (is.null(priority)) {
    priority <- "Normal"
  }

  # Normalize and validate priority
  priority <- normalize_priority(priority)

  # File upload handling
  file_infos <- list()
  if (!is.null(file_path)) {
    # Ensure that file_path is either a single file or multiple files
    if (length(file_path) < 1) {
      stop("The 'file_path' parameter must contain at least one valid file path.")
    }

    # Iterate through each file and upload it
    file_infos <- lapply(file_path, function(path) {
      # Check if the file exists
      if (!file.exists(path)) {
        stop(sprintf("The file specified by 'file_path' does not exist: %s", path))
      }

      # Upload the file
      file_response <- send_mattermost_file(
        channel_id = channel_id,
        file_path = path,
        comment = comment,
        auth = auth,
        verbose = verbose
      )

      # Extract file_info from response
      if (is.list(file_response$file_infos) && length(file_response$file_infos) > 0) {
        return(file_response$file_infos[[1]])
      } else {
        stop("Unexpected format in file response. Unable to extract file ID.")
      }
    })
  }

  # Extract file IDs from file_infos
  file_ids <- unlist(file_infos)

  # Define the endpoint for sending messages
  endpoint <- "/api/v4/posts"

  # Prepare the body of the message
  body <- list(
    channel_id = channel_id,
    message = message
  )

  # If file_ids are present, include them in the body
  if (length(file_ids) > 0) {
    body$file_ids <- file_ids
  }

  # Only add priority if it's different from "Normal"
  if (priority != "Normal") {
    body$props <- list(
      priority = list(
        priority = priority,
        requested_ack = TRUE  # Set to TRUE if you want acknowledgments
      )
    )
  }

  # For debugging: print the body
  if (verbose) {
    cat("Request Body:\n", jsonlite::toJSON(body, auto_unbox = TRUE, pretty = TRUE), "\n")
  }

  # Send the request using the mattermost_api_request function
  response <- mattermost_api_request(
    auth = auth,
    endpoint = endpoint,
    method = "POST",
    body = body,
    verbose = verbose
  )

  return(response)
}

#' Normalize the priority input
#'
#' This function converts various casing inputs for priority to the correct format.
#'
#' @param priority A string representing the priority.
#' @return A string with the corrected priority format.
normalize_priority <- function(priority) {
  priority_lowered <- tolower(priority)  # Convert to lower case for normalization

  if (priority_lowered == "normal") {
    return("Normal")
  } else if (priority_lowered == "high") {
    return("High")
  } else if (priority_lowered == "low") {
    return("Low")
  } else {
    stop(sprintf("Invalid priority: '%s'. Must be one of: Normal, High, Low", priority))
  }
}


# !!! this is the rest api specification!!!!
# therefore file_ids and priority are not working at this moment
# {
#   "channel_id": "string",
#   "message": "string",
#   "root_id": "string",
#   "file_ids": [
#     "string"
#   ],
#   "props": {},
#   "metadata": {
#     "priority": {
#       "priority": "string",
#       "requested_ack": true
#     }
#   }
# }
