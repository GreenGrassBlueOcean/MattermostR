#' Send a Message via a Mattermost Incoming Webhook
#'
#' Posts a message to Mattermost using an incoming webhook URL. Incoming
#' webhooks are simpler than bot-token authentication — no \code{auth} object
#' is needed. The webhook URL itself acts as the credential.
#'
#' @param webhook_url The full incoming webhook URL (e.g.
#'   \code{"https://mattermost.example.com/hooks/xxx-generatedkey-xxx"}).
#'   Treat this as a secret.
#' @param text Markdown-formatted message text. Required unless
#'   \code{attachments} is provided.
#' @param channel Optional. Override the channel the message posts in. Use the
#'   channel's short name (e.g. \code{"town-square"}), not the display name.
#'   Use \code{"@username"} to send a direct message.
#' @param username Optional. Override the username the message posts as.
#'   Requires the server setting
#'   \emph{Enable integrations to override usernames} to be enabled.
#' @param icon_url Optional. Override the profile picture with an image URL.
#'   Requires the server setting
#'   \emph{Enable integrations to override profile picture icons} to be enabled.
#' @param icon_emoji Optional. Override the profile picture with an emoji
#'   (e.g. \code{":robot:"}). Takes precedence over \code{icon_url}.
#' @param attachments Optional. A list of
#'   \href{https://developers.mattermost.com/integrate/reference/message-attachments/}{message attachment}
#'   objects for richer formatting. Required if \code{text} is not provided.
#' @param props Optional. A named list of extra properties for the post.
#'   Supports the \code{card} key for additional Markdown shown in the
#'   right-hand side panel.
#' @param priority Optional. A list specifying message priority (e.g.
#'   \code{list(priority = "important")}).
#' @param timeout Numeric. Request timeout in seconds (default \code{10}).
#' @param max_tries Integer. Maximum number of retry attempts on transient
#'   HTTP failures (default \code{3}).
#'
#' @return The \code{httr2} response object, returned invisibly. A successful
#'   request returns HTTP 200 with body \code{"ok"}.
#'
#' @details
#' Incoming webhooks must be enabled on the Mattermost server
#' (\strong{System Console > Integrations > Integration Management}).
#' The webhook URL is created via
#' \strong{Product menu > Integrations > Incoming Webhook} in Mattermost.
#'
#' The request is retried up to \code{max_tries} times on transient failures.
#'
#' @export
#' @examples
#' \dontrun{
#' # Simple text message
#' send_webhook_message(
#'   webhook_url = "https://mattermost.example.com/hooks/xxx-generatedkey-xxx",
#'   text = "Hello from R!"
#' )
#'
#' # Override channel and username
#' send_webhook_message(
#'   webhook_url = "https://mattermost.example.com/hooks/xxx-generatedkey-xxx",
#'   text = "Build passed :white_check_mark:",
#'   channel = "ci-notifications",
#'   username = "CI Bot",
#'   icon_emoji = ":robot:"
#' )
#'
#' # Rich attachment without text
#' send_webhook_message(
#'   webhook_url = "https://mattermost.example.com/hooks/xxx-generatedkey-xxx",
#'   attachments = list(
#'     list(
#'       title = "Trade Alert",
#'       text = "AAPL filled at $185.50",
#'       color = "#00FF00"
#'     )
#'   )
#' )
#'
#' # Direct message via webhook
#' send_webhook_message(
#'   webhook_url = "https://mattermost.example.com/hooks/xxx-generatedkey-xxx",
#'   text = "Private notification for you.",
#'   channel = "@jsmith"
#' )
#' }
send_webhook_message <- function(webhook_url, text = NULL, channel = NULL,
                                 username = NULL, icon_url = NULL,
                                 icon_emoji = NULL, attachments = NULL,
                                 props = NULL, priority = NULL,
                                 timeout = 10, max_tries = 3) {

  # Validate required input

  check_not_null(webhook_url, "webhook_url")

  if (is.null(text) && is.null(attachments)) {
    stop("At least one of 'text' or 'attachments' must be provided.")
  }

  # Build body — only include non-NULL fields
  body <- list()
  if (!is.null(text))        body$text        <- text
  if (!is.null(channel))     body$channel     <- channel
  if (!is.null(username))    body$username    <- username
  if (!is.null(icon_url))    body$icon_url    <- icon_url
  if (!is.null(icon_emoji))  body$icon_emoji  <- icon_emoji
  if (!is.null(attachments)) body$attachments <- attachments
  if (!is.null(props))       body$props       <- props
  if (!is.null(priority))    body$priority    <- priority

  req <- httr2::request(webhook_url) |>
    httr2::req_body_json(body) |>
    httr2::req_method("POST")
  if (is.numeric(timeout) && length(timeout) == 1L && is.finite(timeout) && timeout > 0) {
    req <- httr2::req_timeout(req, timeout)
  }
  if (is.numeric(max_tries) && length(max_tries) == 1L && is.finite(max_tries) && max_tries >= 1) {
    req <- httr2::req_retry(req, max_tries = as.integer(max_tries))
  }
  resp <- req |>
    httr2::req_error(is_error = function(resp) FALSE) |>
    httr2::req_perform()

  status <- httr2::resp_status(resp)
  if (status >= 400) {
    body_text <- httr2::resp_body_string(resp)
    stop(sprintf("Webhook request failed with HTTP %d: %s", status, body_text))
  }

  invisible(resp)
}

#' Send a Message via a Mattermost Incoming Webhook (Alias)
#'
#' Alias for \code{\link{send_webhook_message}} providing a consistent
#' \code{mm_*} prefix alongside \code{\link{mm_get_channel_posts}}.
#'
#' @inheritParams send_webhook_message
#' @return The \code{httr2} response object, returned invisibly.
#' @export
#' @examples
#' \dontrun{
#' mm_send_webhook(
#'   webhook_url = "https://mattermost.example.com/hooks/xxx-generatedkey-xxx",
#'   text = "Hello from MattermostR!"
#' )
#' }
mm_send_webhook <- send_webhook_message

