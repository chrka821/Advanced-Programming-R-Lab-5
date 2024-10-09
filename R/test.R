source("R/main.R")

#' @importFrom httr GET content
#' @importFrom jsonlite fromJSON
#' @importFrom R6 R6Class
#' @importFrom sf st_read
#' @importFrom dplyr inner_join
#' @importFrom plotly ggplotly
#' @importFrom ggplot2 ggplot

## Example usage
api_handler = kolada_handler$new()
map_handler = map_handler$new()
kolada_data = api_handler$get_kpi("N00923") # life expectancy data

if (class(kolada_data) == "list") {
  kolada_data <- as.data.frame(kolada_data)
}

kolada_data$value <- sapply(kolada_data$values, function(x) x$value)

merged_data = map_handler$merge_data(kolada_data = kolada_data)
map_handler$plot_data(merged_data, "Life expectancy for men")