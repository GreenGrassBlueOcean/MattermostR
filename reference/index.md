# Package index

## Authentication

Authenticate with the Mattermost API and manage credentials.

- [`authenticate_mattermost()`](https://greengrassblueocean.github.io/MattermostR/reference/authenticate_mattermost.md)
  : Authenticate with Mattermost API
- [`clear_mattermost_credentials()`](https://greengrassblueocean.github.io/MattermostR/reference/clear_mattermost_credentials.md)
  : Clear cached Mattermost credentials from R options
- [`print(`*`<mattermost_auth>`*`)`](https://greengrassblueocean.github.io/MattermostR/reference/print.mattermost_auth.md)
  : Print a mattermost_auth object
- [`check_mattermost_auth()`](https://greengrassblueocean.github.io/MattermostR/reference/check_mattermost_auth.md)
  : Check if the object is a valid mattermost_auth object

## Messaging

Send, edit, and delete messages. Includes webhook and thread support.

- [`send_mattermost_message()`](https://greengrassblueocean.github.io/MattermostR/reference/send_mattermost_message.md)
  : Send a Message to a Mattermost Channel with Optional Attachments
- [`send_webhook_message()`](https://greengrassblueocean.github.io/MattermostR/reference/send_webhook_message.md)
  : Send a Message via a Mattermost Incoming Webhook
- [`update_post()`](https://greengrassblueocean.github.io/MattermostR/reference/update_post.md)
  : Update (Patch) an Existing Mattermost Post
- [`delete_post()`](https://greengrassblueocean.github.io/MattermostR/reference/delete_post.md)
  : Delete a specific post in Mattermost
- [`delete_old_messages()`](https://greengrassblueocean.github.io/MattermostR/reference/delete_old_messages.md)
  : Delete Messages Older Than X Days in a Mattermost Channel

## Posts & Search

Retrieve and search posts in channels.

- [`get_channel_posts()`](https://greengrassblueocean.github.io/MattermostR/reference/get_channel_posts.md)
  : Get posts from a Mattermost channel
- [`search_posts()`](https://greengrassblueocean.github.io/MattermostR/reference/search_posts.md)
  : Search for posts in Mattermost

## Reactions & Pins

Add emoji reactions and pin posts.

- [`add_reaction()`](https://greengrassblueocean.github.io/MattermostR/reference/add_reaction.md)
  : Add a Reaction to a Mattermost Post
- [`get_reactions()`](https://greengrassblueocean.github.io/MattermostR/reference/get_reactions.md)
  : Get All Reactions on a Mattermost Post
- [`remove_reaction()`](https://greengrassblueocean.github.io/MattermostR/reference/remove_reaction.md)
  : Remove a Reaction from a Mattermost Post
- [`pin_post()`](https://greengrassblueocean.github.io/MattermostR/reference/pin_post.md)
  : Pin a post to its channel
- [`unpin_post()`](https://greengrassblueocean.github.io/MattermostR/reference/unpin_post.md)
  : Unpin a post from its channel

## Channels

Create, manage, and query channels and their members.

- [`create_channel()`](https://greengrassblueocean.github.io/MattermostR/reference/create_channel.md)
  : Create a new Mattermost channel
- [`create_direct_channel()`](https://greengrassblueocean.github.io/MattermostR/reference/create_direct_channel.md)
  : Create a Direct Message or Group Message Channel
- [`delete_channel()`](https://greengrassblueocean.github.io/MattermostR/reference/delete_channel.md)
  : Delete a Mattermost channel
- [`get_channel_info()`](https://greengrassblueocean.github.io/MattermostR/reference/get_channel_info.md)
  : Get information about a Mattermost channel
- [`get_channel_id_lookup()`](https://greengrassblueocean.github.io/MattermostR/reference/get_channel_id_lookup.md)
  : Get Channel ID by Display Name or Name
- [`get_team_channels()`](https://greengrassblueocean.github.io/MattermostR/reference/get_team_channels.md)
  : Get the list of channels for a team
- [`get_channel_members()`](https://greengrassblueocean.github.io/MattermostR/reference/get_channel_members.md)
  : Get members of a channel
- [`add_user_to_channel()`](https://greengrassblueocean.github.io/MattermostR/reference/add_user_to_channel.md)
  : Add a user to a channel
- [`add_users_to_channel()`](https://greengrassblueocean.github.io/MattermostR/reference/add_users_to_channel.md)
  : Add multiple users to a channel in a single API call
- [`remove_channel_member()`](https://greengrassblueocean.github.io/MattermostR/reference/remove_channel_member.md)
  : Remove a user from a channel

## Teams

List and retrieve teams.

- [`get_all_teams()`](https://greengrassblueocean.github.io/MattermostR/reference/get_all_teams.md)
  : List all teams in Mattermost
- [`get_team()`](https://greengrassblueocean.github.io/MattermostR/reference/get_team.md)
  : Get data of a single team from its team_id

## Users

Look up users and manage their status.

- [`get_me()`](https://greengrassblueocean.github.io/MattermostR/reference/get_me.md)
  : Get information about which user is belonging to bearer key,
- [`get_user()`](https://greengrassblueocean.github.io/MattermostR/reference/get_user.md)
  : Get information about a specific Mattermost user
- [`get_user_info()`](https://greengrassblueocean.github.io/MattermostR/reference/get_user_info.md)
  : Get information about a specific Mattermost user
- [`get_all_users()`](https://greengrassblueocean.github.io/MattermostR/reference/get_all_users.md)
  : Get all known Mattermost users
- [`get_user_status()`](https://greengrassblueocean.github.io/MattermostR/reference/get_user_status.md)
  : Get user online status
- [`set_user_status()`](https://greengrassblueocean.github.io/MattermostR/reference/set_user_status.md)
  : Set user online status

## Files

Upload and download files.

- [`get_mattermost_file()`](https://greengrassblueocean.github.io/MattermostR/reference/get_mattermost_file.md)
  : Retrieve a file from Mattermost

## Bots

Create and manage bot accounts.

- [`create_bot()`](https://greengrassblueocean.github.io/MattermostR/reference/create_bot.md)
  : Create a bot account
- [`get_bot()`](https://greengrassblueocean.github.io/MattermostR/reference/get_bot.md)
  : Get a bot account
- [`get_bots()`](https://greengrassblueocean.github.io/MattermostR/reference/get_bots.md)
  : List bot accounts
- [`update_bot()`](https://greengrassblueocean.github.io/MattermostR/reference/update_bot.md)
  : Update a bot account
- [`disable_bot()`](https://greengrassblueocean.github.io/MattermostR/reference/disable_bot.md)
  : Disable a bot account
- [`enable_bot()`](https://greengrassblueocean.github.io/MattermostR/reference/enable_bot.md)
  : Enable a bot account
- [`assign_bot()`](https://greengrassblueocean.github.io/MattermostR/reference/assign_bot.md)
  : Assign a bot to a different owner

## Slash Commands

Register and manage slash commands.

- [`create_command()`](https://greengrassblueocean.github.io/MattermostR/reference/create_command.md)
  : Create a slash command
- [`get_command()`](https://greengrassblueocean.github.io/MattermostR/reference/get_command.md)
  : Get a slash command
- [`list_commands()`](https://greengrassblueocean.github.io/MattermostR/reference/list_commands.md)
  : List slash commands for a team
- [`update_command()`](https://greengrassblueocean.github.io/MattermostR/reference/update_command.md)
  : Update a slash command
- [`delete_command()`](https://greengrassblueocean.github.io/MattermostR/reference/delete_command.md)
  : Delete a slash command
- [`execute_command()`](https://greengrassblueocean.github.io/MattermostR/reference/execute_command.md)
  : Execute a slash command
- [`regen_command_token()`](https://greengrassblueocean.github.io/MattermostR/reference/regen_command_token.md)
  : Regenerate a command token

## Low-level / Developer

Direct API access and server utilities.

- [`mattermost_api_request()`](https://greengrassblueocean.github.io/MattermostR/reference/mattermost_api_request.md)
  : Make a Mattermost API Request
- [`check_mattermost_status()`](https://greengrassblueocean.github.io/MattermostR/reference/check_mattermost_status.md)
  : Check if the Mattermost server is online
