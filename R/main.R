#' @importFrom httr GET content
#' @importFrom jsonlite fromJSON
#' @importFrom R6 R6Class
#' @importFrom sf st_read
#' @importFrom dplyr inner_join %>%
#' @importFrom plotly ggplotly
#' @importFrom ggplot2 ggplot geom_sf aes scale_fill_viridis_c theme_minimal ggtitle
#' @title Kolada Handler
#' @description An R6 class to handle data retrieval from Kolada API
#' @export

KoladaHandler <- R6Class("kolada_handler",
                       public = list(
                       initialize = function(){
                         
                       },
                       
                       #' @description
                       #' Parses the API response to be a usable R object.
                       #' @param response response as received from API endpoint
                       #' @return parsed_response through JSON parsing
                       
                       parse_response = function(response){
                         data <- content(response, as = "text")
                         parsed_data <- fromJSON(data)$values
                         parsed_data_df <- as.data.frame(parsed_data, stringsAsFactors = FALSE)
                         return (parsed_data_df)
                       },
                       
                       #' @description
                       #' Takes a search string for a KPI and queries Kolada for it
                       #' @param kpi_string Search query for desired KPI
                       #' @return list of KPIs that include the KPI ID
                       parse_kpi = function(kpi_string){
                         kpi_string <- gsub(" ", "%", kpi_string) # url encode spaces
                         endpoint <- "http://api.kolada.se/v2/kpi?title="
                         response <- GET(paste0(endpoint, kpi_string))
                         data <- self$parse_response(response)
                         
                         if (nrow(data) > 0){
                         data <- filter(data, municipality_type == "K") # Filter for only kommuns
                         }
                         return(data)
                         
                       },
                       
                       
                       #' @description
                       #' Get data fetches a list of KPis for a municipalitry
                       #' @param kpi_ids list of KPIs to be fetched (can also be a single KPI)
                       #' @param municipality_ids for what municipality this data is supposed to be fetched,
                       #' if it is a list of length 0, it is fetched for all municipalities
                       #' @param year Year for which the data is supposed to be fetched
                       #' @return dataframe containing the fetched data
                       #' 
                       get_data = function(kpi_ids, municipality_ids, year) {
                         endpoint = "http://api.kolada.se/v2/data"
                         kpi_ids_string = paste(kpi_ids, collapse = ",")
                         endpoint_query = paste0(endpoint, "/kpi/", kpi_ids_string)
      
                         if (length(municipality_ids) > 0) {
                           municipality_ids_string = paste(municipality_ids, collapse = ",")
                           endpoint_query = paste0(endpoint_query, "/municipality/", municipality_ids_string)
                         }
                         
                         endpoint_query = paste0(endpoint_query, "/year/", year)
                         response <- GET(endpoint_query)
                         parsed_data = self$parse_response(response)
                         if(nrow(parsed_data) > 0){
                           # Extract the "T" aka total value from the values column
                           parsed_data$value <- lapply(parsed_data$values, function(value_list) {
                             if (is.data.frame(value_list) && "gender" %in% colnames(value_list)) {
                               # Get the row where gender is "T" (Total)
                               t_value_row <- value_list[value_list$gender == "T", "value"]
                               if (length(t_value_row) == 0) {
                                 return(NA)  # If "T" is not found, return NA
                               } else {
                                 return(t_value_row)
                               }
                             } else {
                               return(NA)  # If the values column is not in the expected format, return NA
                             }
                           })
                           parsed_data <- subset(parsed_data, select=c("kpi", "municipality", "period", "value"))
                         }
                         return(parsed_data)
                       }
                       

  )
)

#' @title Map Handler
#' @description Handler class for map plotting
#' @field shapefile_data A data frame containing shapefile data
#' @field shapefile_path The file path to the shapefile
#' @export

MapHandler <- R6Class("map_handler",
                       public = list(
                         shapefile_data = NULL,
                         shapefile_path = NULL,
                         
                         #' @description
                         #' Method that loads the shape file responsible for plotting the map
                         #' @param path File location of shape file
                         #' @return Loaded shape file
                         load_shapefile = function(path){
                           return(st_read(path))
                         },
                         
                         #' @description
                         #' Constructor function for map handler
                         
                         initialize = function(){
                           self$shapefile_path = here("resources/shapefiles/alla_kommuner.shp")
                           self$shapefile_data = self$load_shapefile(self$shapefile_path)
                         },
                         
                         #' @description
                         #' Merges shape file data with KPI data retrieved from Kolada
                         #' @param kolada_data Data frame that contains the data from Kolada
                         #' @return Data frame that contains both the shape and KPI data
                         merge_data = function(kolada_data){
                           merged_data <- self$shapefile_data %>%
                             inner_join(kolada_data, by = c("ID" = "municipality"))
                         },
                         
                         
                         
                         #' @description
                         #' Plots a map of the KPI data including tooltip
                         #' @param merged_data Dataframe that contains both shape data and KPI data
                         #' @param title Title for the plot
                         plot_data = function(merged_data = NULL, title = "Map") {                             merged_data$value <- as.numeric(merged_data$value) # convert non numeric characters
                             p <- ggplot(data = merged_data) +
                               geom_sf(aes(fill = value, text = paste("Municipality: ", KOM_NAMN, "<br>", "Value: ", value))) +
                               scale_fill_viridis_c(na.value = "grey") + # Set a color for NA values
                               theme_minimal() +
                               ggtitle(title)
                             p <- ggplotly(p, tooltip = "text")
                             print(p)
                         },
                         
                         highlight_municipality = function(municipality_name, municipality_id) {
                           
                           # Create a copy of the shapefile data to avoid altering the original
                           shapefile_copy <- self$shapefile_data %>%
                             mutate(highlight = ifelse(ID == municipality_id, "red", "grey"))
                           
                           # Plot the map
                          p <- ggplot() +
                             geom_sf(data = shapefile_copy, aes(fill = highlight), color = "black") +
                             scale_fill_identity() +
                             theme_minimal() +
                             ggtitle(municipality_name)
                          print(p)
                         },
                         
                         empty_map = function(){
                           p <- ggplot() +
                             geom_sf(data = self$shapefile_data, fill = "grey", color = "black") +
                             theme_minimal() +
                             ggtitle("Map of Sweden")
                           print(p)
                         }
                         
                       
)
                       
  )

api_handler = KoladaHandler$new()
api_handler$parse_kpi("mäasasn")
