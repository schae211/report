
##### Verbosity ##### 
print("Merfish Preoptic Analysis HVG")

##### Command line args ##### 
cmd.arg = as.numeric(commandArgs(trailingOnly = TRUE))[1]

##### Paths ##### 
# input.path <- "/home/philipp/data/saez/htapp/"
input.path <- "/net/data.isilon/ag-saez/bq_pschaefer/MISTY_VIEWS/merfish_preoptic/"
output.path <- "/net/data.isilon/ag-saez/bq_pschaefer/OUTPUT/merfish_preoptic/hvg/"
ifelse(!dir.exists(output.path), dir.create(output.path), FALSE)

##### Packages ##### 
library(mistyR)
library(future)
plan("multisession", workers = 24)
library(tidyverse)

##### Input ##### 
print("Readining Data")
misty.views.smp <- readRDS(paste0(input.path, "hvg_views.RDS"))

# fixing names of misty.views.smp
all.data <- read_csv("/net/data.isilon/ag-saez/bq_pschaefer/DATA/merfish_preoptic/Moffitt_and_Bambah-Mukku_et_al_merfish_all_cells.csv", name_repair = "universal")
smps <- all.data$Animal_ID %>% unique
names(misty.views.smp) <- smps

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
              n.bags = 30)
  })
} else if (cmd.arg == 3) {
  purrr::walk2(misty.views.smp, names(misty.views.smp), function(smp.views, smp.name) {
    run_misty(views = smp.views,
              results.folder = paste0(output.path, "MARS/",smp.name),
              model.function = mars_model,
              seed = 42,
              cv.folds = 10,
              approx = 1)
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
} else if (cmd.arg == 9) {
  purrr::walk2(misty.views.smp, names(misty.views.smp), function(smp.views, smp.name) {
    run_misty(views = smp.views,
              results.folder = paste0(output.path, "MARS80/",smp.name),
              model.function = mars_model,
              seed = 42,
              cv.folds = 10,
              approx = 0.8)
  })
} else if (cmd.arg == 10) {
  purrr::walk2(misty.views.smp, names(misty.views.smp), function(smp.views, smp.name) {
    run_misty(views = smp.views,
              results.folder = paste0(output.path, "MARS60/",smp.name),
              model.function = mars_model,
              seed = 42,
              cv.folds = 10,
              approx = 0.6)
  })
} else if (cmd.arg == 11) {
  purrr::walk2(misty.views.smp, names(misty.views.smp), function(smp.views, smp.name) {
    run_misty(views = smp.views,
              results.folder = paste0(output.path, "MARS40/",smp.name),
              model.function = mars_model,
              seed = 42,
              cv.folds = 10,
              approx = 0.4)
  })
}
