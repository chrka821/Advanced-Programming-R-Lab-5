ui <- navbarPage("Data Exploration of Municipalities",
                 
                 tags$head(
                   tags$style(HTML("
                     .navbar {
                       background-color: #0066CC;  
                     }
                     .navbar-default .navbar-brand {
                       color: #FFD700;  
                     }
                     .navbar-default .navbar-nav > li > a {
                       color: #FFD700;  
                     }
                     .navbar-default .navbar-brand:hover,
                     .navbar-default .navbar-nav > li > a:hover {
                       color: #FFFF00;  
                     }
                     body {
                       background-color: #ECECEC;  
                     }
                     h3 {
                       color: #0066CC;  
                     }
                     .btn-primary {
                       background-color: #0066CC;  
                       color: #FFD700;  
                       border-color: #0066CC;
                     }
                     .btn-primary:hover {
                       background-color: #0055A3;  
                     }
                   "))
                 ),
                 # First tab: Municipality Data Table
                 tabPanel("Municipality Data",
                          sidebarLayout(
                            sidebarPanel(
                              h3("Municipality Data"),
                              selectizeInput("municipality_search", "Search Municipality:", choices = c(" " = "", municipality_choices), 
                                             options = list(placeholder = "Start typing to filter")),
                              selectInput("municipality_year", "Select Year for Municipality", choices = 2015:2023),
                              actionButton("municipality_update", "Update Municipality Data", class = "btn-primary")
                            ),
                            mainPanel(
                              DTOutput("dataTable")
                            )
                          )
                 ),
                 
                 # Second tab: Municipality Map with KPI Search and Update Button
                 tabPanel("Municipality Map",
                          sidebarLayout(
                            sidebarPanel(
                              h3("KPI Search"),
                              selectizeInput("kpi_search", "Search KPI:", choices = kpi_choices, 
                                             options = list(placeholder = "Start typing KPI")),
                              selectInput("kpi_year", "Select Year for KPI", choices = 2015:2023),
                              actionButton("update_map", "Update Map", class = "btn-primary")  
                            ),
                            mainPanel(
                              plotlyOutput("interactiveMap"),
                              textOutput("nationalMean")  
                            )
                          )
                 )
)
