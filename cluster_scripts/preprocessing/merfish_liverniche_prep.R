
##### Verbosity #####
print("merfish liver niche prep")

##### Packages #####
library(mistyR)
library(future)
plan("multisession", workers=16)
library(tidyverse)
library(R.matlab)

##### Paths #####
# input.path <- "/home/philipp/data/saez/merfish/"
input.path <- "/net/data.isilon/ag-saez/bq_pschaefer/DATA/merfish_liver/"
output.path <- "/net/data.isilon/ag-saez/bq_pschaefer/MISTY_VIEWS/merfish_liver/"
ifelse(!dir.exists(output.path), dir.create(output.path), FALSE)

##### Input #####
gene.tibble <- readxl::read_xlsx(
  paste0(input.path, "Supplement/41421_2021_266_MOESM1_ESM.xlsx"),
  skip = 1
)
genes <- gene.tibble$`Gene name`

wt.samples <- list.files(paste0(input.path, "Data/WT CellList"), full.names=TRUE)
sample.names <- str_extract(wt.samples, "CellID_[0-9]+")

raw.data <- map(wt.samples, function(file) {
  readMat(file)$CellList
}) %>% setNames(sample.names)

# Extracting useful information
cell.data <- map(raw.data, function(smp.data) {
  smp.cell.data <- map_dfr(seq.int(1, dim(smp.data)[3]), function(i) {
    cell_i <- smp.data[1:8, 1, i]
    tibble::tibble(id = cell_i$CellID, fov = cell_i$FOV, x = cell_i$Center[1, 1],
                   y = cell_i$Center[1, 2], total.rna.copy = cell_i$TotalRNACopyNumber[1, 1],
                   edge = cell_i$OnEdge[1, 1], type = cell_i$CellType, num.pixel = dim(cell_i$PixelList)[1])
  })
}) %>% setNames(sample.names)

# Merging Cell Data
cell.meta <- cell.data %>% map2_dfr(names(cell.data), function(smp.data, name) {
  smp.data %>% mutate(sample = name)
}) %>%
  mutate(type_name = case_when(
    type == 1 ~ "Arterial.Endothelial.Cells",
    type == 2 ~ "Sinusoidal.Endothelial.Cells",
    type == 3 ~ "Megakaryocytes",
    type == 4 ~ "Hepatocyte",
    type == 5 ~ "Macrophage",
    type == 6 ~ "Myeloid",
    type == 7 ~ "Erythroid.Progenitor",
    type == 8 ~ "Erythroid.Cell",
    type == 9 ~ "Unknown"
  ))

# Getting expression data
expr.data <- map(raw.data, function(smp.data) {
  smp.expr.data <- map_dfr(seq.int(1, dim(smp.data)[3]), function(i) {
    cell_i <- smp.data[1:8, 1, i]
    cell_i$CellID
    expr <- cell_i$RNACopyNumber %>% as.vector
    names(expr) <- genes
    c(id = cell_i$CellID, expr)
  })
})

# Normalizing expression data
expr.data.norm <- map(expr.data, function(sample) {
  cell.totals <- sample %>%
    pivot_longer(cols = 2:141) %>%
    group_by(id) %>%
    summarise(cell.sum = sum(value))

  sample %>%
    left_join(cell.totals, by="id") %>%
    pivot_longer(cols = 2:141) %>%
    mutate(normalized = value / cell.sum * 1000) %>%
    select(-c(cell.sum, value)) %>%
    pivot_wider(names_from = name, values_from = normalized)
})

##### Spatially variable genes #####
# variable.genes.smp <- map2(expr.data, cell.data, function(expr, smp) {
#
#   sp_count <- expr
#
#   location <- smp
#
#   sparkX <- SPARK::sparkx(sp_count,location,numCores=1,option="mixture")
#
#   sparkX$res_mtest %>%
#     rownames_to_column() %>%
#     slice_min(adjustedPval, n=100) %>%
#     pull(rowname)
# })
#
# min.n <- ceiling(length(smps)/2)
#
# sel.genes <- table(unlist(variable.genes.smp))[table(unlist(variable.genes.smp)) >= min.n] %>%
#   names %>%
#   make.names()

# Subsetting fields of view per sample
keep.smp <- map(cell.data, function(smp) {
  smp %>%
    group_by(fov) %>%
    summarise(n = n()) %>%
    filter(n >= 280) %>%
    pull(fov) %>%
    as.numeric()
})

##### MISTy views #####
misty.views.smp <- map2(keep.smp, names(keep.smp), function(keep, name) {

  misty.views <- map(keep, function(test.fov) {

    cell.meta <- cell.data[[name]] %>%
      filter(fov == test.fov)

    coords <- cell.meta %>% select(x, y)

    ids <- cell.meta$id

    expr <- expr.data.norm[[name]][(expr.data.norm[[name]] %>% pull(id)) %in% ids, ] %>%
      select(-id)

    # calculate variance per gene
    expr.clean <- expr[, matrixStats::colVars(expr %>% as.matrix) != 0]

    create_initial_view(expr.clean) %>%
      add_juxtaview(positions = coords, neighbor.thr = 100) %>%
      add_paraview(positions = coords, l = 180, zoi = 100)
  })

  names(misty.views) <- paste0(name, "_fov_", keep)

  misty.views
}) %>%
  unlist(recursive = FALSE)

saveRDS(misty.views.smp, file = paste0(output.path, "standard280_views.RDS"))



