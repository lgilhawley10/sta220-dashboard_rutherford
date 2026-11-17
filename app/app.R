# app.R
# A base dashboard to edit for your final project. See "Using the Dashboard Template."
# Based on "Hello Shiny!" https://shiny.posit.co/r/gallery/start-simple/faithful/

library(shiny)
library(tidyverse)


# The Data ---------------------------------------------------------------------------------------

# Save your cleaned data in app/data/, then delete the # below.
# Yes, you will have cleaned data in two places in your repo.
commute_merged <- read_csv(
  "data/commute_merged.csv",
  col_types = cols(geo_id = col_character())
)

# The UI (what the reader sees) ------------------------------------------------------------------

ui <- fluidPage(
  
  titlePanel("Train, Bus or Car? Commuting from Rutherford to Midtown Manhattan"),
  p("For: those who work in New York City but live in Rutherford and have to commute to and from Manhattan each workday."),
  p("The decision: should you take the NJ Transit Bus, NJ Transit Train or drive yourself?"),
  
  selectInput(inputId = "pick", label = "Which way are you thinking of getting to work?", choices = unique(commute_merged$mode)),
  
  h3("Figure 1. How Rutherford gets to work, compared with Bergen County"),
  plotOutput(outputId = "fig_1"),
  p("Rutherford commuters take the train almost 3 times as often as commuters across Bergen County (6.1% vs. 2.2%) and the bus about 1.5 times as often (13.3% vs. 9.1%), and they drive less (71% vs. 81.4%). Taking transit is common in Rutherford, and more of your neighbors take the bus than the train."),
  
  h3("What this dashboard cannot tell you"),
  p("How long each trip takes or how reliable the trains and buses are. The Census numbers are survey estimates, and Rutherford is a small town.")
  
)


# The Server (how the figures are made) ----------------------------------------------------------

server <- function(input, output) {
  
  output$fig_1 <- renderPlot({
    
    ggplot(
      commute_merged,
      aes(
        x = pct,
        y = place,       # Rutherford on top, Bergen County on the bottom
        fill = place
      )
    ) +
      geom_col(aes(alpha = mode == input$pick)) +
      geom_text(aes(label = paste0(pct, "%")), hjust = -0.2, size = 5) +   # the percent at the end of each bar
      facet_wrap(~ mode) +                                                 # one panel per mode: bus, car, train
      scale_fill_manual(
        values = c("Rutherford" = "#1f4e79", "Bergen County" = "grey60"),
        guide = "none") +
      scale_alpha_manual(
        values = c(`TRUE` = 1, `FALSE` = 0.3), 
        guide = "none"
        ) +   
      scale_x_continuous(limits = c(0, 100)) +                             # every panel runs from 0 to 100 percent
    labs(
      title    = "Rutherford commuters take the train almost 3 times\nas often as Bergen County commuters",
      subtitle = "Percent of commuters who get to work each way, Rutherford and Bergen County\n(commuters = all workers minus those who work from home)",
      x        = "Percent of commuters, 2020-2024",
      y        = NULL,
      caption  = "Source: U.S. Census Bureau, American Community Survey 2020-2024 (5-year), table B08301."
  ) +
  theme_minimal(base_size = 14) +                                      # bigger text for a web page
  theme(plot.title.position = "plot")
    
  })
  
}


# Run the App ------------------------------------------------------------------------------------

shinyApp(ui = ui, server = server)