# Create a data frame with the selected KPIs and their IDs
kpi_df <- data.frame(
  Indicator_English = c(
    "Unemployment Rate", "Carbon Dioxide Emissions per Capita", "Reported Crimes per 100k Inhabitants",
    "High School Graduation Rate", "Average Age", "Refugees / Job seeking migrants per 1000 Inhabitants",
    "Median income after tax, age 20 and above", "Survey: Would you recommend moving here? (%)"
  ),
  Indicator_ID = c(
    "N03920", "N00401", "N07540", "N18605", "N00959", "N01993", "N00905", "U60002"
  )
)
write.csv(kpi_df, "resources/default_kpis.csv")


get_data = function(kpi_ids, municipality_id, year){
  endpoint = "http://api.kolada.se/v2/data"
  kpi_ids_string = paste(kpi_ids, collapse = ",")
  endpoint_query = paste0(endpoint, "/kpi/", kpi_ids_string, "/municipality/", municipality_id, "/year/", year)
  print(endpoint_query)
}

get_data(c(kpi_df$Indicator_ID), "0114", "2015")