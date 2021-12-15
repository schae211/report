
##### Verbosity ##### 
print("4I Prep (Jovan's Script)")

##### Command line args ##### 
cmd.arg = as.numeric(commandArgs(trailingOnly = TRUE))[1]

#####  Packages ##### 
library(mistyR)
library(future)
plan("multisession", workers=24)
library(tidyverse)

##### Paths ##### 
input.path <- "/net/data.isilon/ag-saez/bq_pschaefer/DATA/4iANCA/"
# input.path <- "/home/philipp/Saez/"
# smp <- "/home/philipp/Saez/ANCA1g1.csv"
output.path <- "/net/data.isilon/ag-saez/bq_pschaefer/MISTY_VIEWS/4iANCA/"
ifelse(!dir.exists(output.path), dir.create(output.path), FALSE)

#####  Numbers: ##### 
side_pixel_microns <- 0.13
average_eukaryotic_cell_microns <- 20
# what do we have do divide each coordinate by
raw_ratio <- floor(average_eukaryotic_cell_microns / side_pixel_microns)
raw_l <- 3
# ratio <- raw_ratio

if (cmd.arg == 1) {
  ratio <- raw_ratio
  l <- raw_l
} else if (cmd.arg == 2) {
  ratio <- floor(raw_ratio / 2**1)
  l <- raw_l * 2
} else if (cmd.arg == 3) {
  ratio <- floor(raw_ratio / 2**2)
  l <- raw_l * 4
} else if (cmd.arg == 4) {
  ratio <- floor(raw_ratio / 2**3)
  l <- raw_l * 8
} else if (cmd.arg == 5) {
  ratio <- floor(raw_ratio / 2**4)
  l <- raw_l * 8
}

#####  Input ##### 
print("reading data")
samples <- list.files(input.path, full.names = TRUE)
names(samples) <- str_extract(samples, "(?<=4iANCA//).+(?=.csv)")

misty.views.smp <- map(samples, function(smp) {
  
  ##### Read in Data #####
  img <- read_csv(smp)
  
  ##### Temporary Plotting #####
  # test <- img %>% 
  #   slice_sample(prop = 0.05)
  # 
  # test %>%
  #   ggplot(aes(x=x, y=y, col=DAPI)) +
  #   geom_point(size = 0.01) +
  #   scale_color_viridis_c()
  # 
  # test %>%
  #   ggplot(aes(x=x, y=y, col=Nephrin)) +
  #   geom_point(size = 0.01) +
  #   scale_color_viridis_c()
  # 
  # test %>%
  #   ggplot(aes(x=x, y=y, col=Podocin)) +
  #   geom_point(size = 0.01) +
  #   scale_color_viridis_c()
  
  # Reduce Size
  img.red <- img %>% 
    mutate(x = trunc(x/ratio), y = trunc(y/ratio)) %>% 
    select(-c(...1, cluster)) %>% 
    unite("xy", x, y) %>%
    group_by(xy) %>% 
    summarize(across(everything(), median)) %>% # why should we take the median and not the sum here?
    separate("xy", c("x","y"), convert = TRUE)
  
  # Select Position and Expression
  pos <- img.red %>% select(c(x, y))
  expr <- img.red %>% select(-c(x, y))
  colnames(expr) <- make.names(colnames(expr)) # fix column names
  
  # Create MISTy views (TODO: Is l = 10 reasonable)?
  create_initial_view(data = expr) %>%
    add_paraview(positions = pos, l = 10)
})

print(paste0(output.path, "ratio_", ratio, "_views.RDS"))
saveRDS(misty.views.smp, 
        file = paste0(output.path, "ratio_", ratio, "_views.RDS"))