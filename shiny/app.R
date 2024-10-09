# app.R

library(shiny)

# Source the UI and server code
source("ui.R")
source("server.R")

# Run the Shiny app
shinyApp(ui = ui, server = server)
