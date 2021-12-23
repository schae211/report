
##### Command line args ##### 
cmd.arg = as.numeric(commandArgs(trailingOnly = TRUE))[1]

#####  Packages ##### 
library(mistyR)
library(future)
plan("multisession", workers=16)
library(tidyverse)

##### Paths ##### 
input.path <- "/net/data.isilon/ag-saez/bq_pschaefer/MISTY_VIEWS/mibi_tnbc/"
output.path <- "/net/data.isilon/ag-saez/bq_pschaefer/OUTPUT/mibi_tnbc/TBOOST_hyper/"
ifelse(!dir.exists(output.path), dir.create(output.path), FALSE)

#####  Input ##### 
misty.views.smp <- readRDS(paste0(input.path, "standard_views.RDS"))

##### Parameters ###### -> 10

# Learning Rate: Between 0 and 1, default = 0.3
etas <- c(0.1, 0.3, 0.5, 0.7, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3)

# Maximum depth of the constitutent trees: Defualt 6
max_depths <- c(6, 6, 6, 6, 1, 12, 6, 6, 6, 6)

# Minimum sum of instance weight (hessian) needed in a child, 
# i.e. the larger the more converating
min_child_weights <- c(1, 1, 1, 1, 1, 1, 2, 4, 1, 1)

# Fraction of training instances to sample
subsamples <- c(1, 1, 1, 1, 1, 1, 1, 1, 0.8, 0.6)

map(seq_len(length(etas)), ~ paste(etas[.x], max_depths[.x], 
                                   min_child_weights[.x], subsamples[.x],
                                   sep = "_"))


##### Run MISTy #####
out <- paste("TBOOST_hyper", etas[cmd.arg], max_depths[cmd.arg], 
             min_child_weights[cmd.arg], subsamples[cmd.arg], sep = "_")

purrr::iwalk(misty.views.smp, function(smp.views, smp.name) {
  run_misty(views = smp.views,
            results.folder = paste0(output.path, out, "/", smp.name),
            model.function = gradient_boosting_model,
            seed = 42,
            cv.folds = 10,
            booster = "gbtree",
            eta = etas[cmd.arg],
            max_depth = max_depths[cmd.arg],
            min_child_weight = min_child_weights[cmd.arg],
            subsample = subsamples[cmd.arg])
})
