# scripts/01_import.R
# Reads two sources from the files in data/ and writes clean CSVs for each.
#
#   Source 1: U.S. Census Bureau, American Community Survey 2020-2024 (5-year), table B08301, Means
#             of Transportation to Work, for New Jersey, Bergen County, and every New Jersey town
#             . Downloaded from data.census.gov on November 6, 2026.
#             https://data.census.gov/table/ACSDT5Y2024.B08301?g=040XX00US34_050XX00US34003_040XX00US34$0600000
#             In:  data/ACSDT5Y2024.B08301-Data.csv (from the download's zip, unchanged)
#             Out: data/commute_clean.csv, one row per town
#                  data/commute_clean_bergen.csv, one row: Bergen County
#                  data/commute_clean_nj.csv, one row: New Jersey
#
#   Source 2: NJ Transit, Tickets and Fares, monthly pass prices (rail: Rutherford to New York Penn
#             Station; bus: Rutherford to the Port Authority Bus Terminal). Checked on njtransit.com
#             on [date]. There is no file to download, so I typed the prices into a small CSV
#             (the README lists every step).
#             In:  data/njt_fares.csv (typed by hand)
#             Out: data/fares_clean.csv, one row per mode


# Packages ---------------------------------------------------------------------------------------

library(tidyverse)


# Source 1: ACS, Means of Transportation to Work -------------------------------------------------

# Column codes:
#   B08301_001E: Total workers 16 and over
#   B08301_002E: Car, truck, or van
#   B08301_011E: Bus
#   B08301_013E: Long-distance train or commuter rail (NJ Transit trains)
#   B08301_021E: Worked from home
commute_raw <- read_csv(
  "data/ACSDT5Y2024.B08301-Data.csv",
  col_select = c(
    geo_id  = GEO_ID,
    name    = NAME,
    workers = B08301_001E,
    car     = B08301_002E,
    bus     = B08301_011E,
    train   = B08301_013E,
    wfh     = B08301_021E
  ),                                                      
  col_types = cols(.default = col_character()),                  
  na = c("", "-", "**", "***")                                   
)

# The second row repeats the label so drop it
commute_raw <- filter(commute_raw, geo_id != "Geography")

# New Jersey and Bergen County are benchmarks, not towns, so they get their own files
commute_raw_nj <- filter(commute_raw, name == "New Jersey")

commute_raw_bergen <- filter(commute_raw, name == "Bergen County, New Jersey")

commute_raw <- filter(commute_raw, !name %in% c("New Jersey", "Bergen County, New Jersey"))

# One row is one place: every county subdivision. Expect 569 rows and 7 columns.
# all variable types should be character
dim(commute_raw)
names(commute_raw)
summary(commute_raw)

# New Jersey and Bergen County are intact: expect 1 row and 7 columns each, all characters
dim(commute_raw_nj)
dim(commute_raw_bergen)


# Clean geo_id and turn the counts into numbers
commute_clean <- commute_raw |>
  filter(!str_detect(name, "not defined")) |>                    
  mutate(
    geo_id = str_remove(geo_id, "0600000US"),                    
    workers = as.numeric(workers),
    car = as.numeric(car),
    bus = as.numeric(bus),
    train = as.numeric(train),
    wfh = as.numeric(wfh),
    commuters = workers - wfh
  )

# Clean for Bergen County (different geo id)
commute_clean_bergen <- commute_raw_bergen |>
  mutate(
    geo_id = str_remove(geo_id, "0500000US"),
    workers = as.numeric(workers),
    car = as.numeric(car),
    bus = as.numeric(bus),
    train = as.numeric(train),
    wfh = as.numeric(wfh),
    commuters = workers - wfh
  )

# Clean for nj (different geo id)
commute_clean_nj <- commute_raw_nj |>
  mutate(
    geo_id = str_remove(geo_id, "0400000US"),
    workers = as.numeric(workers),
    car = as.numeric(car),
    bus = as.numeric(bus),
    train = as.numeric(train),
    wfh = as.numeric(wfh),
    commuters = workers - wfh
  )

# One row is one town (expect 564). 8 variables (commuters is new!)
dim(commute_clean)
names(commute_clean)
summary(commute_clean)

# expect 1 row and 8 columns each
dim(commute_clean_bergen)
summary(commute_clean_bergen)

dim(commute_clean_nj)
summary(commute_clean_nj)

# the key check: 0 rows means geo_id is a key
commute_clean |>
  count(geo_id) |>
  filter(n > 1)

commute_clean |>
  filter(str_detect(name, "^Rutherford borough"))


# Source 2: NJ Transit, monthly pass prices ------------------------------------------------------

fares_raw <- read_csv(
  "data/njt_fares.csv",
  col_types = cols(.default = col_character())                   # every column as text first
)

# One row is one way of getting to work. Expect 3 rows (train, bus, car) and 5 columns.
dim(fares_raw)
names(fares_raw)
summary(fares_raw)

# Turn the price into a number
fares_clean <- fares_raw |>
  mutate(monthly_pass = as.numeric(monthly_pass))

# Expect 3 rows and 5 columns
dim(fares_clean)
names(fares_clean)
summary(fares_clean)

# the key check: 0 rows means mode is a key
fares_clean |>
  count(mode) |>
  filter(n > 1)


# Save -------------------------------------------------------------------------------------------

write_csv(commute_clean, "data/commute_clean.csv")

write_csv(commute_clean_bergen, "data/commute_clean_bergen.csv")

write_csv(commute_clean_nj, "data/commute_clean_nj.csv")

write_csv(fares_clean, "data/fares_clean.csv")