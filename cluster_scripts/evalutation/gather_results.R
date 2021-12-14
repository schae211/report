
##### TODO #####
# Check that the results are properly extracted
# Check why certain runs failed (just because of the cluster?)

##### Packages #####
library(mistyR)
library(future)
library(tidyverse)
plan("multisession", workers=24)

##### Paths #####
input.path <- "/net/data.isilon/ag-saez/bq_pschaefer/OUTPUT/"
output.path <- "/net/data.isilon/ag-saez/bq_pschaefer/OUTPUT/"

d <- format(Sys.time(), "%Y-%m-%d-%H-%M")
output.object <- paste0(d, "_all_results.RDS")
output.log <- paste0(d, "_all_results.log")

##### Directories #####
experiments <- list.dirs(input.path, recursive = FALSE)

descriptions <- map(experiments, function(experiment) {
  list.dirs(experiment, recursive = FALSE)
}) %>% unlist

misty.runs <- map(descriptions, function(description) {
  list.dirs(description, recursive = FALSE)
}) %>% unlist

# extract all character preceeded by output path
names(misty.runs) <- str_extract(misty.runs, paste0("(?<=", input.path, ").+"))

# things to exclude
to_exclude <- c("/merfish_liver/hvg/"#, "/synthetic/"
                )

if (length(to_exclude) == 0) {
  mask <- rep(TRUE, length(misty.runs))
} else if (length(to_exclude) == 1) { 
  mask <- str_starts(names(misty.runs), to_exclude[1], negate = TRUE)
} else if (length(to_exclude) == 0) { 
  mask <- map(to_exclude, ~ str_starts(names(misty.runs), .x, negate = TRUE)) %>%
    do.call(`&`, .)
}

message(length(misty.runs[mask]))

misty.results <- purrr::map(misty.runs[mask], function(misty.run) {
  message(misty.run)
  # this should not return the timing file
  samples <- list.dirs(misty.run, recursive = FALSE)
  proper.samples <- c()

  # Checking whether the samples were processed properly, this prevents
  # collect_results from failing just because a single samples was
  # not properly processed
  for (smp in samples) {
    tryCatch(expr = {
      testing <- read.table(paste0(smp,"/","performance.txt"), header = TRUE)
      if (nrow(testing) == 0) {stop("Malformatted")}
      testing <- read.table(paste0(smp,"/","coefficients.txt"), header = TRUE)
      proper.samples <- c(proper.samples, smp)
    },
    error = function(cond) {})
  }

  bad.samples <- setdiff(samples, proper.samples)

  # Write bad samples to log file
  write(x = c("_____", misty.run, bad.samples, "_____"), file = paste0(output.path, output.log),
        append = TRUE)

  # If we have proper samples try to read them.
  if (length(proper.samples) > 0) {
    return_val <- tryCatch({
      # Collect the results
      collect_results(proper.samples)
      
    }, error=function(cond) {
      message(paste("\n MISTy Run malformatted:", misty.run))
      message("Here's the original error message:")
      message(cond)
      # Choose a return value in case of error
      "Error"
    })
  } else {
    return_val <- "No Proper Sample"
  }
  return(return_val)
})

saveRDS(misty.results, file=paste0(output.path, output.object))

