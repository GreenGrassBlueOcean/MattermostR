library(mockery)
library(testthat)
library(ggplot2)

# Unittest for validate_plots
test_that("validate_plots validates plot names and extensions correctly", {
  # Single plot with a single valid name
  plots <- ggplot(data.frame(x = 1:10, y = 1:10), aes(x = x, y = y)) + geom_point()
  plot_name <- "plot1.png"
  result <- validate_plots(plots, plot_name)
  expect_equal(length(result$plots), 1)
  expect_equal(result$plot_name, "plot1.png")

  # Multiple plots with generated names
  plots_list <- list(
    ggplot(data.frame(x = 1:10, y = 1:10), aes(x = x, y = y)) + geom_point(),
    ggplot(data.frame(x = 1:10, y = (1:10)^2), aes(x = x, y = y)) + geom_point(),
    ggplot(data.frame(x = 1:10, y = (1:10)^3), aes(x = x, y = y)) + geom_point()
  )
  plot_name <- "plot"
  result <- validate_plots(plots_list, plot_name)
  expect_equal(length(result$plots), 3)
  expect_equal(result$plot_name, c("plot1.png", "plot2.png", "plot3.png"))

  # Invalid extension
  expect_error(validate_plots(plots_list, "plot.doc"),
               "Invalid file extensions")

  # Length mismatch between plots and names
  expect_error(
    validate_plots(plots_list, c("plot1.png", "plot2.png")),
    "The length of 'plot_name' \\(2\\) does not match the number of plots \\(3\\)."
  )
})


test_that("validate_plots appends default .png extension to plot names without an extension", {
  # Single plot without an extension in plot_name
  plots <- ggplot2::ggplot(data.frame(x = 1:10, y = 1:10), aes(x = x, y = y)) + geom_point()
  plot_name <- "plot1" # No extension
  result <- validate_plots(plots, plot_name)

  # Expect the plot name to have .png appended
  expect_equal(result$plot_name, "plot1.png")

  # Multiple plots with names missing extensions
  plots <- list(
    ggplot2::ggplot(data.frame(x = 1:10, y = 1:10), aes(x = x, y = y)) + geom_point(),
    ggplot2::ggplot(data.frame(x = 1:10, y = (1:10)^2), aes(x = x, y = y)) + geom_point()
  )
  plot_name <- "plot" # No extension
  result <- validate_plots(plots, plot_name)

  # Expect the plot names to have .png appended with numbering
  expect_equal(result$plot_name, c("plot1.png", "plot2.png"))
})



# Unittest for save_plot
test_that("save_plot saves plots to files correctly", {
  # Temp file for testing
  tmp_file <- tempfile(fileext = ".png")

  # ggplot2 plot
  plot <- ggplot(data.frame(x = 1:10, y = 1:10), aes(x = x, y = y)) + geom_point()
  save_plot(plot, tmp_file)
  expect_true(file.exists(tmp_file))

  # Base R plot expression
  tmp_file2 <- tempfile(fileext = ".png")
  plot_expr <- quote(plot(cars))
  save_plot(plot_expr, tmp_file2)
  expect_true(file.exists(tmp_file2))

  # Plot function
  tmp_file3 <- tempfile(fileext = ".png")
  plot_fn <- function() plot(cars)
  save_plot(plot_fn, tmp_file3)
  expect_true(file.exists(tmp_file3))

  # Unsupported plot type
  expect_error(save_plot(list(), tmp_file),
               "Each item in 'plots' must be a ggplot2 object, an expression, or a function.")

  # Clean up
  file.remove(tmp_file, tmp_file2, tmp_file3)
})


test_that("save_plot throws an error if ggplot2 is not installed (requireNamespace returns FALSE)", {
  # Define the mock for requireNamespace to return FALSE
  mock_requireNamespace <- function(pkg, quietly = TRUE) {
    FALSE
  }

  # Stub the requireNamespace function within save_plot to use the mock
  stub(save_plot, "requireNamespace", mock_requireNamespace)

  # Create a mock ggplot object
  mock_plot <- structure(list(), class = "ggplot")
  tmp_file <- tempfile(fileext = ".png")

  # Expect the specific error message
  expect_error(
    save_plot(mock_plot, tmp_file),
    "The 'ggplot2' package is required to handle ggplot objects. Please install it."
  )
})


