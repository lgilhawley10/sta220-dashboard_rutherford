# sta220-dashboard_rutherford

What is this?

A dashboard for young professionals who live in Rutherford, NJ (or are moving there) and work in Midtown Manhattan, deciding how to commute: NJ Transit train (Rutherford station to New York Penn, via Secaucus), NJ Transit bus (Rutherford to Port Authority), or driving. It compares monthly cost and travel time, and benchmarks Rutherford against Bergen County and New Jersey.


Where did the data come from?

Source 1. American Community Survey 5-Year Estimates, Table B08301 (Means of Transportation to Work), U.S. Census Bureau. Geographies: Rutherford borough, Bergen County, New Jersey. Data years 2020-2024. File: data/acs_b08301_2024_raw.csv.https://data.census.gov/table/ACSDT5Y2024.B08301

Source 2. NJ Transit Rail GTFS schedule feed. https://www.njtransit.com/developer-tools

Source 3. NJ Transit fares, NJ Transit. Monthly pass prices, Rutherford to New York Penn (rail). https://www.njtransit.com/tickets


How do I run it?

Open sta220-dashboard_rutherford.Rproj, then run scripts/01_import.R.

Made with R version 4.6.1, tidyverse version 2.0.0.


What does each script do?

01_import.R reads each raw file in data/ and writes a cleaned, R-ready version to data/:

acs_b08301_clean.csv: one row per place per commute mode, with the number of workers, margin of error, and share of workers.
rail_trip_times_clean.csv: one row per scheduled train trip from Rutherford to Secaucus, with departure time and minutes on board.
njt_fares_clean.csv: one row per fare product.


What is in each folder?

data/: raw files, never edited by hand, plus the cleaned files made by the scripts. scripts/: run in order by number. output/: made by the scripts.

Manually curating data for import into R

njt_fares_YYYY-MM-DD.csv was created by hand because NJ Transit does not publish a downloadable fare table:

Went to https://www.njtransit.com/tickets on YYYY-MM-DD.
Looked up the monthly pass price for Rutherford to New York Penn Station (rail).
Looked up the monthly pass price for the Rutherford bus stop to Port Authority Bus Terminal (bus, zone X).
Typed them into a CSV with the columns mode, origin, destination, product, price_usd, date_checked.


Who made it, and when was it last updated?

Luke Gilhawley, 10/26/2026
