# scripts/02_merge.R
# Puts my two clean sources together: how Rutherford, Bergen County, and New Jersey get to work


# Packages and Load the Data ---------------------------------------------------------------------

library(tidyverse)

# Source 1, made by 01_import.R. geo_id is a code, so it is read as text.
commute <- read_csv(
  "data/commute_clean.csv",
  col_types = cols(geo_id = col_character())
)

# One row is one NJ town. Expect 564 rows and 8 columns.
dim(commute)
names(commute)
summary(commute)

# The benchmarks, made by 01_import.R. Expect 1 row and 8 columns each.
commute_bergen <- read_csv(
  "data/commute_clean_bergen.csv",
  col_types = cols(geo_id = col_character())
)

commute_nj <- read_csv(
  "data/commute_clean_nj.csv",
  col_types = cols(geo_id = col_character())
)

dim(commute_bergen)
dim(commute_nj)

# Source 2, made by 01_import.R.
fares <- read_csv("data/fares_clean.csv")

# One row is one way of getting to work. Expect 3 rows and 5 columns.
dim(fares)
names(fares)
summary(fares)

# Rutherford and the two benchmarks, stacked into one table
three_places <- commute |>
  filter(str_detect(name, "^Rutherford borough")) |>
  bind_rows(commute_bergen, commute_nj) |>
  mutate(place = str_remove_all(name, " borough|, Bergen County|, New Jersey"))   # short names for the labels

# Expect 3 rows: Rutherford, Bergen County, New Jersey
dim(three_places)
three_places$place

# One row becomes one place and one mode, and each count becomes a percent of commuters
mode_share <- three_places |>
  pivot_longer(
    cols = c(car, bus, train),
    names_to = "mode",
    values_to = "riders"
  ) |>
  mutate(pct = round(riders / commuters * 100, 1)) |> 
  select(geo_id, place, mode, riders, commuters, pct)

# One row is one place and one mode. Expect 9 rows (3 places x 3 modes) and 6 columns
dim(mode_share)
names(mode_share)
summary(mode_share)


# Know Your Key (Step 2) -------------------------------------------------------------------------

# 0 rows: place and mode together are a key in mode_share
mode_share |>
  count(place, mode) |>
  filter(n > 1)

# 0 rows: mode is a key in fares
fares |>
  count(mode) |>
  filter(n > 1)


# Can These Be Merged? (Step 3) ------------------------------------------------------------------
# My answers to the five questions:
#
#   Unit of analysis  Not the same. A row of mode_share is one place and one way of getting to
#                     work; a row of fares is one way of getting to work. Every place gets the
#                     same price for a mode, which is fine as a monthly pass costs the same no
#                     matter how many people buy it.
#   Time              ACS: 2020-2024 (5-year). Fares: checked on 11 / 6, so they are today's
#                     prices. Not the same.
#   Key               mode, spelled the same way in both ("car", "bus", "train").
#   Format            mode is lowercase text in both. monthly_pass is a number in dollars.
#   Coverage          All 3 modes are in both. Car has no monthly pass, so its price is NA on
#                     purpose while driving costs (tolls, gas, parking) come from other sources later.
#
#   Verdict           Merge as is. fares is the right table: many rows of mode_share match one
#                     row of fares.


# Predict, Then Check (Step 5) -------------------------------------------------------------------

# Before the merge, what I expect:
# 1) Rows: 9, the same as mode_share (mode_share is the left table)
# 2) Columns: 6 (mode_share) + 4 (5 in fares - the key) = 10
# 3) Drops: none

anti_join(mode_share, fares, by = "mode")   # expect 0 rows

anti_join(fares, mode_share, by = "mode")   # expect 0 rows


# The Merge (Step 6) -----------------------------------------------------------------------------

# Say: "Start with mode_share, add the columns of fares, matching rows by mode; save it as
# commute_merged."
commute_merged <- mode_share |>
  left_join(fares, by = "mode")

# Three checks after the merge: expect 9 rows and 10 columns, and NA in monthly_pass only for car
dim(commute_merged)
names(commute_merged)
summary(commute_merged)

commute_merged |>
  select(place, mode, pct, monthly_pass)


# Save (Step 6) ----------------------------------------------------------------------------------

write_csv(commute_merged, "data/commute_merged.csv")