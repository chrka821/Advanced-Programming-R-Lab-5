library(shiny)
library(DT)

server <- function(input, output, session) {
  # Variable to keep track of the current page
  current_page <- reactiveVal("Overview")
  
  # Update the current page based on button clicks
  observeEvent(input$nav_overview, {
    current_page("Overview")
  })
  
  observeEvent(input$nav_analysis, {
    current_page("Additional Analysis")
  })
  
  # Handle the action button click for updating data
  observeEvent(input$update, {
    # Get the selected municipality name and year
    selected_municipality <- input$municipality_search
    selected_year <- input$municipality_year
    
    # Find the municipality ID based on the selected name
    municipality_id <- municipalities_df$ID[municipalities_df$KOM_NAMN == selected_municipality]
    
    # Ensure that a municipality is selected
    if (length(municipality_id) > 0 && selected_municipality != "") {
      # Get the list of KPI IDs
      kpi_ids <- default_kpis$Indicator_ID
      print(kpi_ids)
      # Call the api_handler's get_data() function with the necessary arguments
      # Make sure the api_handler is already instantiated and available
      data_result <- api_handler$get_data(kpi_ids, municipality_id, selected_year)
      
      View(data_result)
      # Display or process the data_result as needed
      # Here, we'll store it in a reactive variable for display later
      output$dataTable <- renderDT({
        datatable(data_result, options = list(pageLength = 5))
      })
      
      # Optionally, you can process data_result further for map rendering, etc.
    } else {
      showNotification("Please select a valid municipality before updating.", type = "error")
    }
  })
  
  # Dynamically display the content based on the selected page
  output$content <- renderUI({
    if (current_page() == "Overview") {
      tagList(
        h4("Map"),
        plotOutput("interactiveMap"),
        br(),
        h4("Data Table"),
        DTOutput("dataTable")
      )
    } else if (current_page() == "Additional Analysis") {
      tagList(
        h4("Additional Analysis"),
        p("This page will be used for more detailed data analysis or visualizations.")
      )
    }
  })
  
  # Placeholder for interactive map
  output$interactiveMap <- renderPlot({
    plot(1:10, 1:10, main = "Sample Map Plot")  # Replace with actual map plot code
  })
  
  # Initial placeholder for the data table, in case the user hasn't clicked update yet
  output$dataTable <- renderDT({
    datatable(data.frame(Municipality = character(), Value = numeric()), options = list(pageLength = 5))
  })
}
