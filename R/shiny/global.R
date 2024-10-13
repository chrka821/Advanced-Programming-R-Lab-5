library(here)
source(here("R", "main.R"))
api_handler <- KoladaHandler$new()
map_handler <- MapHandler$new()

# Reading list of all swedish municipalities from disk
municipalities_df <- read.csv(here("inst/resources/swedish_municipalities.csv"), 
                              stringsAsFactors = FALSE, 
                              colClasses = "character")

# Drop down list for municipalities
municipality_choices <- sort(municipalities_df$KOM_NAMN)

# Default KPIs which get displayed when a municipality is searched for
default_kpis <- read.csv(here("inst/resources/default_kpis.csv"), stringsAsFactors = FALSE)

filtered_default_kpis <- default_kpis[default_kpis$Indicator_ID != "U60002", ]

# Extract unique KPI names for the dropdown
kpi_choices <- unique(filtered_default_kpis$Indicator_English)
