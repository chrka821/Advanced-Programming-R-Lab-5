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

library(here)
library(R6)
library(httr)
library(sf)
library(plotly)
library(ggplot2)
library(jsonlite)

kolada_handler <- R6Class("kolada_handler",
                       public = list(
                       initialize = function(){
                         
                       },
                       
                       #' @description
                       #' Parses the API response to be a usable R object.
                       #' @param response response as received from API endpoint
                       #' @return parsed_response through JSON parsing
                       
                       parse_response = function(response){
                         data <- content(response, as = "text")
                         parsed_data = fromJSON(data)
                         return (parsed_data)
                       },
                       
                       #' @description
                       #' Retrieves a list of available municipalities based on string input
                       #' and presumably fuzzy string matching. 
                       #' Response contains the id of the municipalities which are needed for further processing.
                       #' @param municipality_str Search string for municipality
                       #' @return list of municipalities with similar or equal name
                       
                       parse_municipality = function(municipality_str){
                         endpoint = "http://api.kolada.se/v2/municipality?title="
                         response <- GET(paste0(endpoint, municipality_str))
                         data = self$parse_response(response)
                         return (data)
                       },
                       
                       #' @description
                       #' Function that retrieves all information for a specific municipality
                       #' @param municipality_id integer id as used by kolada and retrieved by parse_municipality method
                       #' @return Information regarding municipality
                       get_municipality = function(municipality_id){
                         endpoint = "https://api.kolada.se/v2/data/municipality/"
                         response <- GET(paste0(endpoint, municipality_id))
                         data = self$parse_response(response)
                         return(data)
                       },
                       
                       #' @description
                       #' Takes a search string for a KPI and queries Kolada for it
                       #' @param kpi_string Search query for desired KPI
                       #' @return list of KPIs that include the KPI ID
                       parse_kpi = function(kpi_string){
                         endpoint = "http://api.kolada.se/v2/kpi?title="
                         response <- GET(paste0(endpoint, kpi_string))
                         data = self$parse_response(response)
                         return(data)
                       },
                       
                       #' @description
                       #' Takes a list of KPI IDs and queries Kolada for it
                       #' @param kpi_id KPI ID as used by Kolada
                       get_kpis = function(kpi_ids){
                         endpoint = "http://api.kolada.se/v2/data/kpi/"
                         response <- GET(paste0(endpoint, kpi_ids, "/year/2023"))
                         data = self$parse_response(response)
                         return(data$values)
                       },
                       
                       #' @description
                       #' 
                       #' @param kpi_ids list of KPIs to be fetched (can also be a single KPI)
                       #' @param municipality_id for what municipality this data is supposed to be fetched, 
                       #' if not specified it fetches the data for every municipality
                       #' @param year Year for which the data is supposed to be fetched
                       #' @return dataframe containing the fetched data
                       #' 
                       get_data = function(kpi_ids, municipality_id, year){
                         endpoint = "http://api.kolada.se/v2/data"
                         kpi_ids_string = paste(kpi_ids, collapse = ",")
                         endpoint_query = paste0(endpoint, "/kpi/", kpi_ids_string, "/municipality/", municipality_id, "/year/", year)
                         response <- GET(endpoint_query)
                         print(endpoint_query)
                         data = self$parse_response(response)
                         print(data)
                         return(data$values)
                       }

  )
)

#' @title Map Handler
#' @description Handler class for map plotting
#' @field shapefile_data A data frame containing shapefile data
#' @field shapefile_path The file path to the shapefile
#' @export

map_handler <- R6Class("map_handler",
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
                       #' @param title title for plot
                        
                       plot_data = function(merged_data, title){
                         p <- ggplot(data = merged_data) +
                           geom_sf(aes(fill = value, text = paste("Municipality: ", KOM_NAMN, "<br>", "Value: ", value))) +
                           scale_fill_viridis_c() +
                           theme_minimal() +
                           ggtitle(title)
                         p_interactive <- ggplotly(p, tooltip = "text")
                         print(p_interactive)
                       }
                       
  )
)

