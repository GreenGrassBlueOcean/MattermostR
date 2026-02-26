#' Compact error checking for required parameters
#'
#' This function checks if a parameter is NULL, has length zero, or is a single
#' empty string and throws an error if so.
#'
#' @param param The parameter to check.
#' @param param_name The name of the parameter (used in the error message).
#'
#' @noRd
check_not_null <- function(param, param_name) {
  if (is.null(param) || length(param) == 0 || (length(param) == 1 && is.character(param) && !nzchar(param))) {
    stop(paste(param_name, "cannot be empty or NULL"))
  }
}
