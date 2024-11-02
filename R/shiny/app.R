# app.R

library(shiny)
library(httr)
library(jsonlite)
library(R6)
library(sf)
library(dplyr)
library( ggplot2)
library(plotly)
library(here)
library(DT)


# Source the UI and server code
source("ui.R")
source("server.R")
source("../R/main.R")

# Run the Shiny app
shinyApp(ui = ui, server = server)
