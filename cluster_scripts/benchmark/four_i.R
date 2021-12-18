
##### Verbosity ##### 
print("Four I Analysis, High Resolution")

##### Command line args ##### 
# argument specifiying the input
cmd.arg1 = as.numeric(commandArgs(trailingOnly = TRUE))[1]
print(cmd.arg1)

# argument specifying the algorithm
cmd.arg2 = as.numeric(commandArgs(trailingOnly = TRUE))[2]
print(cmd.arg2)

##### Paths ##### 
input.path <- "/net/data.isilon/ag-saez/bq_pschaefer/MISTY_VIEWS/4iANCA/"

if (cmd.arg1 == 1) {
  output.path <- "/net/data.isilon/ag-saez/bq_pschaefer/OUTPUT/4iANCA/ratio_153/"
} else if (cmd.arg1 == 2) {
  output.path <- "/net/data.isilon/ag-saez/bq_pschaefer/OUTPUT/4iANCA/ratio_76/"
} else if (cmd.arg1 == 3) {
  output.path <- "/net/data.isilon/ag-saez/bq_pschaefer/OUTPUT/4iANCA/ratio_38/"
} else if (cmd.arg1 == 4) {
  output.path <- "/net/data.isilon/ag-saez/bq_pschaefer/OUTPUT/4iANCA/ratio_19/"
} else if (cmd.arg1 == 5) {
  output.path <- "/net/data.isilon/ag-saez/bq_pschaefer/OUTPUT/4iANCA/ratio_9/"
}

ifelse(!dir.exists(output.path), dir.create(output.path), FALSE)

##### Packages ##### 
library(mistyR)
library(future)
plan("multisession", workers = 24)
library(tidyverse)

##### Input ##### 
print("Reading Data")

if (cmd.arg1 == 1) {
  input.views <- "ratio_153_views.RDS"
} else if (cmd.arg1 == 2) {
  input.views <- "ratio_76_views.RDS"
} else if (cmd.arg1 == 3) {
  input.views <- "ratio_38_views.RDS"
} else if (cmd.arg1 == 4) {
  input.views <- "ratio_19_views.RDS"
} else if (cmd.arg1 == 5) {
  input.views <- "ratio_9_views.RDS"
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
              results.folder = paste0(output.path, "MARS100/",smp.name),
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
              results.folder = paste0(output.path, "MARS80/",smp.name),
              model.function = mars_model,
              approx = 0.6)
  })
} else if (cmd.arg2 == 8) {
  purrr::walk2(misty.views.smp, names(misty.views.smp), function(smp.views, smp.name) {
    run_misty(views = smp.views,
              results.folder = paste0(output.path, "MARS60/",smp.name),
              model.function = mars_model,
              approx = 0.6)
  })
} else if (cmd.arg2 == 9) {
  purrr::walk2(misty.views.smp, names(misty.views.smp), function(smp.views, smp.name) {
    run_misty(views = smp.views,
              results.folder = paste0(output.path, "SVM/",smp.name),
              model.function = svm_model,
              seed = 42,
              cv.folds = 10)
  })
} else if (cmd.arg2 == 10) {
  purrr::walk2(misty.views.smp, names(misty.views.smp), function(smp.views, smp.name) {
    run_misty(views = smp.views,
              results.folder = paste0(output.path, "MLP/",smp.name),
              model.function = mlp_model,
              seed = 42,
              cv.folds = 10)
  })
}
