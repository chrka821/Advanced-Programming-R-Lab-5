#' @importFrom httr GET content
#' @importFrom jsonlite fromJSON
#' @importFrom R6 R6Class
#' @importFrom sf st_read
#' @importFrom dplyr inner_join
kolada_handler <- R6Class("kolada_handler",
                       public = list(
                       
                       #' @description
                       #' Constructor function for the kolada handler
                       #' Takes no arguments as there is no requirement for an API key
                       #' All calls to the API endpoints are made through a kolada_handler instance.
                       #' @return A kolada_handler object which interacts with the API endpoints
                       #' @export
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
                       #' @@return Information regarding municipality
                       get_municipality = function(municipality_id){
                         endpoint = "https://api.kolada.se/v2/data/municipality/"
                         response <- GET(paste0(endpoint, municipality_id))
                         data = self$parse_response(response)
                         return(data)
                       },
                       
                       parse_kpi = function(kpi_string){
                         endpoint = "http://api.kolada.se/v2/kpi?title="
                         response <- GET(paste0(endpoint, kpi_string))
                         data = self$parse_response(response)
                         return(data)
                       },
                       
                       get_kpi = function(kpi_id){
                         endpoint = "http://api.kolada.se/v2/data/kpi/"
                         print(paste0(endpoint, kpi_id))
                         response <- GET(paste0(endpoint, kpi_id, "/year/2023"))
                         data = self$parse_response(response)
                         return(data$values)
                       }
  )
)

map_handler <- R6Class("map_handler",
                       public = list(
                         shapefile_data = NULL,
                         shapefile_path = NULL,
                        
                       load_shapefile = function(path){
                         return(st_read(path))
                       },
                         
                       initialize = function(){
                         self$shapefile_path = "../Advanced-Programming-R-Lab-5/resources/shapefiles/alla_kommuner.shp"
                         self$shapefile_data = self$load_shapefile(self$shapefile_path)
                       },
                       
                       merge_data = function(kolada_data){
                         merged_data <- shapefile_data %>%
                           inner_join(kolada_data, by = c("ID" = "municipality"))
                       },
                       
                       plot_data = function(merged_data){
                         p <- ggplot(data = merged_data) +
                           geom_sf(aes(fill = value)) +
                           scale_fill_viridis_c() +
                           theme_minimal() +
                           ggtitle("Random Data Plot for Swedish Counties")
                         print(p)
                       }
                       
                       
                       
                       
  )
)


# Example usage
api_handler = kolada_handler$new()
map_handler = map_handler$new()
kolada_data = api_handler$get_kpi("N00923") # life expectancy data

if (class(kolada_data) == "list") {
  kolada_data <- as.data.frame(kolada_data)
}

kolada_data$value <- sapply(kolada_data$values, function(x) x$value)

merged_data = map_handler$merge_data(kolada_data = kolada_data)
map_handler$plot_data(merged_data)
