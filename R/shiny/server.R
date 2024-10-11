library(shiny)
library(DT)
library(dplyr)

server <- function(input, output, session) {
    no_results_found_warning <- function(){
    showNotification("No results found for the specified KPI.", type = "warning")
    output$dataTable <- renderDT({
      datatable(data.frame(title = character(), operating_area = character()), 
                options = list(pageLength = 5))
    })
  }
  
  # Render an empty map on start up
  output$interactiveMap <- renderPlot({
    map_handler$plot_data(title = "Map of Sweden")  # Call plot_data with an empty dataset
  })
  
  # Render an empty table on start up
  output$dataTable <- renderDT({
    datatable(data.frame(title = character(), operating_area = character()), 
              options = list(pageLength = 5))
  })
  
  # Handle KPI search button click
  observeEvent(input$kpi_update, {
    kpi_search_term <- input$kpi_search
    kpi_year <- input$kpi_year
    
    if (kpi_search_term != "") {
      # Call parse_kpi with search term to get list of possible KPIs
      kpi_result <- api_handler$parse_kpi(kpi_search_term)
      if (length(kpi_result) == 0) { # No matching results, abort
        no_results_found_warning()
        return() # abort execution of handler function
      }
      
      # Convert kpi_result to a data frame if it is a list
      if (is.list(kpi_result)) {
        kpi_result <- as.data.frame(kpi_result, stringsAsFactors = FALSE)
      }
      
      # Filter the KPI data to only select Kommuns 
      filtered_kpi_result <- kpi_result %>%
        filter(municipality_type == "K") %>%
        select(title, operating_area, id)
      
      
      if (nrow(filtered_kpi_result) == 0) { # Found matching results, but none for kommuns
        no_results_found_warning()
        return()
      }
      
      # Add clickable links to the title column
      filtered_kpi_result <- filtered_kpi_result %>%
        mutate(
          title_link = sprintf(
            '<a href="#" class="kpi-link" data-id="%s" style="color: blue; text-decoration: underline;">%s</a>',
            id, title
          )
        )
      
      # Render the filtered KPIs in the data table
      output$dataTable <- renderDT({
        datatable(filtered_kpi_result %>% select(title_link, operating_area, id), 
                  options = list(pageLength = 5),
                  escape = FALSE,  # Allow HTML rendering for clickable links
                  colnames = c("Title", "Operating Area", "KPI"))
      })
    } else {
      showNotification("Please enter a valid KPI search term.", type = "error")
    }
  })
  
  # Handle click events for KPI links in the data table
  observeEvent(input$dataTable_cell_clicked, {
    info <- input$dataTable_cell_clicked
    if (!is.null(info$value) && grepl("kpi-link", info$value)) {
      # Extract KPI ID from the clicked link
      kpi_id <- sub('.*data-id="(.*?)".*', '\\1', info$value)
      
      # Get the selected year
      selected_year <- input$kpi_year
      
      # Call the get_data function with the selected year, KPI ID, and empty list for municipality_ids
      kpi_data <- api_handler$get_data(kpi_ids = kpi_id, municipality_ids = list(), year = selected_year)
      # Check if the returned data is empty
      if (length(kpi_data$values) == 0) {
        showNotification("No data found for the selected KPI and year.", type = "warning")
        return()
      }
      
      # Extract the KPI name for the title
      kpi_title <- sub('.*">(.*?)<.*', '\\1', info$value)
      merged_data <- map_handler$merge_data(kpi_data)
      
      # Update the map with the KPI title as the plot title
      output$interactiveMap <- renderPlotly({
        map_handler$plot_data(merged_data, title = kpi_title)
      })
    }
  })
  
  # Handle municipality data update button click
  observeEvent(input$municipality_update, {
    selected_municipality <- input$municipality_search
    selected_year <- input$municipality_year
    municipality_id <- municipalities_df$ID[municipalities_df$KOM_NAMN == selected_municipality]
    
    if (length(municipality_id) > 0 && selected_municipality != "") {
      kpi_ids <- default_kpis$Indicator_ID
      data_result <- api_handler$get_data(kpi_ids, municipality_id, selected_year)
      View(data_result)
      # Check if the data result is empty
      if (length(data_result) == 0) {
        showNotification("No data found for the selected municipality.", type = "warning")
        return()
      }
      
      processed_data <- data_result %>%
        left_join(default_kpis, by = c("kpi" = "Indicator_ID")) %>%
        mutate(
          indicator = Indicator_English,
          values
        ) %>%
        select(indicator, municipality, period, values)
      
      # Render the processed data in the data table
      output$dataTable <- renderDT({
        datatable(processed_data, options = list(pageLength = 5))
      })
      
      # Update the map to highlight the selected municipality in red
      output$interactiveMap <- renderPlot({
        # Create a map highlighting the selected municipality
        map_handler$shapefile_data <- map_handler$shapefile_data %>%
          mutate(highlight = ifelse(ID == municipality_id, "red", "grey"))
        
        ggplot() +
          geom_sf(data = map_handler$shapefile_data, aes(fill = highlight), color = "black") +
          scale_fill_identity() +
          theme_minimal() +
          ggtitle(paste("Map for", selected_municipality))
      })
    } else {
      showNotification("Please select a valid municipality before updating.", type = "error")
    }
  })
}
