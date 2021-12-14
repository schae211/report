
# minimal earth script
library(earth)
library(mistyR)

data("synthetic")

expr <- synthetic$synthetic1 %>% dplyr::select(-c(row, col, type))

model <- earth(ECM ~ ., expr)

summary(model)


