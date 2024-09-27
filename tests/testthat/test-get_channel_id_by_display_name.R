
# Sample data frame for testing
channels_df <- structure(list(
  id = c("gy91r1kjnbnkdfu6jjoxzcm5ge", "utbtjouxkirniyh9u84oym6mnh"),
  create_at = c(1727336854611, 1727336854587),
  update_at = c(1727336854611, 1727336854587),
  delete_at = c(0L, 0L),
  team_id = c("9j5zjmwkxbb4dkph9zzapj5c4a", "9j5zjmwkxbb4dkph9zzapj5c4a"),
  type = c("O", "O"),
  display_name = c("Off-Topic", "Town Square"),
  name = c("off-topic", "town-square"),
  header = c("", ""),
  purpose = c("", ""),
  last_post_at = c(1727336854812, 1727336854709),
  total_msg_count = c(0L, 0L),
  extra_update_at = c(0L, 0L),
  creator_id = c("", ""),
  scheme_id = c(NA, NA),
  props = c(NA, NA),
  group_constrained = c(NA, NA),
  shared = c(NA, NA),
  total_msg_count_root = c(0L, 0L),
  policy_id = c(NA, NA),
  last_root_post_at = c(1727336854812, 1727336854709)
), class = "data.frame", row.names = 1:2)

# Unit tests for the get_channel_id_lookup function
test_that("get_channel_id_lookup works correctly", {

  # Test: Valid display name
  expect_equal(get_channel_id_lookup(channels_df, "Off-Topic"), "gy91r1kjnbnkdfu6jjoxzcm5ge")

  # Test: Another valid display name
  expect_equal(get_channel_id_lookup(channels_df, "Town Square"), "utbtjouxkirniyh9u84oym6mnh")

  # Test: Invalid display name
  expect_error(get_channel_id_lookup(channels_df, "Non-Existent Channel"),
               "No channel found with the specified display name.")

  # Test: Invalid input (not a data frame)
  expect_error(get_channel_id_lookup(matrix(1:4, nrow = 2), "Off-Topic"),
               "Input must be a data frame containing 'id' and 'display_name' columns.")

  # Test: Missing necessary columns
  expect_error(get_channel_id_lookup(data.frame(id = c("id1", "id2")), "Off-Topic"),
               "Input must be a data frame containing 'id' and 'display_name' columns.")
})

