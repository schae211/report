
##### Verbosity ##### 
print("merfish tnbc prep")

##### Packages ##### 
library(mistyR)
library(future)
plan("multisession", workers=24)
library(tidyverse)
library(zellkonverter)

##### Paths ##### 
input.path <- "/net/data.isilon/ag-saez/bq_pschaefer/DATA/merfish_bc"
output.path <- "/net/data.isilon/ag-saez/bq_pschaefer/MISTY_VIEWS/merfish_bc/"
ifelse(!dir.exists(output.path), dir.create(output.path), FALSE)

##### Input ##### 
print("Reading data")
files <- list.files(input.path, full.names = TRUE)
files.h5ad <- files[str_ends(files, ".h5ad")]
sample.names <- map_chr(files.h5ad, ~ str_extract(.x, "HTAPP-[0-9]+-SMP-[0-9]+"))
print(sample.names)
sample.data <- map(files.h5ad, ~ readH5AD(.x))

##### MISTy Views #####
print("Computing MISTy views")
misty.views.smp <- map(sample.data, function(smp.data) {
  # Extract relevant data
  expr <- tibble::as_tibble(t(smp.data@assays@data$X), .name_repair = "universal")
  pos <- tibble::tibble(x_orig = smp.data$x_orig, y_orig = smp.data$y_orig)
  
  misty.views <- create_initial_view(expr) %>%
    add_juxtaview(pos) %>%
    add_paraview(pos, l = 100, zoi = 15)
}) %>% setNames(sample.names)

saveRDS(misty.views.smp, file = paste0(output.path, "standard_views.RDS"))

