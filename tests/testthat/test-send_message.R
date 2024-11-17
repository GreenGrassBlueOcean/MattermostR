# File: tests/testthat/test-send_message.R

library(testthat)
library(mockery)
library(ggplot2)
library(officer)

# Define a mock 'mattermost_auth' object
 mock_auth <- structure(
   list(
     token = "mock_token",
     url = "https://mock.mattermost.com"  # Use a valid URL format
   ),
   class = "mattermost_auth"
 )

# Test suite for send_mattermost_message
test_that("send_mattermost_message() handles authentication correctly", {
  # Test with NULL auth
  expect_error(
    send_mattermost_message(channel_id = "123", message = "Hello", auth = NULL),
    "The provided object is not a valid 'mattermost_auth' object."
  )

  # Test with invalid auth (not of class 'mattermost_auth')
  invalid_auth <- list(token = "invalid", url = "https://invalid.url")
  expect_error(
    send_mattermost_message(channel_id = "123", message = "Hello", auth = invalid_auth),
    "The provided object is not a valid 'mattermost_auth' object."
  )
})

test_that("send_mattermost_message() successfully sends a message without attachments", {
  # Mock 'check_mattermost_auth' to do nothing
  stub(send_mattermost_message, "check_mattermost_auth", function(auth) {})

  # Mock 'upload_files' and 'handle_plot_attachments' to return empty lists
  stub(send_mattermost_message, "upload_files", function(...) list())
  stub(send_mattermost_message, "handle_plot_attachments", function(...) list())

  # Mock 'mattermost_api_request' to return a successful response
  mock_response <- list(status = "OK", id = "post123")
  stub(send_mattermost_message, "mattermost_api_request", function(auth, endpoint, method, body, verbose) {
    # Verify that file_ids are empty
    expect_null(body$file_ids)
    return(mock_response)
  })

  # Call the function
  result <- send_mattermost_message(
    channel_id = "123",
    message = "Hello",
    auth = mock_auth,
    verbose = FALSE
  )

  # Verify the response
  expect_equal(result, mock_response)
})

test_that("send_mattermost_message() throws error when channel_id is NULL", {
  expect_error(
    send_mattermost_message(channel_id = NULL, message = "Hello", auth = mock_auth),
    "channel_id cannot be empty or NULL"
  )
})

test_that("send_mattermost_message() throws error when message is NULL", {
  expect_error(
    send_mattermost_message(channel_id = "123", message = NULL, auth = mock_auth),
    "message cannot be empty or NULL"
  )
})

test_that("send_mattermost_message() throws error for invalid priority", {
  expect_error(
    send_mattermost_message(channel_id = "123", message = "Hello", priority = "invalid", auth = mock_auth),
    "Invalid priority: 'invalid'. Must be one of: Normal, High, Low"
  )
})

test_that("send_mattermost_message() correctly normalizes priority inputs", {
  expect_equal(normalize_priority("normal"), "Normal")
  expect_equal(normalize_priority("HIGH"), "High")
  expect_equal(normalize_priority("lOw"), "Low")
})

test_that("normalize_priority() throws error for invalid priority inputs", {
  expect_error(
    normalize_priority("invalid"),
    "Invalid priority: 'invalid'. Must be one of: Normal, High, Low"
  )
})

test_that("send_mattermost_message() successfully sends a message with a single file attachment", {
  # Create a temporary file
  temp_file <- tempfile(fileext = ".txt")
  writeLines("This is a test file for Mattermost upload", temp_file)

  # Mock 'check_mattermost_auth' to do nothing
  stub(send_mattermost_message, "check_mattermost_auth", function(auth) {})

  # Mock 'upload_files' to return a list of file IDs
  mock_upload_files <- function(file_paths, channel_id, comment, auth, verbose) {
    return(list("file_mock_id"))
  }
  stub(send_mattermost_message, "upload_files", mock_upload_files)

  # Mock 'handle_plot_attachments' to return an empty list
  stub(send_mattermost_message, "handle_plot_attachments", function(...) list())

  # Mock 'mattermost_api_request' to return a successful response
  mock_response <- list(status = "OK", id = "post123")
  stub(send_mattermost_message, "mattermost_api_request", function(auth, endpoint, method, body, verbose) {
    # Verify the file_ids in the body
    expect_equal(body$file_ids, list("file_mock_id"))
    return(mock_response)
  })

  # Call the function
  result <- send_mattermost_message(
    channel_id = "123",
    message = "Hello with file",
    file_path = temp_file,
    comment = "Please review the attached file.",
    priority = "High",
    auth = mock_auth,
    verbose = FALSE
  )

  # Verify the response
  expect_equal(result, mock_response)

  # Clean up the temporary file
  unlink(temp_file)
})

