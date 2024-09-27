# File: R/send_mattermost_file.R

#' Send a file to a Mattermost channel
#'
#' This function sends a file to a specified Mattermost channel along with an optional comment
#'
#' @param channel_id The ID of the channel to which the file should be sent.
#' @param file_path The path to the file to be sent.
#' @param comment A comment to accompany the file.
#' @param verbose (Logical) If `TRUE`, detailed information about the request and response will be printed.
#' @param auth A list containing `base_url` and `headers` for authentication.
#'
#' @return The response from the Mattermost API.
#' @export
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
#' response <- send_mattermost_file(channel_id = channel_id
#' ,file_path = "output.txt",comment = "A simple text file.", verbose = TRUE)
#' print(response)
#' unlink(fileconn)
#' }
send_mattermost_file <- function(channel_id, file_path, comment = NULL, auth = authenticate_mattermost(), verbose = FALSE) {

  # Define the endpoint for sending a file
  endpoint <- paste0("/api/v4/files")

  # Check required input for completeness
  check_not_null(channel_id, "channel_id")
  check_not_null(file_path, "file_path")
  check_mattermost_auth(auth)

  # Construct headers
  headers <- list(
    Authorization = auth$headers,
    Accept = "application/json"
  )

  # Create the request object with base URL
  req <- httr2::request(paste0(auth$base_url, endpoint)) |>
         httr2::req_headers(!!!headers)

  if(!is.null(comment)){
    req <- httr2::req_body_multipart(req,
                                     files = curl::form_file(file_path), # Add the file to the request
                                     channel_id = channel_id,
                                     comment = comment)
  } else {
    req <- httr2::req_body_multipart(req,
                                     files = curl::form_file(file_path), # Add the file to the request
                                     channel_id = channel_id
                                     )

  }


  if(verbose){
    req |> httr2::req_verbose()
  }

  # Perform the request and handle the response
  response <- httr2::req_perform(req)

  # Handle the response content
  result <- handle_response_content(response, verbose = verbose)

  return(result)
}
