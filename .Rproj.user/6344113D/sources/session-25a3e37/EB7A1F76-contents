# File: R/get_mattermost_file.R

#' Retrieve a file from Mattermost
#'
#' This function retrieves a file from Mattermost based on its file ID.
#'
#' @param file_id The ID of the file to be retrieved.
#' @param auth A list containing `base_url` and `headers` for authentication.
#' @return The response from the Mattermost API, which may contain the file data.
#' @export
#' @examples
#' \dontrun{
#' # Assuming you have already authenticated and obtained the file_id
#' file_id <- "your_file_id_here"
#' file_response <- get_mattermost_file(file_id = file_id)
#' print(file_response)
#'
#' file_response <- get_mattermost_file(file_id = "i5rb43jei787jxcud7ekyyyyhc")
#' }
get_mattermost_file <- function(file_id, auth = authenticate_mattermost()) {

  # Check required input for completeness
  check_not_null(file_id, "file_id")
  check_mattermost_auth(auth)

  # Define the endpoint for retrieving the file
  endpoint <- paste0("/api/v4/files/", file_id)

  # Send the request to get channels
  file_data <- mattermost_api_request(auth, endpoint, method = "GET")

  return(file_data)
}
