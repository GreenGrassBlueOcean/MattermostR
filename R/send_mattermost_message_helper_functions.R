#' Validate Plots and Plot Names for use in send_mattermost_message
#'
#' Validates the plots and plot_name arguments. Ensures that:
#' - plots is a list.
#' - plot_name has valid extensions.
#' - If multiple plots are provided, plot_name length matches the number of plots.
#' - If a single plot_name is provided, it generates numbered names for multiple plots.
#'
#' @param plots A single plot or a list of plots. Each plot can be:
#'   - A ggplot2 object.
#'   - An R expression (e.g., \code{\{ plot(cars) \}}).
#'   - A function that generates a plot (e.g., \code{function() plot(cars)}).
#' @param plot_name A single name or a vector of names for the plot files. Extensions are optional.
#'   If a single name is provided, numbered names are generated for multiple plots.
#'
#' @return A list containing:
#'   - plots: The validated list of plots.
#'   - plot_name: A vector of validated and correctly extended plot names.
#'  @details Errors that may occur:
#'   - plot_name length does not match plots length.
#'   - Any file name in plot_name has an invalid extension.
#' @noRd
validate_plots <- function(plots, plot_name) {
  # Ensure plots is a list
  if (!inherits(plots, "list")) {
    plots <- list(plots)
  }

  # Validate plot_name length
  if (length(plot_name) > 1 && length(plot_name) != length(plots)) {
    stop(sprintf(
      "Error: The length of 'plot_name' (%d) does not match the number of plots (%d).",
      length(plot_name), length(plots)
    ))
  }

  # Generate numbered names if a single name is provided
  if (length(plot_name) == 1 && length(plots) > 1) {
    base_name <- tools::file_path_sans_ext(plot_name)
    ext <- tools::file_ext(plot_name)
    plot_name <- paste0(base_name, seq_along(plots), ".", ifelse(ext == "", "png", ext))
  } else if(length(plot_name) == 0 && length(plots) > 0){
    plot_name <- paste0("plot", seq_along(plots), ".png")
  }

  # Ensure all plot names have valid extensions
  plot_name <- unname(sapply(plot_name, function(name) {
    if (tools::file_ext(name) == "") {
      paste0(name, ".png")
    } else {
      name
    }
  }))

  # Validate file extensions
  valid_extensions <- c("png", "pdf", "jpeg", "jpg", "tiff", "bmp", "svg")
  invalid_names <- plot_name[!tools::file_ext(plot_name) %in% valid_extensions]
  if (length(invalid_names) > 0) {
    stop(sprintf(
      "Invalid file extensions: %s. Allowed extensions are: %s.",
      paste(invalid_names, collapse = ", "),
      paste(valid_extensions, collapse = ", ")
    ))
  }

  list(plots = plots, plot_name = plot_name)
}





#' Save a Plot to File for use in send_mattermost_message
#'
#' Saves a single plot to a specified file path. Supports:
#' - ggplot2 objects.
#' - Base R plot expressions.
#' - Functions that generate base R plots.
#'
#' @param plot A single plot to save. Can be:
#'   - A ggplot2 object.
#'   - An R expression (e.g., \code{\{ plot(cars) \}}).
#'   - A function that generates a plot (e.g., \code{function() plot(cars)}).
#' @param file_path The path where the plot should be saved. Must include a valid extension.
#' @details Errors that may occur:
#'   - If plot is unsupported, an error is raised.
#'   - If ggplot2 is required but not installed, an error is raised.
#' @noRd
save_plot <- function(plot, file_path) {
  if (inherits(plot, "ggplot")) {
    # Check if ggplot2 is installed
    if (!requireNamespace("ggplot2", quietly = TRUE)) {
      stop("The 'ggplot2' package is required to handle ggplot objects. Please install it.")
    }
    ggplot2::ggsave(filename = file_path, plot = plot)
  } else if (is.language(plot) || is.call(plot)) {
    # Handle base R plot expressions
    grDevices::png(filename = file_path)
    eval(plot)
    grDevices::dev.off()
  } else if (is.function(plot)) {
    # Handle base R plot functions
    grDevices::png(filename = file_path)
    plot()
    grDevices::dev.off()
  } else {
    stop("Each item in 'plots' must be a ggplot2 object, an expression, or a function.")
  }
}


