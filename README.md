
<!-- README.md is generated from README.Rmd. Please edit that file -->

# MattermostR <a href="https://github.com/GreenGrassBlueOcean/MattermostR"><img src="man/figures/MattermostR_hex.png" alt="MattermostR website" align="right" height="138"/></a>

<!-- badges: start -->

[![R-CMD-check.yaml](https://github.com/GreenGrassBlueOcean/MattermostR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/GreenGrassBlueOcean/MattermostR/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/GreenGrassBlueOcean/MattermostR/graph/badge.svg)](https://app.codecov.io/gh/GreenGrassBlueOcean/MattermostR)

<!-- badges: end -->

# MattermostR

MattermostR is an R package designed to interact with the Mattermost API
for sending messages, managing channels, uploading files, and more. The
package includes functionality for automating interactions with
Mattermost from R scripts, allowing you to easily send messages, upload
attachments, and manage teams and channels.

## Installation

You can install the MattermostR package from GitHub:

``` r
# Install the devtools package if you don't have it already
install.packages("devtools")

# Install MattermostR
devtools::install_github("GreenGrassBlueOcean/MattermostR")
```

## Features

### 1. Send Messages with Priority

Send messages to Mattermost channels with optional priorities: -
**Normal** - **High** - **Low**

The priority is automatically normalized in the
`send_mattermost_message()` function, so you don’t need to worry about
case sensitivity (e.g., `high`, `HIGH`, and `High` are all valid).

### 2. Attach Files to Messages

You can attach files to your messages by specifying a file path. The
file is first uploaded to the Mattermost server, and its file ID is
included in the message.

Example:

``` r
response <- send_mattermost_message(
  channel_id = channel_id, 
  message = "Here is your file!", 
  file_path = "output.txt", 
  verbose = TRUE
)
```

### 3. Send Plots as Attachments

You can now directly send plots as attachments to your Mattermost
messages. Supported plot types include:

- ggplot2 objects
- R expressions (e.g., quote(plot(cars)))
- Functions that generate plots (e.g., function() plot(cars))

The plots are automatically saved as .png files and uploaded to the
Mattermost server.

Example:

``` r
# Define some plots
library(ggplot2)

plot1 <- ggplot(mtcars, aes(x = wt, y = mpg)) +
  geom_point()

plot2 <- function() plot(cars)

# Send a message with plot attachments
response <- send_mattermost_message(
  channel_id = channel_id,
  message = "Here are some plots!",
  plots = list(plot1, plot2),
  plot_name = c("scatterplot.png", "lineplot"),
  verbose = TRUE,
  auth = auth
)
```

### 4. Manage Teams and Channels

The package provides tools for managing channels and teams:

1.List Channels and Groups: Retrieve all channels and groups from a
team.  
2.Create Channels: Programmatically create new channels in a team.  
3.Delete Channels: Delete existing channels.  
4.Look Up Channels by Name: Find a specific channel by name and get its
ID.

### 5. Search Posts

Robust search functionality allows you to query message history. This
includes:

1.Filtering by Team, Channel, or User.  
2.Date range filtering (before/after).  
3.Handling pagination and integer overflow for large datasets.

Note: The API usually requires the bot/user to be a member of the
channel to search it.

``` r
# 1. Authenticate
auth <- authenticate_mattermost(
  base_url = "https://yourmattermost.stackhero-network.com", 
  token = "your-token"
)

# 2. Get your user ID (for joining channels) and Team ID
me <- get_user_info("me", auth = auth)
teams <- get_all_teams(auth = auth)
team_id <- teams$id[1] # Select the first team

# 3. Find a channel and ensure the bot is a member
# (Search often fails if the bot hasn't explicitly joined the channel)
channels <- get_team_channels(team_id = team_id, auth = auth)
channel_id <- get_channel_id_lookup(channels, name = "town-square")

add_user_to_channel(channel_id, me$id, auth = auth)

# 4. Perform the Search
results <- search_posts(
  terms = "important update",
  team_id = team_id,
  in_channels = channel_id,
  after_date = "2024-01-01",
  per_page = 100,
  verbose = TRUE,
  auth = auth
)

# View results
head(results)
```

### 6. Authentication

Authenticate with the Mattermost API using a bearer token or by
providing your username and password. Once authenticated, the token is
stored for future API calls.

``` r
auth <- authenticate_mattermost(
  base_url = "https://yourmattermost.stackhero-network.com", 
  token = "your-token"
)
```

### 7. Error Handling and Validation

Priority Validation: Before sending a message, the priority is validated
to ensure that it’s one of Normal, High, or Low. If an invalid priority
is provided, the function will return an error. Input Validation:
Ensures that required fields (such as channel_id and message) are
provided before making API calls.

## Usage

### Sending a Message

``` r
# Authenticate
auth <- authenticate_mattermost(base_url = "https://yourmattermost.stackhero-network.com", token = "your-token")

# Send a message to a channel
response <- send_mattermost_message(
  channel_id = "your-channel-id", 
  message = "Hello, Mattermost!", 
  priority = "High", 
  verbose = TRUE
)
```

### Sending a Message with a File

``` r
# Send a message with a file attachment
response <- send_mattermost_message(
  channel_id = "your-channel-id", 
  message = "Here is a file attachment", 
  file_path = "path/to/file.txt", 
  verbose = TRUE
)
```

### Managing Channels

``` r
# List all channels in a team
channels <- get_team_channels(team_id = "your-team-id")

# Create a new channel
create_mattermost_channel(team_id = "your-team-id", channel_name = "new-channel", channel_display_name = "New Channel")

# Delete a channel
delete_mattermost_channel(channel_id = "your-channel-id")
```

## License

This project is licensed under the MIT License.
