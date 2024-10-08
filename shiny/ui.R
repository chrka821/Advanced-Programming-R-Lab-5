# ui.R

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
  
  
  
  sidebar = sidebar(
    bg = "#0a4275",  # Navy-blue background for the sidebar
    fg = "#ffffff",  # White text color for the sidebar
    width = 250,  # Adjust the width of the sidebar as needed
    h3("Navigation", style = "color: #ffffff;"),  # White text for sidebar titles
    actionButton("nav_overview", "Overview", icon = icon("chart-bar"), class = "btn-light"),
    actionButton("nav_analysis", "Additional Analysis", icon = icon("chart-line"), class = "btn-light"),
    hr(),
    h3("Filters", style = "color: #ffffff;"),
    selectInput("municipality", "Select Municipality:", choices = NULL),
    actionButton("update", "Update Data", class = "btn-primary")
    
  ),
  
  # Main content area
  
    h4(""),
    uiOutput("content")
  
)
