
##### Command line args ##### 
cmd.arg = as.numeric(commandArgs(trailingOnly = TRUE))[1]

#####  Packages ##### 
library(mistyR)
library(future)
plan("multisession", workers=16)
library(tidyverse)
library(tiff)

##### Paths ##### 
input.path <- "/net/data.isilon/ag-saez/bq_pschaefer/MISTY_VIEWS/mibi_tnbc/"
output.path <- "/net/data.isilon/ag-saez/bq_pschaefer/OUTPUT/mibi_tnbc/RF_hyper/"
ifelse(!dir.exists(output.path), dir.create(output.path), FALSE)

#####  Input ##### 
misty.views.smp <- readRDS(paste0(input.path, "standard_views.RDS"))

##### Parameters ###### -> 10

# Number of Trees: 50, 100, 200, 500
number.trees <- c(50, 100, 200, 500, 100, 100, 100, 100, 100, 100)

# Minimum number of instances per node: default 5
min.node.sizes <- c(5, 5, 5, 5, 5, 5, 1, 50, 5, 5)

# Maximum depth of the constitutent trees: default 0 for unlimited, 1 for stumps
max.depths <- c(0, 0, 0, 0, 0, 0, 0, 0, 1, 10)

# Splitrule: "variance", "extratrees"
splitrules <- c("variance", "variance", "variance", "variance", "extratrees",
                "maxstat", "variance", "variance", "variance", "variance")

map(seq_len(length(number.trees)), ~ paste(number.trees[.x], min.node.sizes[.x], 
                                        max.depths[.x], splitrules[.x],
                                           sep = "_"))


##### Run MISTy #####
out <- paste("RF_hyper", number.trees[cmd.arg], min.node.sizes[cmd.arg], 
             max.depths[cmd.arg], splitrules[cmd.arg], sep = "_")

purrr::iwalk(misty.views.smp, function(smp.views, smp.name) {
  run_misty(views = smp.views,
            results.folder = paste0(output.path, out, "/", smp.name),
            model.function = random_forest_model,
            seed = 42,
            cv.folds = 10,
            num.trees = number.trees[cmd.arg],
            min.node.size = min.node.sizes[cmd.arg],
            max.depth = max.depths[cmd.arg],
            splitrule = splitrules[cmd.arg])
})
