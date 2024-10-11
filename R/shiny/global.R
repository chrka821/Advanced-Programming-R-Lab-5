library(here)
source(here("R", "main.R"))
api_handler <- KoladaHandler$new()
map_handler <- MapHandler$new()

# Reading list of all swedish municipalities from disk
municipalities_df <- read.csv(here("resources/swedish_municipalities.csv"), 
                              stringsAsFactors = FALSE, 
                              colClasses = "character")
municipality_choices <- sort(municipalities_df$KOM_NAMN)
default_kpis <- read.csv(here("resources/default_kpis.csv"), stringsAsFactors = FALSE)