
##### Verbosity ##### 
print("Merfish TNBC Analysis HVG")

##### Command line args ##### 
cmd.arg = as.numeric(commandArgs(trailingOnly = TRUE))[1]

##### Paths ##### 
# input.path <- "/home/philipp/data/saez/htapp/"
input.path <- "/net/data.isilon/ag-saez/bq_pschaefer/MISTY_VIEWS/merfish_bc/"
output.path <- "/net/data.isilon/ag-saez/bq_pschaefer/OUTPUT/merfish_bc/hvg/"
ifelse(!dir.exists(output.path), dir.create(output.path), FALSE)

##### Packages ##### 
library(mistyR)
library(future)
plan("multisession", workers = 20)
library(tidyverse)

##### Input ##### 
print("Readining Data")
misty.views.smp <- readRDS(paste0(input.path, "hvg_views.RDS"))

##### Run MISTy #####
if (cmd.arg == 1) {
  purrr::walk2(misty.views.smp, names(misty.views.smp), function(smp.views, smp.name) {
    run_misty(views = smp.views,
              results.folder = paste0(output.path, "RF/",smp.name),
              model.function = random_forest_model,
              seed = 42,
              cv.folds = 10)
  })
} else if (cmd.arg == 2) {
  purrr::walk2(misty.views.smp, names(misty.views.smp), function(smp.views, smp.name) {
    run_misty(views = smp.views,
              results.folder = paste0(output.path, "BGMARS/",smp.name),
              model.function = bagged_mars_model,
              seed = 42,
              cv.folds = 10,
              n.bags = 20)
  })
} else if (cmd.arg == 3) {
  purrr::walk2(misty.views.smp, names(misty.views.smp), function(smp.views, smp.name) {
    run_misty(views = smp.views,
              results.folder = paste0(output.path, "MARS/",smp.name),
              model.function = mars_model,
              seed = 42,
              cv.folds = 10)
  })
} else if (cmd.arg == 4) {
  purrr::walk2(misty.views.smp, names(misty.views.smp), function(smp.views, smp.name) {
    run_misty(views = smp.views,
              results.folder = paste0(output.path, "LM/",smp.name),
              model.function = linear_model,
              seed = 42,
              cv.folds = 10)
  })
} else if (cmd.arg == 5) {
  purrr::walk2(misty.views.smp, names(misty.views.smp), function(smp.views, smp.name) {
    run_misty(views = smp.views,
              results.folder = paste0(output.path, "TBOOST/",smp.name),
              model.function = gradient_boosting_model,
              seed = 42,
              cv.folds = 10,
              booster = "gbtree")
  })
} else if (cmd.arg == 6) {
  purrr::walk2(misty.views.smp, names(misty.views.smp), function(smp.views, smp.name) {
    run_misty(views = smp.views,
              results.folder = paste0(output.path, "LBOOST/",smp.name),
              model.function = gradient_boosting_model,
              seed = 42,
              cv.folds = 10,
              booster = "gblinear")
  })
} else if (cmd.arg == 7) {
  purrr::walk2(misty.views.smp, names(misty.views.smp), function(smp.views, smp.name) {
    run_misty(views = smp.views,
              results.folder = paste0(output.path, "SVM/",smp.name),
              model.function = svm_model,
              seed = 42,
              cv.folds = 10)
  })
} else if (cmd.arg == 8) {
  purrr::walk2(misty.views.smp, names(misty.views.smp), function(smp.views, smp.name) {
    run_misty(views = smp.views,
              results.folder = paste0(output.path, "MLP/",smp.name),
              model.function = mlp_model,
              seed = 42,
              cv.folds = 10)
  })
}
