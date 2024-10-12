library(here)
source(here("R", "main.R"))
api_handler <- KoladaHandler$new()
map_handler <- MapHandler$new()

# Reading list of all swedish municipalities from disk
municipalities_df <- read.csv(here("resources/swedish_municipalities.csv"), 
                              stringsAsFactors = FALSE, 
                              colClasses = "character")

# Drop down list for municipalities
municipality_choices <- sort(municipalities_df$KOM_NAMN)

# Default KPIs which get displayed when a municipality is searched for
default_kpis <- read.csv(here("resources/default_kpis.csv"), stringsAsFactors = FALSE)

# Assuming 'default_kpis' is the dataframe holding KPI data with columns 'Indicator_ID' and 'Indicator_English'
kpi_choices <- unique(default_kpis$Indicator_English)  # Extract unique KPI names