test_that("send_mattermost_message() successfully sends a message with multiple file attachments", {
  # Create temporary files
  temp_file1 <- tempfile(fileext = ".pdf")
  temp_file2 <- tempfile(fileext = ".docx")

  # Create a ggplot and save it as a PDF
  plot_pdf <- ggplot2::ggplot(mtcars, ggplot2::aes(x = wt, y = mpg)) +
    ggplot2::geom_point()
  ggplot2::ggsave(filename = temp_file1, plot = plot_pdf)

  # Create a simple DOCX file using officer
  doc <- officer::read_docx() |>
    officer::body_add_par("This is a sample Word document.", style = "Normal")
  print(doc, target = temp_file2)

  # Mock 'check_mattermost_auth' to do nothing
  stub(send_mattermost_message, "check_mattermost_auth", function(auth) {})

  # Mock 'upload_files' to return a list of file IDs
  mock_upload_files <- function(file_paths, channel_id, comment, auth, verbose) {
    return(list("file_pdf_id", "file_docx_id"))
  }
  stub(send_mattermost_message, "upload_files", mock_upload_files)

  # Mock 'handle_plot_attachments' to return an empty list
  stub(send_mattermost_message, "handle_plot_attachments", function(...) list())

  # Mock 'mattermost_api_request' to return a successful response
  mock_response <- list(status = "OK", id = "post123")
  stub(send_mattermost_message, "mattermost_api_request", function(auth, endpoint, method, body, verbose) {
    # Verify the file_ids in the body
    expect_equal(body$file_ids, list("file_pdf_id", "file_docx_id"))
    return(mock_response)
  })

  # Call the function
  result <- send_mattermost_message(
    channel_id = "123",
    message = "Hello with multiple files",
    file_path = c(temp_file1, temp_file2),
    comment = "Please review the attached files.",
    priority = "High",
    auth = mock_auth,
    verbose = FALSE
  )

  # Verify the response
  expect_equal(result, mock_response)

  # Clean up the temporary files
  unlink(c(temp_file1, temp_file2))
})

test_that("send_mattermost_message() successfully sends a message with verbose enabled", {
  # Create a temporary file
  temp_file <- tempfile(fileext = ".txt")
  writeLines("This is a test file for Mattermost upload", temp_file)

  # Mock 'check_mattermost_auth' to do nothing
  stub(send_mattermost_message, "check_mattermost_auth", function(auth) {})

  # Mock 'upload_files' to return a list of file IDs
  mock_upload_files <- function(file_paths, channel_id, comment, auth, verbose) {
    return(list("file_mock_id"))
  }
  stub(send_mattermost_message, "upload_files", mock_upload_files)

  # Mock 'handle_plot_attachments' to return an empty list
  stub(send_mattermost_message, "handle_plot_attachments", function(...) list())

  # Mock 'mattermost_api_request' to return a successful response
  mock_response <- list(status = "OK", id = "post123")
  stub(send_mattermost_message, "mattermost_api_request", function(auth, endpoint, method, body, verbose) {
    return(mock_response)
  })

  # Capture the verbose output
  expect_output(
    result <- send_mattermost_message(
      channel_id = "123",
      message = "Hello with verbose",
      file_path = temp_file,
      comment = "Please review the attached file.",
      priority = "High",
      auth = mock_auth,
      verbose = TRUE
    ),
    "Request Body:"
  )

  # Verify the response
  expect_equal(result, mock_response)

  # Clean up the temporary file
  unlink(temp_file)
})

test_that("send_mattermost_message() correctly handles priority settings", {
  # Mock 'check_mattermost_auth' to do nothing
  stub(send_mattermost_message, "check_mattermost_auth", function(auth) {})

  # Mock 'upload_files' and 'handle_plot_attachments' to return empty lists
  stub(send_mattermost_message, "upload_files", function(...) list())
  stub(send_mattermost_message, "handle_plot_attachments", function(...) list())

  # Mock 'mattermost_api_request' to return a successful response
  mock_response <- list(status = "OK", id = "post123")
  stub(send_mattermost_message, "mattermost_api_request", function(auth, endpoint, method, body, verbose) {
    if (body$message == "Priority High") {
      expect_equal(body$props$priority$priority, "important")
    } else if (body$message == "Priority Normal") {
      expect_null(body$props)
    } else if (body$message == "Priority Low") {
      expect_equal(body$props$priority$priority, "minor")
    }
    return(mock_response)
  })

  # Test case: Priority High
  result_high <- send_mattermost_message(
    channel_id = "123",
    message = "Priority High",
    priority = "High",
    auth = mock_auth,
    verbose = FALSE
  )
  expect_equal(result_high, mock_response)

  # Test case: Priority Normal
  result_normal <- send_mattermost_message(
    channel_id = "123",
    message = "Priority Normal",
    priority = "Normal",
    auth = mock_auth,
    verbose = FALSE
  )
  expect_equal(result_normal, mock_response)

  # Test case: Priority Low
  result_low <- send_mattermost_message(
    channel_id = "123",
    message = "Priority Low",
    priority = "Low",
    auth = mock_auth,
    verbose = FALSE
  )
  expect_equal(result_low, mock_response)
})

