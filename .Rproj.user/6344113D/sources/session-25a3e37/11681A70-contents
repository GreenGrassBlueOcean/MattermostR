# File: R/check_mattermost_status.R

#' Check if the Mattermost server is online
#'
#' @param verbose Boolean. If `TRUE`, the function will print request/response details for more information.
#' @param auth A list containing `base_url` and `headers` for authentication.
#'
#' @return TRUE if the server is online; FALSE otherwise.
#' @examples
#' \dontrun{
#' check_mattermost_status()
#' }
#'
check_mattermost_status <- function(verbose = FALSE, auth = authenticate_mattermost()) {

  # Check required input for completeness
  check_mattermost_auth(auth)

  endpoint <- "/api/v4/system/ping"

  # Perform the request
  response <- mattermost_api_request( auth = auth
                                    , endpoint = endpoint
                                    , method = "GET"
                                    , verbose = verbose)

  # Check the response status code
  if (!is.null(response) && response$status == "OK") {
    return(TRUE)  # Server is online
  } else {
    return(FALSE)  # Server is offline or encountered an error
  }
}
