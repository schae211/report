
##### Verbosity ##### 
print("mibi tnbc prep")

#####  Packages ##### 
library(mistyR)
library(future)
plan("multisession", workers=24)
library(tidyverse)
library(tiff)

##### Paths ##### 
input.path <- "/net/data.isilon/ag-saez/bq_pschaefer/DATA/mibi_tnbc/"
output.path <- "/net/data.isilon/ag-saez/bq_pschaefer/MISTY_VIEWS/mibi_tnbc/"
ifelse(!dir.exists(output.path), dir.create(output.path), FALSE)

#####  Input ##### 
print("reading data")
input <- read_csv(paste0(input.path, "cellData.csv"), show_col_types=FALSE)
group.trans <- c("1" = "Unidentified", "2" = "Immune", "3" = "Endothelial", 
                 "4" = "Mesenchymal-like", "5" = "Tumor", 
                 "6" = "Keratin-positive tumor")
immune.group.trans <- c("0" = "Non-Immune?", "1" = "Tregs", "2" = "CD4 T", "3" = "CD8 T", 
                        "4" = "CD3 T", "5" = "NK", "6" = "B",
                        "7" = "Neutrophils", "8" = "Macrophages", 
                        "9" = "DC", "10" = "DC/Mono", "11" = "Mono/Neu", 
                        "12" = "Other immune")

raw_data <- input %>%
  mutate(Group = group.trans[as.character(Group)]) %>%
  mutate(immuneGroup = immune.group.trans[as.character(immuneGroup)])

#####  Coordinates ##### 
print("computing coordinates")
samples <- c(1:29, 31:41) # sample 30 does not exist
coord <- furrr::future_map_dfr(samples, function(sample.id) {
  # Read in raw matrix (in tiff format)
  img.path <- paste0(input.path, "tiffs/p", sample.id, "_labeledcellData.tiff")
  # Testing
  print(sample.id)
  #print(img.path)
  tiff <- readTIFF(img.path, as.is = TRUE)
  seq.rows <- seq_len(nrow(tiff))
  seq.cols <- seq_len(ncol(tiff))
  # important: map over all unique values here! (but I removed 1 and 2)
  cell.ids <- unique(as.vector(tiff))[-which(unique(as.vector(tiff)) %in% c(0,1))]
  purrr::map_dfr(cell.ids, function(i) {
    # Convert to binary matrix with TRUE and FALSE
    binary <- (tiff == i)
    s <- sum(binary)
    # Calculate center of mass
    c(id = sample.id, 
      i = i,
      x.center = sum(seq.rows * rowSums(binary)) / s,
      y.center = sum(seq.cols * colSums(binary)) / s
    )
  })
})
data <- raw_data %>%
  inner_join(coord, by = c("SampleID" = "id", 
                           "cellLabelInImage" = "i")) %>%
  rename(row = x.center, col = y.center)

#####  Split meta data and expression ##### 
meta <- data %>%
  select(c(1:3, 53:59))

expr <- data %>%
  select(4:52)

#####  Clean Expression ##### 
print("Cleaning expression data")
cv.folds = 10
expr.smp <- unique(meta$SampleID) %>%
  set_names(paste0("s", .)) %>%
  map(function(id) {
    ret.expr <- expr %>%
      filter(meta$SampleID == id) %>%
      # Select only proteins
      select(11:47)
    
    # Check for zero variance (otherwise MISTy throws an error)
    target.var <- apply(ret.expr, 2, stats::sd, na.rm = TRUE)
    ret.expr <- ret.expr %>% select(-names(which(target.var == 0)))
    
    # Check for how many unique values
    target.unique <- colnames(ret.expr) %>%
      purrr::set_names() %>%
      purrr::map_int(~ length(unique(ret.expr %>% pull(.x))))
    ret.expr <- ret.expr %>% select(
      names(target.unique[target.unique > cv.folds])
    )
    
    colnames(ret.expr) <- make.names(colnames(ret.expr))
    ret.expr
  })

##### Clean Coordinates ##### 
print("Cleaning coordinate data")
coord.smp <- unique(meta$SampleID) %>%
  set_names(paste0("s", .)) %>%
  map(function(id) {
    meta %>%
      filter(meta$SampleID == id) %>% 
      select(c(row, col))
  })

##### MISTy Views #####
print("computing misty views")
misty.views.smp <- map2(expr.smp, coord.smp, function(expr, coord) {
  # Create views
  create_initial_view(expr) %>%
    add_juxtaview(positions = coord, neighbor.thr = 40) %>%
    add_paraview(positions = coord, l = 120, zoi = 40)
})
names(misty.views.smp) <- names(expr.smp)

print(paste0(output.path, "standard_views.RDS"))
saveRDS(misty.views.smp, file = paste0(output.path, "standard_views.RDS"))

