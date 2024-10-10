library(shiny)
library(DT)
library(dplyr)

server <- function(input, output, session) {
  # Reactive to keep track of the current page
  current_page <- reactiveVal("Overview")
  
  # Page navigation
  observeEvent(input$nav_overview, { current_page("Overview") })
  observeEvent(input$nav_analysis, { current_page("Additional Analysis") })
  
  # Helper function to format the values, prints values by gender
  format_values <- function(val_list) {
    if (is.data.frame(val_list) && all(c("gender", "value") %in% colnames(val_list))) {
      formatted_values <- sapply(1:nrow(val_list), function(i) {
        val <- val_list[i, ]
        if (!is.null(val$gender) && !is.null(val$value)) {
          switch(val$gender,
                 "T" = paste("Total:", val$value),
                 "K" = paste("Women:", val$value),
                 "M" = paste("Men:", val$value),
                 NULL)
        } else {
          NULL
        }
      })
      paste(na.omit(formatted_values), collapse = ", ")
    } else {
      "No data available"
    }
  }
  
  # Update data based on user input
  observeEvent(input$update, {
    selected_municipality <- input$municipality_search
    selected_year <- input$municipality_year
    municipality_id <- municipalities_df$ID[municipalities_df$KOM_NAMN == selected_municipality]
    
    if (length(municipality_id) > 0 && selected_municipality != "") {
      kpi_ids <- default_kpis$Indicator_ID
      data_result <- api_handler$get_data(kpi_ids, municipality_id, selected_year)
      
      processed_data <- data_result %>%
        left_join(default_kpis, by = c("kpi" = "Indicator_ID")) %>%
        mutate(
          indicator = Indicator_English,
          values = sapply(values, format_values)
        ) %>%
        select(indicator, municipality, period, values)
      
      output$dataTable <- renderDT({ datatable(processed_data, options = list(pageLength = 5)) })
    } else {
      showNotification("Please select a valid municipality before updating.", type = "error")
    }
  })
  
  # Dynamic content rendering
  output$content <- renderUI({
    if (current_page() == "Overview") {
      tagList(
        h4("Map"),
        plotOutput("interactiveMap"),
        br(),
        h4("Data Table"),
        DTOutput("dataTable")
      )
    } else {
      tagList(
        h4("Additional Analysis"),
        p("This page will be used for more detailed data analysis or visualizations.")
      )
    }
  })
  
  # Placeholder for the interactive map
  output$interactiveMap <- renderPlot({ plot(1:10, 1:10, main = "Sample Map Plot") })
  
  # Initial placeholder for the data table
  output$dataTable <- renderDT({
    datatable(data.frame(indicator = character(), municipality = character(), period = character(), values = character()), 
              options = list(pageLength = 5))
  })
}
