library(here)
source(here("R", "main.R"))
api_handler <- kolada_handler$new()
map_handler <- map_handler$new()

# Reading list of all swedish municipalities from disk
municipalities_df <- read.csv("../resources/swedish_municipalities.csv", 
                              stringsAsFactors = FALSE, 
                              colClasses = "character")
municipality_choices <- sort(municipalities_df$KOM_NAMN)
default_kpis <- read.csv("../resources/default_kpis.csv", stringsAsFactors = FALSE)