
##### Command line args ##### 
cmd.arg1 = as.numeric(commandArgs(trailingOnly = TRUE))[1]

cmd.arg2 = as.numeric(commandArgs(trailingOnly = TRUE))[2]

#####  Packages ##### 
library(mistyR)
library(future)
plan("multisession")
library(tidyverse)

##### Paths ##### 
if (cmd.arg1 == 1) {
  input.path <- "/net/data.isilon/ag-saez/bq_pschaefer/MISTY_VIEWS/synthetic/"
  input <- "l12.RDS"
  output.path <- "/net/data.isilon/ag-saez/bq_pschaefer/OUTPUT/synthetic/RF_hyper/"
} else if (cmd.arg1 == 2) {
  input.path <- "/net/data.isilon/ag-saez/bq_pschaefer/MISTY_VIEWS/mibi_tnbc/"
  input <- "standard_views.RDS"
  output.path <- "/net/data.isilon/ag-saez/bq_pschaefer/OUTPUT/mibi_tnbc/RF_hyper/"
} else if (cmd.arg1 == 3) {
  input.path <- "/net/data.isilon/ag-saez/bq_pschaefer/MISTY_VIEWS/merfish_bc/"
  input <- "hvg_views.RDS"
  output.path <- "/net/data.isilon/ag-saez/bq_pschaefer/OUTPUT/merfish_bc/RF_hyper"
}
ifelse(!dir.exists(output.path), dir.create(output.path), FALSE)

#####  Input ##### 
misty.views.smp <- readRDS(paste0(input.path, input))

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
out <- paste("RF_hyper", number.trees[cmd.arg2], min.node.sizes[cmd.arg2], 
             max.depths[cmd.arg2], splitrules[cmd.arg2], sep = "_")

purrr::iwalk(misty.views.smp, function(smp.views, smp.name) {
  run_misty(views = smp.views,
            results.folder = paste0(output.path, out, "/", smp.name),
            model.function = random_forest_model,
            seed = 42,
            cv.folds = 10,
            num.trees = number.trees[cmd.arg2],
            min.node.size = min.node.sizes[cmd.arg2],
            max.depth = max.depths[cmd.arg2],
            splitrule = splitrules[cmd.arg2])
})

