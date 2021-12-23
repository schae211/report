
##### Start ##### 

print("--------------------------------------------------")

##### Verbosity #####
print("Merfish Liver Analysis")

##### Command line args ##### 
# argument specifying the input
cmd.arg1 = as.numeric(commandArgs(trailingOnly = TRUE))[1]
print(cmd.arg1)

# argument specifying the algorithm
cmd.arg2 = as.numeric(commandArgs(trailingOnly = TRUE))[2]
print(cmd.arg2)

##### Paths ##### 
input.path <- "/net/data.isilon/ag-saez/bq_pschaefer/MISTY_VIEWS/merfish_liver/"

if (cmd.arg1 == 1) {
  output.path <- "/net/data.isilon/ag-saez/bq_pschaefer/OUTPUT/merfish_liver/std280/"
} else if (cmd.arg1 == 2) {
  output.path <- "/net/data.isilon/ag-saez/bq_pschaefer/OUTPUT/merfish_liver/hvg/"
} else if (cmd.arg1 == 3) {
  output.path <- "/net/data.isilon/ag-saez/bq_pschaefer/xxx"
}
ifelse(!dir.exists(output.path), dir.create(output.path), FALSE)

##### Packages ##### 
library(mistyR)
library(future)
plan("multisession")
library(tidyverse)

##### Input ##### 
print("Readining Data")
if (cmd.arg1 == 1) {
  input.views <- "standard280_views.RDS"
} else if (cmd.arg1 == 2) {
  input.views <- "hvg_views.RDS"
} else if (cmd.arg1 == 3) {
  input.views <- "xxx"
}
misty.views.smp <- readRDS(paste0(input.path, input.views))

##### Run MISTy #####
if (cmd.arg2 == 1) {
  purrr::walk2(misty.views.smp, names(misty.views.smp), function(smp.views, smp.name) {
    run_misty(views = smp.views,
              results.folder = paste0(output.path, "RF/",smp.name),
              model.function = random_forest_model,
              seed = 42,
              cv.folds = 10)
  })
} else if (cmd.arg2 == 2) {
  purrr::walk2(misty.views.smp, names(misty.views.smp), function(smp.views, smp.name) {
    run_misty(views = smp.views,
              results.folder = paste0(output.path, "BGMARS/",smp.name),
              model.function = bagged_mars_model,
              seed = 42,
              cv.folds = 10,
              n.bags = 20)
  })
} else if (cmd.arg2 == 3) {
  purrr::walk2(misty.views.smp, names(misty.views.smp), function(smp.views, smp.name) {
    run_misty(views = smp.views,
              results.folder = paste0(output.path, "MARS/",smp.name),
              model.function = mars_model,
              seed = 42,
              cv.folds = 10)
  })
} else if (cmd.arg2 == 4) {
  purrr::walk2(misty.views.smp, names(misty.views.smp), function(smp.views, smp.name) {
    run_misty(views = smp.views,
              results.folder = paste0(output.path, "LM/",smp.name),
              model.function = linear_model,
              seed = 42,
              cv.folds = 10)
  })
} else if (cmd.arg2 == 5) {
  purrr::walk2(misty.views.smp, names(misty.views.smp), function(smp.views, smp.name) {
    run_misty(views = smp.views,
              results.folder = paste0(output.path, "TBOOST/",smp.name),
              model.function = gradient_boosting_model,
              seed = 42,
              cv.folds = 10,
              booster = "gbtree")
  })
} else if (cmd.arg2 == 6) {
  purrr::walk2(misty.views.smp, names(misty.views.smp), function(smp.views, smp.name) {
    run_misty(views = smp.views,
              results.folder = paste0(output.path, "LBOOST/",smp.name),
              model.function = gradient_boosting_model,
              seed = 42,
              cv.folds = 10,
              booster = "gblinear")
  })
} else if (cmd.arg2 == 7) {
  purrr::walk2(misty.views.smp, names(misty.views.smp), function(smp.views, smp.name) {
    run_misty(views = smp.views,
              results.folder = paste0(output.path, "SVM/",smp.name),
              model.function = svm_model,
              seed = 42,
              cv.folds = 10)
  })
} else if (cmd.arg2 == 8) {
  purrr::walk2(misty.views.smp, names(misty.views.smp), function(smp.views, smp.name) {
    run_misty(views = smp.views,
              results.folder = paste0(output.path, "MLP/",smp.name),
              model.function = mlp_model,
              seed = 42,
              cv.folds = 10)
  })
}
