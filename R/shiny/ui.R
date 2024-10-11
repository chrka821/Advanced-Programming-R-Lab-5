library(shiny)
library(bslib)
library(DT)

# Define a custom theme with a navy-blue sidebar and grey/white main page
custom_theme <- bs_theme(
  bg = "#f8f9fa",  # Background color for the main content (light grey/white)
  fg = "#000000",  # Foreground text color (black)
  primary = "#0a4275",  # Primary color for elements (navy blue)
  secondary = "#d3d3d3",  # Secondary color for minor elements (light grey)
  base_font = font_google("Roboto"),
  bootswatch = "flatly"  # Adding a base theme for a modern look
)

# Define the UI for the application using bslib's page_sidebar()
ui <- page_sidebar(
  theme = custom_theme,
  titlePanel(div("Data Exploration of Municipalities", style = "text-align: center;")),
  
  # Custom CSS for center alignment
  tags$head(
    tags$style(HTML("
      .content-wrapper {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: flex-start;
        padding: 20px;
        width: 100%;
      }
      .shiny-plot-output {
        width: 80%;
        max-width: 900px;
      }
      .dataTables_wrapper {
        width: 80%;
        max-width: 900px;
      }
    "))
  ),
  
  sidebar = sidebar(
    bg = "#0a4275",
    fg = "#ffffff",
    width = 250,
    hr(),
    h3("Filters", style = "color: #ffffff;"),
    
    textInput("kpi_search", "Search KPI:", placeholder = "Enter KPI to search"),
    selectInput("kpi_year", "Select Year for KPI:", choices = 2015:2023),
    actionButton("kpi_update", "Search KPI", class = "btn-primary"),
    hr(),
    
    selectizeInput("municipality_search", "Search Municipality:", choices = c(" " = "", municipality_choices), 
                   options = list(placeholder = "Start typing to filter")),
    selectInput("municipality_year", "Select Year for Municipality:", choices = 2015:2023),
    actionButton("municipality_update", "Update Municipality Data", class = "btn-primary")
  ),
  
  # Custom content area for centering the map and table
  tags$div(
    class = "content-wrapper",
    h4("Map"),
    plotOutput("interactiveMap"),
    br(),
    h4("Data Table"),
    DTOutput("dataTable")
  )
)
