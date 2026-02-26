
#' Retrieve a file from Mattermost
#'
#' This function retrieves a file from Mattermost based on its file ID.
#'
#' @param file_id The ID of the file to be retrieved.
#' @param auth The authentication object created by [authenticate_mattermost()].
#' @return The file contents as returned by the Mattermost API. The exact type
#'   depends on the file's content type (typically raw bytes or a character
#'   string).
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
get_mattermost_file <- function(file_id, auth = get_default_auth()) {

  # Check required input for completeness
  check_not_null(file_id, "file_id")
  check_mattermost_auth(auth)

  # Define the endpoint for retrieving the file
  endpoint <- paste0("/api/v4/files/", file_id)

  # Send the request to get channels
  file_data <- mattermost_api_request(auth, endpoint, method = "GET")

  return(file_data)
}
