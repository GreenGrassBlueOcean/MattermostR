# File: R/utils.R

#' Compact error checking for required parameters
#'
#' This function checks if a parameter is NULL or an empty string and throws an error if it is.
#'
#' @param param The parameter to check.
#' @param param_name The name of the parameter (used in the error message).
#'
#' @noRd
check_not_null <- function(param, param_name) {
  if (is.null(param) || !nzchar(param)) {
    stop(paste(param_name, "cannot be empty or NULL"))
  }
}
