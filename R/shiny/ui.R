# UI for the app
ui <- fluidPage(
  titlePanel("Data Exploration of Municipalities"),
  
  sidebarLayout(
    sidebarPanel(
      h3("KPI Search"),
      textInput("kpi_search", "Search KPI"),
      selectInput("kpi_year", "Select Year for KPI", choices = 2015:2023),
      actionButton("kpi_update", "Search KPI", class = "btn-primary"),
      hr(),
      
      h3("Municipality Data"),
      selectizeInput("municipality_search", "Search Municipality:", choices = c(" " = "", municipality_choices), 
                     options = list(placeholder = "Start typing to filter")),
      selectInput("municipality_year", "Select Year for Municipality", choices = 2015:2023),
      actionButton("municipality_update", "Update Municipality Data", class = "btn-primary")
    ),
    
    mainPanel(
      plotlyOutput("interactiveMap"),
      br(),
      DTOutput("dataTable")
    )
  )
)