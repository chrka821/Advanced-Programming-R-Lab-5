library(httr)
library(jsonlite)

# Function to fetch all KPIs from Kolada, including pagination
fetch_all_kpis <- function() {
  base_url <- "https://api.kolada.se/v2/kpi"
  all_kpis <- list()
  page <- 1
  
  repeat {
    # Make the API request for the current page
    url <- paste0(base_url, "?per_page=100&page=", page)
    response <- GET(url)
    
    # Check if the request was successful
    if (status_code(response) != 200) {
      stop("Failed to fetch KPIs from Kolada")
    }
    
    # Parse the response to JSON
    kpi_data <- content(response, as = "text", encoding = "UTF-8")
    kpi_list <- fromJSON(kpi_data)$values
    
    # If no more data is returned, break the loop
    if (length(kpi_list) == 0) {
      break
    }
    
    # Append the current page of KPIs to the overall list
    all_kpis <- c(all_kpis, kpi_list)
    
    # Check for the next page
    next_page <- fromJSON(kpi_data)$next_page
    if (is.null(next_page)) {
      break
    }
    
    # Increment the page counter
    page <- page + 1
  }
  
  # Convert the list of KPIs to a data frame
  if (length(all_kpis) > 0) {
    # Extract relevant fields and ensure consistent structure
    kpi_df <- do.call(rbind, lapply(all_kpis, function(x) {
      data.frame(
        id = x$id,
        title = x$title,
        municipality_type = x$municipality_type,
        stringsAsFactors = FALSE
      )
    }))
    return(kpi_df)
  } else {
    stop("No KPI data retrieved from Kolada")
  }
}

# Fetch all KPIs
all_kpis_df <- fetch_all_kpis()

# Check if the data frame has the necessary columns
if (!all(c("id", "title", "municipality_type") %in% colnames(all_kpis_df))) {
  stop("The expected columns 'id', 'title', and 'municipality_type' are not present in the data")
}

# Filter for KPIs with municipality_type "K"
filtered_kpis <- all_kpis_df[all_kpis_df$municipality_type == "K", ]

# Ensure there are results after filtering
if (nrow(filtered_kpis) == 0) {
  stop("No KPIs found with municipality_type 'K'")
}

# Keep only the ID and title columns
filtered_kpis <- filtered_kpis[, c("id", "title")]

# Save the filtered KPIs to a CSV file
write.csv(filtered_kpis, "filtered_kpis.csv", row.names = FALSE)

cat("Filtered KPI data saved to 'filtered_kpis.csv'")
