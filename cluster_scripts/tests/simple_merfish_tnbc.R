
##### Verbosity ##### 
print("merfish tnbc prep")

##### Paths ##### 
# input.path <- "/home/philipp/data/saez/htapp/"
input.path <- "/net/data.isilon/ag-saez/bq_pschaefer/DATA/htapp"
output.path <- "/net/data.isilon/ag-saez/bq_pschaefer/MISTY_VIEWS/merfish_tnbc/"
ifelse(!dir.exists(output.path), dir.create(output.path), FALSE)

##### Packages ##### 
library(mistyR)
library(tidyverse)

##### Input ##### 
print("Reading data")
files <- list.files(input.path, full.names = TRUE)
print(files)
files.h5ad <- files[str_ends(files, ".h5ad")]
print(files.h5ad)

sample.names <- purrr::map_chr(files.h5ad, ~ str_extract(.x, "HTAPP-[0-9]+-SMP-[0-9]+"))
print(sample.names)

sample.data <- list()
for (file in files.h5ad) {
  print(file)
  smp.data <- zellkonverter::readH5AD(file)
  sample.data(file = smp.data)
}

# sample.data <- purrr::map(files.h5ad, function(file) {
#   print(file)
#   zellkonverter::readH5AD(file) 
#   })
# str(sample.data)

library(future)
plan("multisession", workers=16)


