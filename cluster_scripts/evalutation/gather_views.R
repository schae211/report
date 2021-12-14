
##### TODO #####
# Check that the results are properly extracted
# Check why certain runs failed (just because of the cluster?)

##### Packages #####
library(mistyR)
library(future)
library(tidyverse)
plan("multisession", workers=24)

##### Paths #####
input.path <- "/net/data.isilon/ag-saez/bq_pschaefer/MISTY_VIEWS/"
output.path <- "/net/data.isilon/ag-saez/bq_pschaefer/"

d <- format(Sys.time(), "%Y-%m-%d-%H-%M")
output.object <- paste0(d, "_all_views.RDS")

##### Directories #####
experiments <- list.dirs(input.path, recursive = FALSE) 

views <- map(experiments, function(experiment) {
  list.files(experiment, full.names = TRUE)
}) %>% unlist

names(views) <- map_chr(views, ~ str_extract(.x, "(?<=/net/data.isilon/ag-saez/bq_pschaefer/MISTY_VIEWS/)[^\\.]+"))

read.views <- map(views, function(view) {
  readRDS(view)
})

saveRDS(read.views, file=paste0(output.path, output.object))

