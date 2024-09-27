# File: R/send_message.R

#' Send a text message to a Mattermost channel
#'
#' @param channel_id The ID of the Mattermost channel.
#' @param message The message content.
#' @param priority A string specifying the priority of the message. Must be one of:
#'   - "Normal" (default)
#'   - "High"
#'   - "Low"
#' @param verbose Boolean. If `TRUE`, the function will print request/response details for more information.
#' @param file_path The path to the file to be sent.
#' @param auth The authentication object created by `authenticate_mattermost()`.
#' @param comment A comment to accompany the attachment file.
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
#' # Send the message with Normal priority
#' response <- send_mattermost_message(channel_id = channel_id
#' , message = message, priority = "Low", verbose = TRUE)
#'
#'
#' #send message with attachment file
#' fileconn <- file("output.txt")
#' writeLines(c("Hello", "world"), fileconn)
#' close(fileconn)
#'
#' response <- send_mattermost_message(channel_id = channel_id
#' , message = message, file_path = "output.txt", verbose = TRUE, priority = "High")
#' unlink(fileconn)
#' }
send_mattermost_message <- function( channel_id, message, priority = NULL
                                     , file_path = NULL, comment = NULL
                                     , verbose = FALSE, auth = authenticate_mattermost()) {

  # Check required input for completeness
  check_not_null(channel_id, "channel_id")
  check_not_null(message, "message")
  check_mattermost_auth(auth)

  # Normalize and validate priority if provided
  if (!is.null(priority)) {
    priority <- normalize_priority(priority)
  }

  # File upload handling
  file_ids <- NULL
  if (!is.null(file_path)) {
    file_response <- send_mattermost_file( channel_id = channel_id
                                           , file_path = file_path
                                           , comment = comment
                                           , auth = auth
                                           , verbose = verbose)
    # Extract file_id(s) from response (assuming response has a field 'file_infos')
    file_ids <- list(file_response$file_infos[1]$id)  # Modify based on actual API response structure
  }

  # Define the endpoint for sending messages
  endpoint <- "/api/v4/posts"

  # Prepare the body of the message
  body <- list(
    channel_id = channel_id,
    message = message
  )

  # If file_ids are present, include them in the body
  if (!is.null(file_ids)) {
    body$file_ids <- file_ids
  }

  # Add priority metadata if provided
  if (!is.null(priority)) {
    body$metadata <- list(
      priority = list(
        priority = priority,
        requested_ack = TRUE  # Set this to TRUE or allow the user to control it if needed
      )
    )
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
