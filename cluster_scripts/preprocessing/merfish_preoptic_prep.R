
##### Verbosity ##### 
print("merfish preoptic prep")

##### Packages ##### 
library(mistyR)
library(future)
plan("multisession", workers=24)
library(tidyverse)

##### Paths ##### 
# input.path <- "/home/philipp/data/saez/merfish_moffitt/"
input.path <- "/net/data.isilon/ag-saez/bq_pschaefer/DATA/merfish_preoptic/"
output.path <- "/net/data.isilon/ag-saez/bq_pschaefer/MISTY_VIEWS/merfish_preoptic/"
ifelse(!dir.exists(output.path), dir.create(output.path), FALSE)

##### Input ##### 
print("reading data")
all.data <- read_csv(paste0(input.path, "Moffitt_and_Bambah-Mukku_et_al_merfish_all_cells.csv"), name_repair = "universal")

smps <- all.data$Animal_ID %>% unique

##### Spatially variable genes #####
variable.genes.smp <- map(smps, function(smp) {
  print(smp)
  sp_count <- all.data %>% 
    filter(Animal_ID == smp) %>%
    select(c(10:21, 27:170)) %>%
    select(-Fos) %>%
    t()
  
  colnames(sp_count) <- seq_len(ncol(sp_count))
  
  location <- all.data %>% 
    filter(Animal_ID == smp) %>%
    select(Centroid_X, Centroid_Y)

  sparkX <- SPARK::sparkx(sp_count,location,numCores=1,option="mixture")
  
  sparkX$res_mtest %>%
    rownames_to_column() %>%
    slice_min(adjustedPval, n=100) %>%
    pull(rowname)
})

min.n <- ceiling(length(smps)/2)

sel.genes <- table(unlist(variable.genes.smp))[table(unlist(variable.genes.smp)) >= min.n] %>%
  names %>%
  make.names()

##### MISTy views ##### 
print("computing misty views")
cv.folds <- 10
misty.views.smp <- map(smps, function(smp) {
  print(smp)
  
  pos <- all.data %>% 
    filter(Animal_ID == smp) %>%
    select(Centroid_X, Centroid_Y)
  
  # Get expression values and clean
  expr <- all.data %>% 
    filter(Animal_ID == smp) %>%
    select(c(10:21, 27:170))
  
  # Check for zero variance (otherwise MISTy throws an error)
  target.var <- apply(expr, 2, stats::sd, na.rm = TRUE)
  expr <- expr %>% select(-names(which(target.var == 0)))
  
  # Check for how many unique values
  target.unique <- colnames(expr) %>%
    purrr::set_names() %>%
    purrr::map_int(~ length(unique(expr %>% pull(.x))))
  expr <- expr %>% select(
    names(target.unique[target.unique > cv.folds])
  )
  
  colnames(expr) <- make.names(colnames(expr))
  
  create_initial_view(expr[, sel.genes]) %>%
    add_juxtaview(positions = pos, neighbor.thr = 30) %>%
    add_paraview(positions = pos, l = 120, zoi = 30)
}) %>% 
  set_names(smps)

saveRDS(misty.views.smp, file = paste0(output.path, "hvg_views.RDS"))