#' Upload Files to a Mattermost Channel for use in send_mattermost_message
#'
#' Uploads one or more files to a Mattermost channel and returns their file IDs.
#'
#' @param file_paths A vector of file paths to upload. All files must exist.
#' @param channel_id The ID of the Mattermost channel where the files will be uploaded.
#' @param comment An optional comment to accompany the files.
#' @param auth The authentication object created by \code{authenticate_mattermost()}.
#' @param verbose Boolean. If TRUE, prints request/response details for debugging.
#' @return A list of file IDs for the uploaded files.
#' @details Errors that may occur:
#'   - Any file in file_paths does not exist.
#'   - The response from the Mattermost server is unexpected or invalid.
#' @noRd
upload_files <- function(file_paths, channel_id, comment, auth, verbose) {
  file_ids <- lapply(file_paths, function(path) {
    # Check if the file exists
    if (!file.exists(path)) {
      stop(sprintf("The file specified by 'file_path' does not exist: %s", path))
    }

    # Upload the file
    file_response <- send_mattermost_file(
      channel_id = channel_id,
      file_path = path,
      comment = comment,
      auth = auth,
      verbose = verbose
    )

    # Extract file_info from response
    if (is.data.frame(file_response$file_infos) && nrow(file_response$file_infos) > 0) {
      return(file_response$file_infos[1, "id"])
    } else {
      stop("Unexpected format in file response. Unable to extract file ID.")
    }
  })
  file_ids
}

#' Handle Plot Attachments for Mattermost Messages
#'
#' This function processes plot objects by validating them, saving them to temporary files,
#' uploading the files to Mattermost, and returning their corresponding file IDs.
#'
#' @param plots A single plot or a list of plots. Each plot can be:
#'   - A ggplot2 object.
#'   - An R expression (e.g., \code{\{ plot(cars) \}}).
#'   - A function that generates a plot (e.g., \code{function() plot(cars)}).
#' @param plot_name A single name or a vector of names for the plot files. Extensions are optional.
#'   If a single name is provided, numbered names are generated for multiple plots.
#' @param channel_id The ID of the Mattermost channel where the plots will be uploaded.
#' @param comment An optional comment to accompany the plot files.
#' @param auth The authentication object created by \code{authenticate_mattermost()}.
#' @param verbose Boolean. If `TRUE`, the function will print request/response details for more information.
#'
#' @return A list of `file_ids` corresponding to the uploaded plot files.
#'
#' @details
#' - The function ensures that the number of plot names matches the number of plots provided.
#' - It appends a default `.png` extension to plot names that lack an extension.
#' - A maximum of 5 plot files can be attached to a message.
#'
#'
#' @examples
#' \dontrun{
#' # Define plots
#' plot1 <- ggplot2::ggplot(mtcars, ggplot2::aes(x = wt, y = mpg)) +
#'   ggplot2::geom_point()
#' plot2 <- function() plot(cars)
#'
#' # Handle plot attachments
#' file_ids <- handle_plot_attachments(
#'   plots = list(plot1, plot2),
#'   plot_name = c("mtcars_plot.png", "cars_plot"),
#'   channel_id = "channel_123",
#'   comment = "Here are some plots",
#'   auth = authenticate_mattermost(),
#'   verbose = TRUE
#' )
#' }
#'
#' @noRd
handle_plot_attachments <- function(plots, plot_name, channel_id, comment = NULL,
                                    auth, verbose = FALSE) {

  # Validate plots and plot_name using the helper function
  validated <- validate_plots(plots, plot_name)
  validated_plots <- validated$plots
  validated_plot_names <- validated$plot_name

  # Enforce maximum attachment limit
  if (length(validated_plots) > 5) {
    stop("A maximum of 5 plots can be attached to a message.")
  }

  # Save plots to temporary files with correct extensions
  plot_files <- mapply(
    FUN = function(plot, name) {
      # Remove extension from name for tempfile
      name_no_ext <- tools::file_path_sans_ext(name)

      # Extract extension
      ext <- tools::file_ext(name)

      # Create a temp file with the correct extension
      tmp_file <- tempfile(pattern = name_no_ext, fileext = paste0(".", ext))

      # Save the plot
      save_plot(plot, tmp_file)

      # Return the temp file path
      tmp_file
    },
    plot = validated_plots,
    name = validated_plot_names,
    SIMPLIFY = FALSE
  )

  # Convert list of plot_files to a character vector
  plot_files_vector <- unname(unlist(plot_files))

  # Upload plot files and collect file_ids
  plot_file_ids <- upload_files(
    file_paths = plot_files_vector,
    channel_id = channel_id,
    comment = comment,
    auth = auth,
    verbose = verbose
  )

  # Clean up temporary plot files
  lapply(plot_files_vector, unlink)

  # Return the list of plot file IDs
  return(plot_file_ids)
}
