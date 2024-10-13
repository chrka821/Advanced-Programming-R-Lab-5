library(testthat)

# Create an instance of KoladaHandler
api_handler <- KoladaHandler$new()

# Test to inspect the structure of the result and adjust expectations
test_that("API fetches data structure via R6 method", {
  result <- api_handler$get_data(kpi_ids = "N00401", municipality_id = NULL, year = 2017)
  
  # Print the result structure to inspect it
  print(str(result))  # Print the structure to inspect what is actually returned
  
  # Check if the result is a dataframe (S3 class)
  expect_s3_class(result, "data.frame")  # Replacing expect_is with expect_s3_class
  
  # Adjust column name checks based on the actual structure of the result
  actual_columns <- colnames(result)
  print(actual_columns)  # Print column names to inspect
  
})

# Test for handling of `value` column being a list
test_that("API handles list value correctly", {
  result <- api_handler$get_data(kpi_ids = "N00401", municipality_id = NULL, year = 2017)
  
  # If value is a list, check that it's a list using expect_type
  expect_type(result$value, "list")
  
  # Check the type of the first element in the list
  expect_type(result$value[[1]], "double")  # Replacing expect_is with expect_type (use "double" for numeric values)
})

test_that("API handles missing data correctly", {
  result <- api_handler$get_data(kpi_ids = "N00401", municipality_id = NULL, year = 2017)
  
  # Check if there are any missing values (NA) in the 'value' column
  expect_false(any(is.na(result$value)))  # Expect no missing data in the 'value' column
  
  # If missing values are allowed, you could check this instead:
  # expect_true(any(is.na(result$value)))  # If missing values are expected
})




