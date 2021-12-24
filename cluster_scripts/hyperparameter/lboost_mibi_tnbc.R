
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
  output.path <- "/net/data.isilon/ag-saez/bq_pschaefer/OUTPUT/synthetic/LBOOST_hyper/"
} else if (cmd.arg1 == 2) {
  input.path <- "/net/data.isilon/ag-saez/bq_pschaefer/MISTY_VIEWS/mibi_tnbc/"
  input <- "standard_views.RDS"
  output.path <- "/net/data.isilon/ag-saez/bq_pschaefer/OUTPUT/mibi_tnbc/LBOOST_hyper/"
} else if (cmd.arg1 == 3) {
  input.path <- "/net/data.isilon/ag-saez/bq_pschaefer/MISTY_VIEWS/merfish_bc/"
  input <- "hvg_views.RDS"
  output.path <- "/net/data.isilon/ag-saez/bq_pschaefer/OUTPUT/merfish_bc/LBOOST_hyper"
}
ifelse(!dir.exists(output.path), dir.create(output.path), FALSE)

#####  Input ##### 
misty.views.smp <- readRDS(paste0(input.path, input))

##### Parameters ###### -> 8

# Maximum Boosting Rounds
nroundss <- c(2, 4, 8, 16, 32, 10, 10, 10)

# L2 regularization term on weights: Default: 0
lambdas <- c(0, 0, 0, 0, 0, 0.5, 0, 0)

# L1 regularization term on weights: Default: 0
alphas <- c(0, 0, 0, 0, 0, 0 , 1, 5)

map(seq_len(length(lambdas)), ~ paste(nroundss[.x], lambdas[.x], alphas[.x],
                                   sep = "_"))


##### Run MISTy #####
out <- paste("LBOOST_hyper", nroundss[cmd.arg2], lambdas[cmd.arg2], 
             alphas[cmd.arg2], sep = "_")

purrr::iwalk(misty.views.smp, function(smp.views, smp.name) {
  run_misty(views = smp.views,
            results.folder = paste0(output.path, out, "/", smp.name),
            model.function = gradient_boosting_model,
            seed = 42,
            cv.folds = 10,
            booster = "gblinear",
            nrounds = nroundss[cmd.arg2],
            lambda = lambdas[cmd.arg2],
            alpha = alphas[cmd.arg2])
})
