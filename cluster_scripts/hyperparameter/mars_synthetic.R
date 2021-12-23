
##### Command line args ##### 
cmd.arg = as.numeric(commandArgs(trailingOnly = TRUE))[1]

#####  Packages ##### 
library(mistyR)
library(future)
plan("multisession", workers=24)
library(tidyverse)

##### Paths ##### 
output.path <- "/net/data.isilon/ag-saez/bq_pschaefer/OUTPUT/synthetic/MARS_hyper/"
ifelse(!dir.exists(output.path), dir.create(output.path), FALSE)

##### Input ##### 
data("synthetic")

#####  MISTy Views ##### 
misty.views.smp <- purrr::map(synthetic, function(sample) {
  sample.expr <- sample %>% dplyr::select(-c(row, col, type))
  sample.pos <- sample %>% dplyr::select(row, col)
  create_initial_view(sample.expr) %>% add_paraview(sample.pos, l = 10)
})

##### Parameters ######

# Penalties: -1, 0, 2, 3
penalties <- c(-1, 0, 2, -1, 0, 2, 3, 4, 3, 3, 3, 3)

# Degrees: 1, 2, 3
degrees <- c(1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2)

# Fast K: 20, 10, 5
fastks <- c(20, 20, 20, 20, 20, 20, 20, 20, 10, 5, 20, 20)

# Prunning Method: "backward", "none", "forward"
pmethods <- c("backward", "backward", "backward", "backward", "backward", 
              "backward", "backward", "backward", "backward", "backward", 
              "none", "forward")

map(seq_len(length(penalties)), ~ paste(penalties[.x], degrees[.x], 
                                           fastks[.x], pmethods[.x],
                                           sep = "_"))


##### Run MISTy #####
out <- paste("MARS_hyper", penalties[cmd.arg], degrees[cmd.arg], 
             fastks[cmd.arg], pmethods[cmd.arg], sep = "_")
purrr::iwalk(misty.views.smp, function(smp.views, smp.name) {
  run_misty(views = smp.views,
            results.folder = paste0(output.path, out, "/", smp.name),
            model.function = mars_model,
            seed = 42,
            cv.folds = 10,
            degree = degrees[cmd.arg],
            penalty = penalties[cmd.arg],
            fast.k = fastks[cmd.arg],
            pmethod = pmethods[cmd.arg])
})
