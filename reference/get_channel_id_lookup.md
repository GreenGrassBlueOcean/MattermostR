# Get Channel ID by Display Name or Name

This function retrieves the channel ID associated with a specified
display name or name from a data frame of channels. If multiple channels
have the same display name, the name parameter can be used to
disambiguate.

## Usage

``` r
get_channel_id_lookup(channels_df, display_name = NULL, name = NULL)
```

## Arguments

- channels_df:

  A data frame containing channel information. It must include at least
  three columns: \`id\` (the channel ID), \`display_name\`, and
  \`name\`.

- display_name:

  (Optional) A character string representing the display name of the
  channel for which the ID is to be retrieved.

- name:

  (Optional) A character string representing the unique name of the
  channel for which the ID is to be retrieved.

## Value

A character string containing the channel ID if found, otherwise an
error is thrown.

## Examples

``` r
# Sample channels data frame
channels <- data.frame(
  id = c("gy91r1kjnbnkdfu6jjoxzcm5ge", "utbtjouxkirniyh9u84oym6mnh", "abc12345xyz", "xyz56789abc"),
  display_name = c("Off-Topic", "Town Square", "Off-Topic", "Random"),
  name = c("off-topic", "town-square", "off-topic-team", "random"),
  stringsAsFactors = FALSE
)

# As this display_name is not unique for "Off-Topic" this will lead to an error.
#' # get_channel_id_lookup(channels, display_name = "Off-Topic")

# this will however return a result
get_channel_id_lookup(channels, display_name = "Town Square")
#> [1] "utbtjouxkirniyh9u84oym6mnh"

# Get the channel ID for "Town Square" by name
get_channel_id_lookup(channels, name = "town-square")
#> [1] "utbtjouxkirniyh9u84oym6mnh"
```
