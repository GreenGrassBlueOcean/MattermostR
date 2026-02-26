#' Auto-paginate a Mattermost GET endpoint
#'
#' Internal helper that iterates through pages of results from a Mattermost API
#' endpoint that supports \code{page} and \code{per_page} query parameters.
#' Accumulates all pages into a single data frame.
#'
#' @param auth A \code{mattermost_auth} object.
#' @param endpoint The API endpoint path (e.g. \code{"/api/v4/teams"}).
#'   May already contain a query string (\code{?key=value}).
#' @param per_page Integer. Number of results per page (max 200).
#' @param max_pages Numeric. Maximum number of pages to fetch. Defaults to
#'   \code{Inf} (fetch all). Acts as a safety valve for very large result sets.
#' @param transform Optional function applied to each page's raw API response
#'   before accumulating. Useful for endpoints that return nested structures
#'   (e.g. the posts endpoint returns a \code{PostList} object that needs
#'   conversion to a data frame). When \code{NULL} (default), the raw result
#'   from \code{mattermost_api_request()} is used as-is.
#' @param verbose Logical. Passed through to \code{mattermost_api_request()}.
#'
#' @return A data frame combining all pages, or an empty data frame if the
#'   first page is empty.
#' @noRd
paginate_api <- function(auth, endpoint, per_page = 200, max_pages = Inf,
                         transform = NULL, verbose = FALSE) {
  all_results <- list()
  page <- 0L

  repeat {
    sep <- if (grepl("\\?", endpoint)) "&" else "?"
    paged_endpoint <- sprintf("%s%spage=%d&per_page=%d",
                              endpoint, sep, page, per_page)

    result <- mattermost_api_request(auth, paged_endpoint,
                                     method = "GET", verbose = verbose)

    # Guard against unexpected error responses that slipped through
    if (is.list(result) && !is.data.frame(result) &&
        "message" %in% names(result) && "status_code" %in% names(result)) {
      stop(sprintf("API error during pagination (page %d): %s",
                   page, result$message))
    }

    # Apply per-page transform if provided
    if (!is.null(transform)) {
      result <- transform(result)
    }

    # Determine page size
    if (is.data.frame(result)) {
      n <- nrow(result)
    } else if (is.list(result)) {
      n <- length(result)
    } else {
      break
    }

    if (n == 0L) break

    all_results[[length(all_results) + 1L]] <- result

    if (n < per_page) break

    page <- page + 1L
    if (page >= max_pages) break
  }

  if (length(all_results) == 0L) return(data.frame())

  do.call(rbind, all_results)
}
