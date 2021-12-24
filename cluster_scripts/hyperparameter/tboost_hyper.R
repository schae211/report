
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
  output.path <- "/net/data.isilon/ag-saez/bq_pschaefer/OUTPUT/synthetic/TBOOST_hyper/"
} else if (cmd.arg1 == 2) {
  input.path <- "/net/data.isilon/ag-saez/bq_pschaefer/MISTY_VIEWS/mibi_tnbc/"
  input <- "standard_views.RDS"
  output.path <- "/net/data.isilon/ag-saez/bq_pschaefer/OUTPUT/mibi_tnbc/TBOOST_hyper/"
} else if (cmd.arg1 == 3) {
  input.path <- "/net/data.isilon/ag-saez/bq_pschaefer/MISTY_VIEWS/merfish_bc/"
  input <- "hvg_views.RDS"
  output.path <- "/net/data.isilon/ag-saez/bq_pschaefer/OUTPUT/merfish_bc/TBOOST_hyper"
}
ifelse(!dir.exists(output.path), dir.create(output.path), FALSE)

#####  Input ##### 
misty.views.smp <- readRDS(paste0(input.path, input))

##### Parameters ###### -> 12

# Maximum Boosting Rounds
nroundss <- c(10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 5, 20)

# Learning Rate: Between 0 and 1, default = 0.3
etas <- c(0.1, 0.3, 0.5, 0.7, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3)

# Maximum depth of the constitutent trees: Defualt 6
max_depths <- c(6, 6, 6, 6, 1, 12, 6, 6, 6, 6, 6, 6)

# Minimum sum of instance weight (hessian) needed in a child, 
# i.e. the larger the more converating
min_child_weights <- c(1, 1, 1, 1, 1, 1, 2, 4, 1, 1, 1, 1)

# Fraction of training instances to sample
subsamples <- c(1, 1, 1, 1, 1, 1, 1, 1, 0.8, 0.6, 1, 1)

map(seq_len(length(etas)), ~ paste(nroundss[.x], etas[.x], max_depths[.x], 
                                   min_child_weights[.x], subsamples[.x],
                                   sep = "_"))


##### Run MISTy #####
out <- paste("TBOOST_hyper", nroundss[cmd.arg2], etas[cmd.arg2], max_depths[cmd.arg2], 
             min_child_weights[cmd.arg2], subsamples[cmd.arg2], sep = "_")

purrr::iwalk(misty.views.smp, function(smp.views, smp.name) {
  run_misty(views = smp.views,
            results.folder = paste0(output.path, out, "/", smp.name),
            model.function = gradient_boosting_model,
            seed = 42,
            cv.folds = 10,
            booster = "gbtree",
            nrounds = nroundss[cmd.arg2],
            eta = etas[cmd.arg2],
            max_depth = max_depths[cmd.arg2],
            min_child_weight = min_child_weights[cmd.arg2],
            subsample = subsamples[cmd.arg2])
})
