
##### Verbosity ##### 
print("synthetic prep")

##### Packages ##### 
library(mistyR)
library(future)
plan("multisession", workers=24)
library(tidyverse)

##### Paths ##### 
output.path <- "/net/data.isilon/ag-saez/bq_pschaefer/MISTY_VIEWS/synthetic/"
ifelse(!dir.exists(output.path), dir.create(output.path), FALSE)

##### Input ##### 
data("synthetic")

#####  MISTy Views ##### 

# l = 6
standard.views <- purrr::map(synthetic, function(sample) {
  sample.expr <- sample %>% dplyr::select(-c(row, col, type))
  sample.pos <- sample %>% dplyr::select(row, col)
  create_initial_view(sample.expr) %>% add_paraview(sample.pos, l = 6)
})

saveRDS(standard.views, file = paste0(output.path, "l6.RDS"))

# l = 12
standard.views <- purrr::map(synthetic, function(sample) {
  sample.expr <- sample %>% dplyr::select(-c(row, col, type))
  sample.pos <- sample %>% dplyr::select(row, col)
  create_initial_view(sample.expr) %>% add_paraview(sample.pos, l = 12)
})

saveRDS(standard.views, file = paste0(output.path, "l12.RDS"))

# l = 24
standard.views <- purrr::map(synthetic, function(sample) {
  sample.expr <- sample %>% dplyr::select(-c(row, col, type))
  sample.pos <- sample %>% dplyr::select(row, col)
  create_initial_view(sample.expr) %>% add_paraview(sample.pos, l = 24)
})

saveRDS(standard.views, file = paste0(output.path, "l24.RDS"))