test_that("send_mattermost_message() throws an error when more than 5 attachments are provided", {
  # Create 6 temporary files
  tmp_files <- replicate(6, tempfile(fileext = ".txt"), simplify = FALSE)

  # Write some content to each temporary file
  lapply(tmp_files, function(f) writeLines("Test content", f))

  # Mock 'check_mattermost_auth' to do nothing
  stub(send_mattermost_message, "check_mattermost_auth", function(auth) {})

  # Mock 'upload_files' to return a list of file IDs
  mock_upload_files <- function(file_paths, channel_id, comment, auth, verbose) {
    return(lapply(file_paths, function(x) paste0("file_", tools::file_path_sans_ext(basename(x)))))
  }
  stub(send_mattermost_message, "upload_files", mock_upload_files)

  # Mock 'handle_plot_attachments' to return empty list
  stub(send_mattermost_message, "handle_plot_attachments", function(...) list())

  # Define a mock response (won't be used as function should error before)
  mock_response <- list(status = "OK", id = "post123")

  # Mock 'mattermost_api_request' (should not be called)
  stub(send_mattermost_message, "mattermost_api_request", function(...) mock_response)

  # Expect an error when attaching more than 5 files
  expect_error(
    send_mattermost_message(
      channel_id = "123",
      message = "Too many attachments.",
      file_path = tmp_files,
      comment = "This should fail due to exceeding attachment limits.",
      priority = "Normal",
      auth = mock_auth,
      verbose = FALSE
    ),
    "A maximum of 5 files can be attached to a message."
  )

  # Clean up temporary files
  unlink(tmp_files)
})

test_that("send_mattermost_message() throws an error when file_path is provided but empty", {
  # Define required parameters
  channel_id <- "channel_123"
  message <- "Test message with empty file_path"

  # Set file_path to an empty character vector
  file_path <- character(0)

  # Expect an error when file_path is empty
  expect_error(
    send_mattermost_message(
      channel_id = channel_id,
      message = message,
      file_path = file_path,
      comment = "This is a test comment",
      verbose = FALSE,
      auth = mock_auth
    ),
    "The 'file_path' parameter must contain at least one valid file path."
  )
})

test_that("send_mattermost_message() throws an error when file_path contains a non-existent file", {
  # Define required parameters
  channel_id <- "channel_123"
  message <- "Test message with a non-existent file"

  # Set file_path to a non-existent file
  file_path <- "non_existent_file.txt"

  # Expect an error when file_path does not exist
  expect_error(
    send_mattermost_message(
      channel_id = channel_id,
      message = message,
      file_path = file_path,
      comment = "This file does not exist",
      verbose = FALSE,
      auth = mock_auth
    ),
    sprintf("The file specified by 'file_path' does not exist: %s", file_path)
  )
})

test_that("send_mattermost_message() successfully sends a message with diverse plot types and a file attachment", {
  # Create a temporary file
  temp_file <- tempfile(fileext = ".txt")
  writeLines("This is a test file for Mattermost upload", temp_file)

  # Define plots
  plot1 <- ggplot2::ggplot(mtcars, ggplot2::aes(x = wt, y = mpg)) +
    ggplot2::geom_point()
  plot2 <- function() plot(cars)
  plot3 <- quote(plot(mpg))

  # Define mock functions
  mock_upload_files <- function(file_paths, channel_id, comment, auth, verbose) {
    return(list("file_mock_id"))
  }

  mock_handle_plot_attachments <- function(plots, plot_name, channel_id, comment, auth, verbose) {
    return(list("plot1_mock_id", "plot2_mock_id", "plot3_mock_id"))
  }

  # Define mock response
  mock_response <- list(status = "OK", id = "post123")

  # Stub the helper functions within the correct environment
  stub(send_mattermost_message, "check_mattermost_auth", function(auth) {})
  stub(send_mattermost_message, "upload_files", mock_upload_files)
  stub(send_mattermost_message, "handle_plot_attachments", mock_handle_plot_attachments)
  stub(send_mattermost_message, "mattermost_api_request", function(auth, endpoint, method, body, verbose) {
    # Verify the file_ids and plot_ids in the body
    expect_equal(body$file_ids, list("file_mock_id", "plot1_mock_id", "plot2_mock_id", "plot3_mock_id"))
    return(mock_response)
  })

  # Call the function
  result <- send_mattermost_message(
    channel_id = "123",
    message = "All possible plot types.",
    file_path = temp_file,
    plots = list(plot1, plot2, plot3),
    plot_name = c("plot1.png", "plot2.png", "plot3.png"),
    comment = "sending all kind possible of attachments",
    priority = "Normal",
    auth = mock_auth,
    verbose = FALSE
  )

  # Verify the response
  expect_equal(result, mock_response)

  # Clean up the temporary file
  unlink(temp_file)
})