# Unittest for upload_files
test_that("upload_files uploads files correctly and returns file IDs", {
  # Mock files
  tmp_file1 <- tempfile(fileext = ".txt")
  tmp_file2 <- tempfile(fileext = ".txt")
  writeLines("test content", tmp_file1)
  writeLines("test content", tmp_file2)

  # Mock auth object
  auth <- structure(list(token = "mock_token", url = "http://mockserver"), class = "mattermost_auth")

  # Define the mocked version of send_mattermost_file
  mocked_send_mattermost_file <- function(channel_id, file_path, comment, auth, verbose) {
    if (!grepl("^http", auth$url)) stop("Invalid URL")
    list(file_infos = data.frame(id = paste0("mock_file_id_", basename(file_path))))
  }

  # Stub the send_mattermost_file function
  stub(upload_files, "send_mattermost_file", mocked_send_mattermost_file)

  # Test single file upload
  file_ids <- upload_files(file_paths = tmp_file1, channel_id = "channel_123", comment = "test", auth = auth, verbose = FALSE)
  expect_equal(file_ids[[1]], paste0("mock_file_id_", basename(tmp_file1)))

  # Test multiple file uploads
  file_ids <- upload_files(file_paths = c(tmp_file1, tmp_file2), channel_id = "channel_123", comment = "test", auth = auth, verbose = FALSE)
  expect_equal(file_ids, list(paste0("mock_file_id_", basename(tmp_file1)), paste0("mock_file_id_", basename(tmp_file2))))

  # Test non-existent file
  expect_error(upload_files(file_paths = "non_existent_file.txt", channel_id = "channel_123", comment = "test", auth = auth, verbose = FALSE),
               "The file specified by 'file_path' does not exist")

  # Clean up
  file.remove(tmp_file1, tmp_file2)
})



#handle_plot_attachments tests

library(testthat)
library(mockery)
library(ggplot2)
# Define a mock auth object with class 'mattermost_auth'
mock_auth <- structure(
  list(
    token = "mock_token",
    url = "https://mock-mattermost.example.com",
    headers = "Bearer mock_token"
  ),
  class = "mattermost_auth"
)

# Test suite for handle_plot_attachments
test_that("() successfully processes a single plot", {

  # Mock the upload_files function to return a mock file ID
  mockery::stub(handle_plot_attachments, 'upload_files', function(file_paths, channel_id, comment, auth, verbose) {
    # Verify that the file exists
    expect_true(all(file.exists(file_paths)))
    # Verify that the file has a .png extension
    expect_true(all(grepl("\\.png$", file_paths)))
    return(list("file_plot123"))
  })

  # Mock the save_plot function to create a dummy file instead of actual plotting
  mockery::stub(handle_plot_attachments, 'save_plot', function(plot, file_path) {
    # Create a dummy file to simulate a saved plot
    writeLines("dummy plot content", con = file_path)
    return(file_path)
  })

  # Define a ggplot object
  plot <- ggplot2::ggplot(mtcars, ggplot2::aes(x = wt, y = mpg)) +
    ggplot2::geom_point()

  # Call the helper function
  file_ids <- handle_plot_attachments(
    plots = plot,
    plot_name = "mtcars_plot.png",
    channel_id = "channel_123",
    comment = "Here is a plot",
    auth = mock_auth,
    verbose = FALSE
  )

  # Verify the returned file_ids
  expect_equal(file_ids, list("file_plot123"))
})

test_that("handle_plot_attachments() successfully processes multiple plots with generated names", {

  # Mock the upload_files function to return mock file IDs
  mockery::stub(handle_plot_attachments, 'upload_files', function(file_paths, channel_id, comment, auth, verbose) {
    # Verify that the files exist
    expect_true(all(file.exists(file_paths)))
    # Verify that the files have .png extensions
    expect_true(all(grepl("\\.png$", file_paths)))
    return(list("file_plot123", "file_plot456", "file_plot789"))
  })

  # Mock the save_plot function to create dummy files
  mockery::stub(handle_plot_attachments, 'save_plot', function(plot, file_path) {
    # Create a dummy file to simulate a saved plot
    writeLines("dummy plot content", con = file_path)
    return(file_path)
  })

  # Define multiple plots
  plot1 <- ggplot2::ggplot(mtcars, ggplot2::aes(x = wt, y = mpg)) +
    ggplot2::geom_point()
  plot2 <- function() plot(cars)
  plot3 <- quote(plot(pressure))

  # Call the helper function with a single plot name (should generate numbered names)
  file_ids <- handle_plot_attachments(
    plots = list(plot1, plot2, plot3),
    plot_name = "test_plot",
    channel_id = "channel_123",
    comment = "Here are multiple plots",
    auth = mock_auth,
    verbose = FALSE
  )

  # Verify the returned file_ids
  expect_equal(file_ids, list("file_plot123", "file_plot456", "file_plot789"))
})

