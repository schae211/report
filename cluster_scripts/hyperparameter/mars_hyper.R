
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
  output.path <- "/net/data.isilon/ag-saez/bq_pschaefer/OUTPUT/synthetic/MARS_hyper/"
} else if (cmd.arg1 == 2) {
  input.path <- "/net/data.isilon/ag-saez/bq_pschaefer/MISTY_VIEWS/mibi_tnbc/"
  input <- "standard_views.RDS"
  output.path <- "/net/data.isilon/ag-saez/bq_pschaefer/OUTPUT/mibi_tnbc/MARS_hyper/"
} else if (cmd.arg1 == 3) {
  input.path <- "/net/data.isilon/ag-saez/bq_pschaefer/MISTY_VIEWS/merfish_bc/"
  input <- "hvg_views.RDS"
  output.path <- "/net/data.isilon/ag-saez/bq_pschaefer/OUTPUT/merfish_bc/MARS_hyper"
}
ifelse(!dir.exists(output.path), dir.create(output.path), FALSE)

#####  Input ##### 
misty.views.smp <- readRDS(paste0(input.path, input))

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
out <- paste("MARS_hyper", penalties[cmd.arg2], degrees[cmd.arg2], 
             fastks[cmd.arg2], pmethods[cmd.arg2], sep = "_")
purrr::iwalk(misty.views.smp, function(smp.views, smp.name) {
  run_misty(views = smp.views,
            results.folder = paste0(output.path, out, "/", smp.name),
            model.function = mars_model,
            seed = 42,
            cv.folds = 10,
            degree = degrees[cmd.arg2],
            penalty = penalties[cmd.arg2],
            fast.k = fastks[cmd.arg2],
            pmethod = pmethods[cmd.arg2])
})
