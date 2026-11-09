# scripts/03_mode_share.R
# Figure 1: how do Rutherford's commuters get to work, compared with Bergen County and New Jersey?
#   In:  data/commute_merged.csv (made by 02_merge.R)
#   Out: output/figures/mode_share.png
# Run 01_import.R and 02_merge.R first.


# Packages and Load the Data ---------------------------------------------------------------------

library(tidyverse)

commute_merged <- read_csv(
  "data/commute_merged.csv",
  col_types = cols(geo_id = col_character())
)

# One row is one place and one mode: one bar each. Expect 9 rows and 10 columns.
dim(commute_merged)
names(commute_merged)
summary(commute_merged)

commute_merged |>
  select(place, mode, pct)


# The Figure -------------------------------------------------------------------------------------

fig1 <- ggplot(
  commute_merged,
  aes(
    x = pct,
    y = fct_reorder(place, commuters),     # sorts the bars by size: Rutherford, Bergen County, New Jersey
    fill = place
  )
) +
  geom_col() +
  geom_text(aes(label = pct), hjust = -0.2, size = 2.6) + 
  facet_wrap(~ mode) +                                         
  scale_fill_manual(
    values = c("Rutherford" = "#1f4e79", "Bergen County" = "grey60", "New Jersey" = "grey80"),
    guide = "none"
  ) +
  scale_x_continuous(limits = c(0, 100)) +                     
  labs(
    title    = "Rutherford commuters ride the bus at almost 3 times the state rate",
    subtitle = "Percent of commuters who get to work each way",
    x        = "Percent of commuters, 2020-2024",
    y        = "Place",
    caption  = "Source: U.S. Census Bureau, American Community Survey 2020-2024 (5-year), table B08301.",
    alt      = paste(
      "Bar chart in three panels: bus, car, and train, each showing the percent of commuters in",
      "Rutherford, Bergen County, and New Jersey. Bus: Rutherford 13.3, Bergen County 9.1, New Jersey 4.9.",
      "Car: Rutherford 71, Bergen County 81.4, New Jersey 84. Train: Rutherford 6.1, Bergen County 2.2,",
      "New Jersey 2.0. Rutherford uses the bus and train more, and drives less, than the county or the state."
    )
  ) +
  theme_minimal()

fig1

# Git does not keep empty folders, so make output/figures if it is not there yet
dir.create("output/figures", showWarnings = FALSE, recursive = TRUE)

ggsave(
  "output/figures/mode_transport.png",
  fig1,
  width = 7,
  height = 3.2,
  dpi = 300,
  bg = "white"
)
