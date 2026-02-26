#' Get Channel ID by Display Name or Name
#'
#' This function retrieves the channel ID associated with a specified display name or name
#' from a data frame of channels. If multiple channels have the same display name, the name
#' parameter can be used to disambiguate.
#'
#' @param channels_df A data frame containing channel information. It must include at least three columns:
#'                    `id` (the channel ID), `display_name`, and `name`.
#' @param display_name (Optional) A character string representing the display name of the channel for which
#'                     the ID is to be retrieved.
#' @param name (Optional) A character string representing the unique name of the channel for which the ID is to be retrieved.
#'
#' @return A character string containing the channel ID if found, otherwise an error is thrown.
#' @export
#'
#' @examples
#' # Sample channels data frame
#' channels <- data.frame(
#'   id = c("gy91r1kjnbnkdfu6jjoxzcm5ge", "utbtjouxkirniyh9u84oym6mnh", "abc12345xyz", "xyz56789abc"),
#'   display_name = c("Off-Topic", "Town Square", "Off-Topic", "Random"),
#'   name = c("off-topic", "town-square", "off-topic-team", "random"),
#'   stringsAsFactors = FALSE
#' )
#'
#' # As this display_name is not unique for "Off-Topic" this will lead to an error.
#' #' # get_channel_id_lookup(channels, display_name = "Off-Topic")
#'
#' # this will however return a result
#' get_channel_id_lookup(channels, display_name = "Town Square")
#'
#' # Get the channel ID for "Town Square" by name
#' get_channel_id_lookup(channels, name = "town-square")
get_channel_id_lookup <- function(channels_df, display_name = NULL, name = NULL) {

  # Validate input
  if (!is.data.frame(channels_df) || !all(c("id", "display_name", "name") %in% names(channels_df))) {
    stop("Input must be a data frame containing 'id', 'display_name', and 'name' columns.")
  }

  if (is.null(display_name) && is.null(name)) {
    stop("Either 'display_name' or 'name' must be provided.")
  }

  # Filter channels by display_name if provided
  if (!is.null(display_name)) {
    matched_channels <- channels_df[channels_df$display_name == display_name, ]
  } else {
    matched_channels <- channels_df
  }

  # Further filter by name if provided
  if (!is.null(name)) {
    matched_channels <- matched_channels[matched_channels$name == name, ]
  }

  # Check if any channel is found
  if (nrow(matched_channels) == 0) {
    stop("No channel found with the specified display_name or name.")
  }

  # Check if multiple channels match the display_name without disambiguation
  if (nrow(matched_channels) > 1 && is.null(name)) {
    stop("Multiple channels found with the same display_name. Please provide the 'name' for disambiguation.")
  }

  # Return the first matched channel ID
  return(matched_channels$id[1])
}
