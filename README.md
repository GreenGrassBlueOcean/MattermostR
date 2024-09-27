# MattermostR

MattermostR is an R package that simplifies interactions with the [Mattermost](https://mattermost.com/) platform through its REST API. The package allows you to send messages, upload files, and manage other Mattermost features from within R.

## Features

-   **Send Messages**: Send messages to specific Mattermost channels.
-   **File Uploads**: Upload files as attachments to messages.
-   **Message Priority**: Set message priority to Normal, High, or Low (depending on Mattermost server support).
-   **Easy Authentication**: Authenticate via a token to interact with the Mattermost API.

## Installation

To install MattermostR, you can clone this repository and install it using R's `devtools`:

``` r
# Install devtools if you don't have it
install.packages("devtools")

# Install MattermostR
devtools::install_github("your-username/MattermostR")
```

## Authentication

Before sending any messages or uploading files, you need to authenticate using your Mattermost API token.

``` r
# Authenticate with Mattermost using your API token
auth <- authenticate_mattermost(base_url = "https://your-mattermost-server.com", token = "your-api-token")
```

## Usage Sending a Message

You can send a message to a specific Mattermost channel using the send_mattermost_message function.

``` r
# Send a simple text message
response <- send_mattermost_message(
  channel_id = "your-channel-id", 
  message = "Hello, Mattermost!"
)
```

# Sending a Message with Priority

You can set the priority of the message (if supported by your Mattermost server) to one of the following values: "Normal", "High", or "Low". The function automatically normalizes the priority string to ensure proper casing.

``` r
# Send a message with High priority
response <- send_mattermost_message(
  channel_id = "your-channel-id", 
  message = "This is an important message!", 
  priority = "High"
)
```

```         
Note: There is no need to manually use the normalize_priority() function, as send_mattermost_message() already handles priority normalization automatically.
```

# Uploading a File with a Message

You can attach a file to your message by providing the file path.

``` r
# Create a sample text file
writeLines(c("Hello, world!"), "output.txt")

# Send the file with a message
response <- send_mattermost_message(
  channel_id = "your-channel-id", 
  message = "Here's an attached file!", 
  file_path = "output.txt"
)
```

# Normalizing and Validating Priority

Although normalize_priority() is handled automatically by send_mattermost_message(), you can still call it manually if needed. This function converts different casings of priority values ("low", "LOW", "Low") into their correct format ("Low", "Normal", "High") and validates them.

``` r
# Example usage of normalize_priority
normalize_priority("low")  # Returns "Low"
normalize_priority("HIGH")  # Returns "High"
normalize_priority("medium")  # Throws an error for invalid priority
```

# Handling Errors

The package includes basic error handling. For example, if you try to send a message with an invalid priority, you'll get an informative error message:

``` r
# Error handling for invalid priority
tryCatch(
  send_mattermost_message(channel_id = "your-channel-id", message = "Test", priority = "InvalidPriority"),
  error = function(e) {
    print(e$message)
  }
)
```

## Tests

The package includes unit tests written with testthat. You can run the tests using:

``` r
library(testthat)
test_dir("tests")
```

## Known Issues

```         
Priority Support: The priority field for messages may not be supported on all Mattermost servers. If the server doesn't support this feature, a HTTP 501 Not Implemented error will be raised. The function has been designed to bypass this field in such cases, but check with your server admin if you encounter issues.
```

## Future Enhancements

```         
Improve support for priority metadata by adding automatic checks for Mattermost server version compatibility.
Add more robust error handling for various API failures.
Implement threading support (root_id) for replies within conversations.
```

## Contributing

Contributions to improve MattermostR are welcome! Please open an issue or submit a pull request. How to Contribute

```         
Fork the repository.
Create a new branch with your changes.
Make sure all tests pass.
Submit a pull request.
```

## License

This project is licensed under the MIT License. See the LICENSE file for details.
