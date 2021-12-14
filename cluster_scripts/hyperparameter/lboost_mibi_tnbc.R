
##### Command line args ##### 
cmd.arg = as.numeric(commandArgs(trailingOnly = TRUE))[1]

##### Start Time #####
start <- Sys.time()
timing.file <- "/net/data.isilon/ag-saez/bq_pschaefer/OUTPUT/mibi_tnbc/LBOOST_hyper/timing.txt"

#####  Packages ##### 
library(mistyR)
library(future)
plan("multisession", workers=16)
library(tidyverse)

##### Paths ##### 
input.path <- "/net/data.isilon/ag-saez/bq_pschaefer/MISTY_VIEWS/mibi_tnbc/"
output.path <- "/net/data.isilon/ag-saez/bq_pschaefer/OUTPUT/mibi_tnbc/LBOOST_hyper/"
ifelse(!dir.exists(output.path), dir.create(output.path), FALSE)

#####  Input ##### 
misty.views.smp <- readRDS(paste0(input.path, "standard_views.RDS"))

##### Parameters ###### -> 7

# L2 regularization term on weights: Default: 0
lambdas <- c(0, 0.5, 1, 5, 0, 0, 0)

# L1 regularization term on weights: Default: 0
alphas <- c(0, 0, 0, 0, 0.5, 1, 5)

map(seq_len(length(lambdas)), ~ paste(lambdas[.x], alphas[.x],
                                   sep = "_"))


##### Run MISTy #####
out <- paste("LBOOST_hyper", lambdas[cmd.arg], alphas[cmd.arg], sep = "_")

purrr::walk2(misty.views.smp, names(misty.views.smp), function(smp.views, smp.name) {
  run_misty(views = smp.views,
            results.folder = paste0(output.path, out, "/", smp.name),
            model.function = gradient_boosting_model,
            seed = 42,
            cv.folds = 10,
            booster = "gblinear",
            lambda = lambdas[cmd.arg],
            alpha = alphas[cmd.arg])
})

##### End Time #####
end <- Sys.time()
difference <- end - start
# it is just important that I take care of this timing file while reading 
# the results.
write(paste0(out, ", ", difference), file = timing.file, append = TRUE)
