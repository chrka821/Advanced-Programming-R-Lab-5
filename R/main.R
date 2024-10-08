#' @importFrom httr GET content
#' @importFrom jsonlite fromJSON
#' @importFrom R6 R6Class


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
                       }
  )
)


api_handler = kolada_handler$new()
print(api_handler$parse_municipality("Köping"))
