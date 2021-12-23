
cmd.arg1 = commandArgs(trailingOnly = TRUE)[1]
message(paste0("Publishing: ", cmd.arg1))

library(workflowr)

wflow_publish(paste0("analysis/", cmd.arg1), delete_cache=TRUE, verbose=TRUE)

