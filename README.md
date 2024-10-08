# Advanced-Programming-R-Lab-5
<!-- badges: start -->
  [![R-CMD-check](https://github.com/chrka821/Advanced-Programming-R-Lab-5/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/chrka821/Advanced-Programming-R-Lab-5/blob/master/.github/workflows/R-CMD-check.yaml)
  <!-- badges: end -->

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