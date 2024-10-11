library(shiny)
library(DT)
library(dplyr)

server <- function(input, output, session) {
  
  # Helper function to show a notification if no results are found
  no_results_found_warning <- function() {
    showNotification("No results found.", type = "warning")
  }
  
  # Render an empty map on start up
  output$interactiveMap <- renderPlot({
    map_handler$empty_map()
  })
  
  # Render an empty table on start up
  output$dataTable <- renderDT({
    datatable(data.frame(title = character(), operating_area = character()), 
              options = list(pageLength = 5))
  })
  
  # Handle KPI Search
  observeEvent(input$kpi_update, {
    kpi_search_term <- input$kpi_search
    kpi_year <- input$kpi_year
    
    # Handle no input
    if (kpi_search_term == "") {
      showNotification("Please enter a valid KPI search term.", type = "error")
      return()
    }
    
    # Fetch KPI data
    kpi_result <- api_handler$parse_kpi(kpi_search_term)
    
    # Handle no results
    if (nrow(kpi_result) == 0) {
      no_results_found_warning()
      return()
    }
    
    # Add clickable links to the title column
    kpi_result <- kpi_result %>%
      mutate(
        title_link = sprintf(
          '<a href="#" class="kpi-link" data-id="%s" style="color: blue; text-decoration: underline;">%s</a>',
          id, title
        )
      )
    
    # Render the table
    output$dataTable <- renderDT({
      datatable(
        kpi_result %>% select(title_link, operating_area), 
        options = list(pageLength = 5),
        escape = FALSE,  # Allow HTML rendering for clickable links
        colnames = c("Title", "Operating Area")
      )
    })
  })
  
  # Handle click events for KPI links in the data table
  observeEvent(input$dataTable_cell_clicked, {
    info <- input$dataTable_cell_clicked
    if (!is.null(info$value) && grepl("kpi-link", info$value)) {
      # Extract KPI ID and Name from the clicked link
      kpi_id <- sub('.*data-id="(.*?)".*', '\\1', info$value)
      indicator_name <- sub('.*">(.*?)<.*', '\\1', info$value)
      selected_year <- input$kpi_year
      
      # Fetch data based on KPI ID and year
      kpi_data <- api_handler$get_data(kpi_ids = kpi_id, municipality_ids = list(), year = selected_year)
      
      if (nrow(kpi_data) == 0) {
        showNotification("No data found for the selected KPI and year.", type = "warning")
        return()
      }
      
      # Merge KPI data with map data
      merged_data <- map_handler$merge_data(kpi_data)
      View(merged_data)
      # Update the map with new data
      output$interactiveMap <- renderPlotly({
        map_handler$plot_data(merged_data, title = indicator_name)
      })
    }
  })
  
  # Handle Municipality Data Update
  observeEvent(input$municipality_update, {
    selected_municipality <- input$municipality_search
    selected_year <- input$municipality_year
    municipality_id <- municipalities_df$ID[municipalities_df$KOM_NAMN == selected_municipality]
    
    if (length(municipality_id) == 0 || selected_municipality == "") {
      showNotification("Please select a valid municipality.", type = "error")
      return()
    }
    
    # Fetch data for the municipality
    kpi_ids <- default_kpis$Indicator_ID
    data_result <- api_handler$get_data(kpi_ids, municipality_id, selected_year)
    
    if (nrow(data_result) == 0) {
      showNotification("No data found for the selected municipality.", type = "warning")
      return()
    }
    
    # Process the data and update the table
    processed_data <- data_result %>%
      left_join(default_kpis, by = c("kpi" = "Indicator_ID")) %>%
      select(Indicator_English, value, kpi)
    
    output$dataTable <- renderDT({
      datatable(
        processed_data, 
        options = list(pageLength = 5), 
        colnames = c("Title", "Value", "KPI")
      )
    })
    
    # Update the map to highlight the selected municipality
    output$interactiveMap <- renderPlotly({
      map_handler$highlight_municipality(selected_municipality, municipality_id)
    })
  })
}
