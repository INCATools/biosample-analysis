library(readr)
library(data.table)
library(tidyr)

row_frac = 0.3

# 1.5 minutes
start_time = Sys.time()
print(start_time)
harmonized_values_eav <-
  as.data.table(
    read_delim(
      "target/harmonized-values-eav.tsv",
      "\t",
      escape_double = FALSE,
      trim_ws = TRUE
    )
  )
end_time = Sys.time()
time_diff = end_time - start_time
print(time_diff)

hveav_rows = nrow(harmonized_values_eav)

####

row_count = hveav_rows * row_frac
row_subset = harmonized_values_eav[1:row_count,]

print(row_count)
start_time = Sys.time()
print(start_time)
harmonized_table <- dcast(row_subset, id ~ attribute)
end_time = Sys.time()
time_diff = end_time - start_time
print(time_diff)

unique_id_count    = length(unique(harmonized_values_eav$id))
unique_value_count = length(unique(harmonized_values_eav$value))
matrix_size = unique_id_count * unique_value_count

#  1645507 rows in 16.60114  secs
#  4936522 rows in  5.663576 secs ???
# 16455072 rows in 47.79537  secs
# 49365217 rows
# Error in CJ(1:5607170, 1:437) : 
#   Cross product of elements provided to CJ() would result in 2450333290 rows which exceeds .Machine$integer.max == 2147483647

row_count = hveav_rows * row_frac
row_subset = harmonized_values_eav[1:row_count,]

print(row_count)
start_time = Sys.time()
print(start_time)
harmonized_table <- pivot_wider(
  row_subset,
  id_cols = id,
  names_from = attribute,
  names_sort = FALSE,
  # names_repair = "check_unique",
  # values_from = value
  # values_fill = NULL,
  # values_fn = NULL,
  # ...
)
end_time = Sys.time()
time_diff = end_time - start_time
print(time_diff)

#  1645507 rows in  0.6903222 secs
#  4936522 rows in  8.627185  secs ???
# 16455072 rows in 31.41789  secs
# 49365217 rows



