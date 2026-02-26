#' Send a Message to a Mattermost Channel with Optional Attachments
#'
#' This function sends a text message to a specified Mattermost channel, optionally including one or more attachment files and plots.
#'
#' @param channel_id The ID of the Mattermost channel where the message will be sent. Must be a non-empty string.
#' @param message The content of the message to be sent. Must be a non-empty string.
#' @param priority A string specifying the priority of the message. Must be one of:
#'   - "Normal" (default)
#'   - "Important"
#'   - "Urgent"
#' @param root_id Optional. The post ID of an existing message to reply to as a
#'   thread. When supplied, the new message appears as a threaded reply rather
#'   than a top-level post.
#' @param file_path A vector of file paths to be sent as attachments. Each path must point to an existing file.
#' @param comment A comment to accompany the attachment files. Useful for providing context or instructions.
#' @param plots A list of plot objects to attach to the message. Each plot can be:
#'   - A `ggplot2` object.
#'   - An R expression (e.g., `quote(plot(cars))`). Make sure to always wrap your expresion using the `quote()` function.
#'   - A function that generates a plot (e.g., `function() plot(cars)`).
#' @param plot_name A vector of names for the plot files. Extensions are optional; `.png` will be appended if missing.
#'   If multiple plots are provided with a single name, numbered names will be generated automatically.
#' @param verbose Boolean. If `TRUE`, the function will print detailed request and response information for debugging purposes.
#' @param auth The authentication object created by `authenticate_mattermost()`. Must be a valid `mattermost_auth` object.
#'
#' @return A list containing the parsed response from the Mattermost server, including details about the posted message and attachments.
#'
#' @details
#' - The function enforces a maximum of 5 total attachments (files + plots). Attempting to attach more will result in an error.
#' - Plot attachments are handled by the `handle_plot_attachments` helper function, which processes and uploads plots, returning their respective file IDs.
#' - Priority levels can influence how messages are displayed or handled within Mattermost, depending on server configurations.
#' @export
#' @examples
#' \dontrun{
#' # Define channel ID and message
#' auth = authenticate_mattermost()
#' teams <- get_all_teams()
#' team_channels <- get_team_channels(team_id = teams$id[1])
#' channel_id <- get_channel_id_lookup(team_channels, "Off-Topic")
#'
#' # Example 1: Send a simple message without attachments
#' response1 <- send_mattermost_message(
#'   channel_id = channel_id,
#'   message = "Hello, Mattermost!",
#'   auth = auth,
#'   verbose = TRUE
#' )
#' print(response1)
#'
#' # Example 2: Send a message with a single file attachment
#' # Create a temporary text file
#' temp_file <- tempfile(fileext = ".txt")
#' writeLines("This is a sample file attachment.", con = temp_file)
#'
#' response2 <- send_mattermost_message(
#'   channel_id = channel_id,
#'   message = "Here is a file for you.",
#'   file_path = temp_file,
#'   comment = "Please review the attached file.",
#'   auth = auth,
#'   verbose = TRUE
#' )
#' print(response2)
#'
#' # Clean up temporary file
#' unlink(temp_file)
#'
#' # Example 3: Send a message with multiple file attachments
#' # Create temporary files
#' temp_file1 <- tempfile(fileext = ".pdf")
#' temp_file2 <- tempfile(fileext = ".docx")
#'
#' # Create a ggplot and save it as a PDF
#' plot_pdf <- ggplot2::ggplot(mtcars, ggplot2::aes(x = wt, y = mpg)) +
#'   ggplot2::geom_point()
#' ggplot2::ggsave(filename = temp_file1, plot = plot_pdf)
#'
#' # Create a simple DOCX file using officer
#' doc <- officer::read_docx() |>
#'   officer::body_add_par("This is a sample Word document.", style = "Normal")
#' print(doc, target = temp_file2)
#'
#' response3 <- send_mattermost_message(
#'   channel_id = channel_id,
#'   message = "Please find the attached documents.",
#'   file_path = c(temp_file1, temp_file2),
#'   comment = "Attached: Report.pdf and Summary.docx.",
#'   priority = "Important",
#'   auth = auth,
#'   verbose = TRUE
#' )
#' print(response3)
#'
#' # Clean up temporary files
#' unlink(c(temp_file1, temp_file2))
#'
#' # Example 4: Send a message with plot attachments
#' # Define plots
#' plot1 <- ggplot2::ggplot(mtcars, ggplot2::aes(x = wt, y = mpg)) +
#'   ggplot2::geom_point()
#' plot2 <- function() plot(cars)
#'
#' # Call the function with plot attachments
#' response4 <- send_mattermost_message(
#'   channel_id = channel_id,
#'   message = "Check out these plots.",
#'   plots = list(plot1, plot2),
#'   plot_name = c("mtcars_plot.png", "cars_plot"),
#'   comment = "Attached: mtcars_plot and cars_plot.",
#'   auth = auth,
#'   verbose = TRUE
#' )
#' print(response4)
#'
#' # Example 5: Send a message with both file and plot attachments
#' # Create a temporary file
#' temp_file3 <- tempfile(fileext = ".csv")
#' write.csv(mtcars, file = temp_file3, row.names = FALSE)
#'
#' response5 <- send_mattermost_message(
#'   channel_id = channel_id,
#'   message = "Files and plots attached for your review.",
#'   file_path = temp_file3,
#'   plots = list(plot1, plot2),
#'   plot_name = c("mtcars_plot.png", "cars_plot"),
#'   comment = "Attached: mtcars_plot.png, cars_plot, and mtcars.csv.",
#'   priority = "Urgent",
#'   auth = auth,
#'   verbose = TRUE
#' )
#' print(response5)
#'
#'
#' # Example 6: Combine all plot possibilities and a file attachment
#' #Define additional plot using the `quote()` function.
#' plot3 <-  quote(plot(ggplot2::mpg))
#'
#' # Attempt to send 4 attachments (1 file + 3 plots)
#' response6 <- send_mattermost_message(
#'     channel_id = channel_id,
#'     message = "All possible plot types.",
#'     file_path = temp_file3,
#'     plots = list(plot1, plot2, plot3),
#'     plot_name = c("plot1.png", "plot2.png", "plot3.png"),
#'     comment = "sending all kind possible of attachments",
#'     priority = "Normal",
#'     auth = auth,
#'     verbose = TRUE
#'   )
#'
#' # Clean up temporary file
#' unlink(temp_file3)
#'
#' # Example 7: Reply to an existing message as a thread
#' response7 <- send_mattermost_message(
#'   channel_id = channel_id,
#'   message = "This is a threaded reply.",
#'   root_id = response1$id,
#'   auth = auth
#' )
#'
#' }
send_mattermost_message <- function(channel_id, message, priority = "Normal",
                                    root_id = NULL,
                                    file_path = NULL, comment = NULL,
                                    plots = NULL, plot_name = NULL,
                                    verbose = FALSE, auth = get_default_auth()) {

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
  all_file_ids  <- list()
  uploaded_file_ids <- list()

  if (!is.null(file_path)) {
    # Ensure that file_path is either a single file or multiple files
    if (length(file_path) < 1) {
      stop("The 'file_path' parameter must contain at least one valid file path.")
    }

    # Upload files and collect file IDs
    uploaded_file_ids <- upload_files(
      file_paths = file_path,
      channel_id = channel_id,
      comment = comment,
      auth = auth,
      verbose = verbose
    )

    # Append to all_file_ids
    all_file_ids <- c(all_file_ids, uploaded_file_ids)
  }

  # Handle plot attachments using the helper function
  if (!is.null(plots)) {
    # Upload plot attachments and collect file IDs
    plot_file_ids <- handle_plot_attachments(
      plots = plots,
      plot_name = plot_name,
      channel_id = channel_id,
      comment = comment,
      auth = auth,
      verbose = verbose
    )

    # Append to all_file_ids
    all_file_ids <- c(all_file_ids, plot_file_ids)
  }

    # Ensure that the number of files does not exceed 5
  if (length(all_file_ids) > 5) {
      stop("A maximum of 5 files can be attached to a message.")
  }

   # Ensure that mattermost_api_request from being called if upload_files returns NULL.
  if (!is.null(file_path) || !is.null(plots)) {
    # Ensure that mattermost_api_request is not called if upload_files or handle_plot_attachments fails.
    if (is.null(all_file_ids) || length(all_file_ids) == 0) {
      stop("Unexpected format in file response. Unable to extract file ID.")
    }
  }


  # Define the endpoint for sending messages
  endpoint <- "/api/v4/posts"

  # Prepare the body of the message
  body <- list(
    channel_id = channel_id,
    message = message
  )

  # If root_id is provided, include it for thread replies
  if (!is.null(root_id)) {
    body$root_id <- root_id
  }

  # If file_ids are present, include them in the body
  if (length(all_file_ids) > 0) {
    body$file_ids <- all_file_ids
  }

  # Only add priority if it's different from "Normal"
  # Priority must go under metadata (not props) per Mattermost server source.
  # See: Post.GetPriority() reads from Metadata.Priority
  # Valid API values: "" (standard), "important", "urgent"
  if (priority != "Normal") {
    body$metadata <- list(
      priority = list(
        priority = switch(priority,
                          "Important" = "important",
                          "Urgent" = "urgent",
                          priority)
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
#' Valid priorities match the Mattermost UI: Normal, Important, Urgent.
#'
#' @param priority A string representing the priority.
#' @return A string with the corrected priority format.
normalize_priority <- function(priority) {
  priority_lowered <- tolower(priority)  # Convert to lower case for normalization

  if (priority_lowered == "normal") {
    return("Normal")
  } else if (priority_lowered == "important") {
    return("Important")
  } else if (priority_lowered == "urgent") {
    return("Urgent")
  } else {
    stop(sprintf("Invalid priority: '%s'. Must be one of: Normal, Important, Urgent", priority))
  }
}


# Mattermost REST API specification for POST /api/v4/posts:
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
#       "priority": "string",        # "", "important", or "urgent"
#       "requested_ack": true
#     }
#   }
# }
