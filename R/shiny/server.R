library(shiny)
library(DT)
library(dplyr)
library(ggplot2)
library(plotly)

# Server logic for the Shiny application
server <- function(input, output, session) {
  
  # ------------------ Helper Functions ------------------
  
  # Helper function to show a notification if no results are found
  no_results_found_warning <- function() {
    showNotification("No results found.", type = "warning")
  }
  
  # ------------------ Render Empty Map ------------------
  
  # Render an empty map when the app starts (Page 2 - Municipality Map)
  output$interactiveMap <- renderPlotly({
    map_handler$empty_map()
  })
  
  # ------------------ Render Empty Table ------------------
  
  # Render an empty table when the app starts (Page 1 - Municipality Data)
  output$dataTable <- renderDT({
    datatable(
      data.frame(title = character(), value = numeric(), kpi = character()), 
      options = list(pageLength = 5)
    )
  })
  
  # ------------------ Municipality Data Update (Page 1) ------------------
  
  # Update table based on selected municipality and year
  observeEvent(input$municipality_update, {
    selected_municipality <- input$municipality_search
    selected_year <- input$municipality_year
    
    # Get municipality ID from selected name
    municipality_id <- municipalities_df$ID[municipalities_df$KOM_NAMN == selected_municipality]
    
    if (length(municipality_id) == 0 || selected_municipality == "") {
      showNotification("Please select a valid municipality.", type = "error")
      return()
    }
    
    # Fetch data for the selected municipality
    kpi_ids <- default_kpis$Indicator_ID
    data_result <- api_handler$get_data(kpi_ids, municipality_id, selected_year)
    
    if (nrow(data_result) == 0) {
      showNotification("No data found for the selected municipality.", type = "warning")
      return()
    }
    
    # Process the data and update the table
    processed_data <- data_result %>%
      left_join(default_kpis, by = c("kpi" = "Indicator_ID")) %>%
      select(Indicator_English, value)
    
    # Render updated data table
    output$dataTable <- renderDT({
      datatable(
        processed_data, 
        options = list(pageLength = 5), 
        colnames = c("KPI", "Value")
      )
    })
  })
  
  # ------------------ KPI Map Update (Page 2) ------------------
  
  # Update the map based on selected KPI and year when "Update Map" button is clicked
  # Handle KPI Selection for the Gradient Map (Page 2)
  observeEvent(input$update_map, {
    selected_kpi <- input$kpi_search
    selected_year <- input$kpi_year
    
    if (selected_kpi != "") {
      
      # Get the corresponding KPI ID
      selected_kpi_id <- default_kpis$Indicator_ID[default_kpis$Indicator_English == selected_kpi]
      
      # Fetch KPI data for all municipalities for the selected KPI and year
      kpi_data <- api_handler$get_data(selected_kpi_id, municipality_id = NULL, year = selected_year)
      
      if (nrow(kpi_data) == 0) {
        no_results_found_warning()
        return()
      }
      
      # Ensure KPI values are numeric
      kpi_data$value <- as.numeric(kpi_data$value)
      
      # Calculate the national mean
      national_mean <- mean(kpi_data$value, na.rm = TRUE)
      
      # Merge KPI data with map data
      municipality_map_data <- map_handler$merge_data(kpi_data)
      
      # Update the map with gradient based on KPI values
      output$interactiveMap <- renderPlotly({
        ggplot(municipality_map_data) +
          geom_sf(aes(fill = value, text = paste("Municipality: ", KOM_NAMN, "<br>", "Value: ", round(value, 2)))) +  # Rounded values
          scale_fill_gradient(low = "lightblue", high = "darkblue", na.value = "grey") +
          theme_minimal() +
          ggtitle(paste("Map of", selected_kpi, "for year", selected_year))
      })
      
      # Display the national mean under the map
      output$nationalMean <- renderText({
        paste("National Mean for", selected_kpi, "in", selected_year, ":", round(national_mean, 2))
      })
    }
  })
  
}

