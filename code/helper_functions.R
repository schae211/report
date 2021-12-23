
# function to split the importances according to view and sample.
split_importances_old <- function(misty.importances) {
  misty.importances %>%
    unite(relation, Predictor, Target, sep="_") %>%
    select(-c(study, view.comp)) %>%
    drop %>%
    pivot_wider(names_from=relation, values_from=Importance) %>%
    # !!! all NAs replaced with 0 !!!
    replace(is.na(.), 0) %>%
    mutate(sample = str_extract(sample, "[^/]+$")) %>%
    group_by(sample, view) %>%
    group_split()
}

# function to get the keys for splitting the importances according to view and sample.
split_keys <- function(misty.importances) {
  misty.importances %>%
    unite(relation, Predictor, Target, sep="_") %>%
    select(-c(study, view.comp)) %>%
    drop_na() %>%
    pivot_wider(names_from=relation, values_from=Importance) %>%
    mutate(sample = str_extract(sample, "[^/]+$")) %>%
    group_by(sample, view) %>%
    group_keys()
}

# Using data.table (much faster than tibbles and tidyverse)
get_importance_dt <- function(filtered.run) {
  # https://atrebas.github.io/post/2019-03-03-datatable-dplyr/
  # could potentially be faster with these large datasets
  # impressive benchmark: https://h2oai.github.io/db-benchmark/
  map2_dfr(filtered.run, names(filtered.run), function(misty.run, name) {
    out <- misty.run$importances    
    out <- data.table::as.data.table(out)
    out[, algorithm := str_extract(name, "(?<=/)[^/]+$")]
    out[, study := str_extract(sample, "(?<=OUTPUT/)[^/]+")]
    out[, view.comp := str_extract(sample, paste0("(?<=OUTPUT/", 
                                                  study, "/)[^/]+"))]
  })
}

get_importance_old <- function(filtered.run) {
  map2_dfr(filtered.run, names(filtered.run), function(misty.run, name) {
    misty.run$importances %>%
      mutate(algorithm = str_extract(name, "(?<=/)[^/]+$")) %>%
      mutate(study = str_extract(sample, "(?<=OUTPUT/)[^/]+")) %>%
      mutate(view.comp = str_extract(sample, paste0("(?<=OUTPUT/", 
                                                    study, "/)[^/]+")))
  })
}