test_that("send_mattermost_message() throws an error for unexpected file response format", {
  # Step 1: Create a temporary file
  temp_file <- tempfile(fileext = ".txt")
  writeLines("Test content", temp_file)

  # Step 2: Mock 'check_mattermost_auth' to simulate successful auth
  stub(send_mattermost_message, "check_mattermost_auth", function(auth) {
    print("Mock check_mattermost_auth called")
  })

  # Step 3: Mock 'upload_files' to simulate an unexpected file response
  stub(send_mattermost_message, "upload_files", function(file_paths, channel_id, comment, auth, verbose) {
    print("Mock upload_files called with:")
    print(list(file_paths = file_paths, channel_id = channel_id, comment = comment))
    return(NULL)  # Simulate unexpected response format
  })

  # Step 4: Mock 'handle_plot_attachments' to return an empty list
  stub(send_mattermost_message, "handle_plot_attachments", function(...) {
    print("Mock handle_plot_attachments called")
    list()
  })

  # Step 5: Mock 'mattermost_api_request' to prevent any actual API calls
  stub(send_mattermost_message, "mattermost_api_request", function(auth, endpoint, method, body, verbose) {
    print("mattermost_api_request should NOT be called")
    stop("This should not be called during this test.")
  })

  # Debugging: Print the start of the test
  print("Starting test for unexpected file response format")

  # Step 6: Expect the specific error message when `upload_files` returns an unexpected response
  expect_error(
    send_mattermost_message(
      channel_id = "123",
      message = "Test message with invalid file response",
      file_path = temp_file,
      comment = "This file response is invalid",
      priority = "Normal",
      auth = mock_auth,  # Ensure `mock_auth` is valid
      verbose = TRUE
    ),
    "Unexpected format in file response. Unable to extract file ID."
  )

  # Step 7: Debugging: Print test end
  print("Test complete: Unexpected file response format")

  # Step 8: Clean up the temporary file
  unlink(temp_file)
})


test_that("send_mattermost_message() defaults priority to 'Normal' when priority is NULL", {
  # Step 1: Create a temporary file
  temp_file <- tempfile(fileext = ".txt")
  writeLines("This is a test file for Mattermost upload", temp_file)

  # Step 2: Mock 'check_mattermost_auth' to do nothing
  stub(send_mattermost_message, "check_mattermost_auth", function(auth) {
    print("Mock check_mattermost_auth called")
  })

  # Step 3: Mock 'upload_files' to return a list of file IDs
  mock_upload_files <- function(file_paths, channel_id, comment, auth, verbose) {
    print("Mock upload_files called")
    return(list("file_mock_id"))
  }
  stub(send_mattermost_message, "upload_files", mock_upload_files)

  # Step 4: Mock 'handle_plot_attachments' to return an empty list
  stub(send_mattermost_message, "handle_plot_attachments", function(...) {
    print("Mock handle_plot_attachments called")
    list()
  })

  # Step 5: Mock 'mattermost_api_request' to verify 'props' is not included
  mock_response <- list(status = "OK", id = "post123")
  stub(send_mattermost_message, "mattermost_api_request", function(auth, endpoint, method, body, verbose) {
    # Verify that 'props' is not present in the body
    expect_null(body$props)
    # Verify that 'file_ids' contains the mocked file ID
    expect_equal(body$file_ids, list("file_mock_id"))
    return(mock_response)
  })

  # Step 6: Call the function with priority = NULL
  result <- send_mattermost_message(
    channel_id = "123",
    message = "Hello with default priority",
    file_path = temp_file,
    comment = "Please review the attached file.",
    priority = NULL,  # Set priority to NULL
    auth = mock_auth,
    verbose = FALSE
  )

  # Step 7: Verify the response
  expect_equal(result, mock_response)

  # Step 8: Clean up the temporary file
  unlink(temp_file)
})

