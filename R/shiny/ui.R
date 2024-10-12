ui <- navbarPage("Data Exploration of Municipalities",
                 
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
                              actionButton("update_map", "Update Map", class = "btn-primary")  # Add the button to update the map
                            ),
                            mainPanel(
                              plotlyOutput("interactiveMap"),
                              textOutput("nationalMean")  # Add this to display the national mean
                            )
                          )
                 )
)
