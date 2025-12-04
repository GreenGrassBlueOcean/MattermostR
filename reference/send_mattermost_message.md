# Send a Message to a Mattermost Channel with Optional Attachments

This function sends a text message to a specified Mattermost channel,
optionally including one or more attachment files and plots.

## Usage

``` r
send_mattermost_message(
  channel_id,
  message,
  priority = "Normal",
  file_path = NULL,
  comment = NULL,
  plots = NULL,
  plot_name = NULL,
  verbose = FALSE,
  auth = authenticate_mattermost()
)
```

## Arguments

- channel_id:

  The ID of the Mattermost channel where the message will be sent. Must
  be a non-empty string.

- message:

  The content of the message to be sent. Must be a non-empty string.

- priority:

  A string specifying the priority of the message. Must be one of: -
  "Normal" (default) - "High" - "Low"

- file_path:

  A vector of file paths to be sent as attachments. Each path must point
  to an existing file.

- comment:

  A comment to accompany the attachment files. Useful for providing
  context or instructions.

- plots:

  A list of plot objects to attach to the message. Each plot can be: - A
  \`ggplot2\` object. - An R expression (e.g., \`quote(plot(cars))\`).
  Make sure to always wrap your expresion using the \`quote()\`
  function. - A function that generates a plot (e.g., \`function()
  plot(cars)\`).

- plot_name:

  A vector of names for the plot files. Extensions are optional;
  \`.png\` will be appended if missing. If multiple plots are provided
  with a single name, numbered names will be generated automatically.

- verbose:

  Boolean. If \`TRUE\`, the function will print detailed request and
  response information for debugging purposes.

- auth:

  The authentication object created by \`authenticate_mattermost()\`.
  Must be a valid \`mattermost_auth\` object.

## Value

A list containing the parsed response from the Mattermost server,
including details about the posted message and attachments.

## Details

\- The function enforces a maximum of 5 total attachments (files +
plots). Attempting to attach more will result in an error. - Plot
attachments are handled by the \`handle_plot_attachments\` helper
function, which processes and uploads plots, returning their respective
file IDs. - Priority levels can influence how messages are displayed or
handled within Mattermost, depending on server configurations.

## Examples

``` r
if (FALSE) { # \dontrun{
# Define channel ID and message
auth = authenticate_mattermost()
teams <- get_all_teams()
team_channels <- get_team_channels(team_id = teams$id[1])
channel_id <- get_channel_id_lookup(team_channels, "Off-Topic")

# Example 1: Send a simple message without attachments
response1 <- send_mattermost_message(
  channel_id = channel_id,
  message = "Hello, Mattermost!",
  auth = auth,
  verbose = TRUE
)
print(response1)

# Example 2: Send a message with a single file attachment
# Create a temporary text file
temp_file <- tempfile(fileext = ".txt")
writeLines("This is a sample file attachment.", con = temp_file)

response2 <- send_mattermost_message(
  channel_id = channel_id,
  message = "Here is a file for you.",
  file_path = temp_file,
  comment = "Please review the attached file.",
  auth = auth,
  verbose = TRUE
)
print(response2)

# Clean up temporary file
unlink(temp_file)

# Example 3: Send a message with multiple file attachments
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

response3 <- send_mattermost_message(
  channel_id = channel_id,
  message = "Please find the attached documents.",
  file_path = c(temp_file1, temp_file2),
  comment = "Attached: Report.pdf and Summary.docx.",
  priority = "High",
  auth = auth,
  verbose = TRUE
)
print(response3)

# Clean up temporary files
unlink(c(temp_file1, temp_file2))

# Example 4: Send a message with plot attachments
# Define plots
plot1 <- ggplot2::ggplot(mtcars, ggplot2::aes(x = wt, y = mpg)) +
  ggplot2::geom_point()
plot2 <- function() plot(cars)

# Call the function with plot attachments
response4 <- send_mattermost_message(
  channel_id = channel_id,
  message = "Check out these plots.",
  plots = list(plot1, plot2),
  plot_name = c("mtcars_plot.png", "cars_plot"),
  comment = "Attached: mtcars_plot and cars_plot.",
  auth = auth,
  verbose = TRUE
)
print(response4)

# Example 5: Send a message with both file and plot attachments
# Create a temporary file
temp_file3 <- tempfile(fileext = ".csv")
write.csv(mtcars, file = temp_file3, row.names = FALSE)

response5 <- send_mattermost_message(
  channel_id = channel_id,
  message = "Files and plots attached for your review.",
  file_path = temp_file3,
  plots = list(plot1, plot2),
  plot_name = c("mtcars_plot.png", "cars_plot"),
  comment = "Attached: mtcars_plot.png, cars_plot, and mtcars.csv.",
  priority = "Low",
  auth = auth,
  verbose = TRUE
)
print(response5)


# Example 6: Combine all plot possibilities and a file attachment
#Define additional plot using the `quote()` function.
plot3 <-  quote(plot(ggplot2::mpg))

# Attempt to send 4 attachments (1 file + 3 plots)
response6 <- send_mattermost_message(
    channel_id = channel_id,
    message = "All possible plot types.",
    file_path = temp_file3,
    plots = list(plot1, plot2, plot3),
    plot_name = c("plot1.png", "plot2.png", "plot3.png"),
    comment = "sending all kind possible of attachments",
    priority = "Normal",
    auth = auth,
    verbose = TRUE
  )

# Clean up temporary file
unlink(temp_file3)

} # }
```