test_that("handle_plot_attachments() throws an error when plot_name length does not match plots length", {

  # Define multiple plots
  plot1 <- ggplot2::ggplot(mtcars, ggplot2::aes(x = wt, y = mpg)) +
    ggplot2::geom_point()
  plot2 <- ggplot2::ggplot(mtcars, ggplot2::aes(x = hp, y = mpg)) +
    ggplot2::geom_point()

  # Expect an error due to mismatched plot_name length
  expect_error(
    handle_plot_attachments(
      plots = list(plot1, plot2),
      plot_name = c("plot1.png", "plot2.png", "plot3.png"),  # 3 names for 2 plots
      channel_id = "channel_123",
      comment = "Mismatched plots and names",
      auth = mock_auth,
      verbose = FALSE
    ),
    "The length of 'plot_name' \\(3\\) does not match the number of plots \\(2\\)."
  )
})

test_that("handle_plot_attachments() appends .png extension to plot names without extension", {

  # Mock the upload_files function to return a mock file ID
  mockery::stub(handle_plot_attachments, 'upload_files', function(file_paths, channel_id, comment, auth, verbose) {
    # Verify that the files have .png extensions
    expect_true(all(grepl("\\.png$", file_paths)))
    return(list("file_plot123"))
  })

  # Mock the save_plot function to create a dummy file
  mockery::stub(handle_plot_attachments, 'save_plot', function(plot, file_path) {
    # Create a dummy file to simulate a saved plot
    writeLines("dummy plot content", con = file_path)
    return(file_path)
  })

  # Define a ggplot object
  plot <- ggplot2::ggplot(mtcars, ggplot2::aes(x = wt, y = mpg)) +
    ggplot2::geom_point()

  # Call the helper function with a plot name without extension
  file_ids <- handle_plot_attachments(
    plots = plot,
    plot_name = "mtcars_plot",  # No extension
    channel_id = "channel_123",
    comment = "Plot without extension",
    auth = mock_auth,
    verbose = FALSE
  )

  # Verify the returned file_ids
  expect_equal(file_ids, list("file_plot123"))
})

test_that("handle_plot_attachments() enforces maximum attachment limit", {

  # Define multiple plots (6 plots to exceed the limit of 5)
  plots <- replicate(6, ggplot2::ggplot(mtcars, ggplot2::aes(x = wt, y = mpg)) +
                       ggplot2::geom_point(), simplify = FALSE)
  plot_names <- paste0("plot", 1:6, ".png")

  # Expect an error when exceeding the maximum number of attachments
  expect_error(
    handle_plot_attachments(
      plots = plots,
      plot_name = plot_names,
      channel_id = "channel_123",
      comment = "Too many plots",
      auth = mock_auth,
      verbose = FALSE
    ),
    "A maximum of 5 plots can be attached to a message."
  )
})


test_that("handle_plot_attachments() appends .png extension to plot names without extension", {

  # Step 1: Initialize a vector to capture file paths passed to upload_files
  captured_file_paths <- NULL

  # Step 2: Mock 'upload_files' to capture the file_paths argument
  mock_upload_files <- function(file_paths, channel_id, comment, auth, verbose) {
    # Capture the file_paths for verification
    captured_file_paths <<- file_paths
    # Return a mock file ID
    return(list("file_plot123"))
  }
  mockery::stub(handle_plot_attachments, 'upload_files', mock_upload_files)

  # Step 3: Define a ggplot object
  plot <- ggplot2::ggplot(mtcars, ggplot2::aes(x = wt, y = mpg)) +
    ggplot2::geom_point()

  # Step 4: Call the helper function with a plot name without extension
  file_ids <- handle_plot_attachments(
    plots = plot,
    plot_name = "mtcars_plot",  # No extension
    channel_id = "channel_123",
    comment = "Plot without extension",
    auth = mock_auth,
    verbose = FALSE
  )

  # Step 5: Verify the returned file_ids
  expect_equal(file_ids, list("file_plot123"))

  # Step 6: Verify that the captured_file_paths have '.png' extension
  expect_true(all(grepl("\\.png$", captured_file_paths)))

})


test_that("upload_files throws an error for unexpected file response format", {
  # Mock 'send_mattermost_file' to simulate a malformed response
  mock_send_mattermost_file <- function(channel_id, file_path, comment, auth, verbose) {
    print("Mock send_mattermost_file called")
    # Return a malformed response lacking 'file_infos'
    return(list())
  }

  # Stub 'send_mattermost_file' to use the mock
  stub(upload_files, "send_mattermost_file", mock_send_mattermost_file)

  # Create a temporary file to simulate an attachment
  temp_file <- tempfile(fileext = ".txt")
  writeLines("Test content", temp_file)

  # Expect an error when calling 'upload_files' with the mocked behavior
  expect_error(
    upload_files(
      file_paths = temp_file,
      channel_id = "123",
      comment = "Test comment",
      auth = mock_auth,  # Ensure `mock_auth` is valid
      verbose = FALSE
    ),
    "Unexpected format in file response. Unable to extract file ID."
  )

  # Clean up the temporary file
  unlink(temp_file)
})


