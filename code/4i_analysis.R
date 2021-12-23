
perf.sig <- extract_signature(iiii_38$`/4iANCA/ratio_38/RF`,
                              type="performance") %>%
  mutate(sample = str_extract(sample, "(?<=RF/).+")) %>%
  mutate(condition = ifelse(str_detect(sample, "Control"),
                            "control", "anca"))
perf.pca <- prcomp(perf.sig %>% select(-c(sample, condition)))
ggplot() +
  geom_point(aes(x=perf.pca$x[,1], y=perf.pca$x[,2], 
                 col = perf.sig$condition))

imp.sig <- extract_signature(iiii_38$`/4iANCA/ratio_38/RF`,
                             type="importance") %>%
  mutate(sample = str_extract(sample, "(?<=RF/).+")) %>%
  mutate(condition = ifelse(str_detect(sample, "Control"),
                            "control", "anca")) %>%
  mutate(patient = str_extract(sample, ".+(?=g)"))

imp.pca <- prcomp(imp.sig %>% 
                    select(-c(sample, condition, patient)),
                  rank. = 50)

ggplot() +
  geom_point(aes(x=imp.pca$x[,1], y=imp.pca$x[,2], 
                 col = imp.sig$condition))

imp.sig %>% dim
imp.pca$rotation %>% dim

pc1 <- (imp.pca$rotation[,1] %>%
          abs %>%
          sort(decreasing = TRUE))[1:10]

pc2 <- (imp.pca$rotation[,2] %>%
          abs %>%
          sort(decreasing = TRUE))[1:10]

ggplot() +
  geom_point(aes(x=imp.pca$x[,1], y=imp.pca$x[,2], 
                 col = imp.sig$patient))

factoextra::fviz_pca_var(imp.pca,
                         gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
                         col.var="cos2", repel = TRUE,
                         select.var = list(cos2 = 15))

# PC 1 loadings
(imp.pca$rotation[,1] %>%
    abs %>%
    sort(decreasing = TRUE))[1:10] %>%
  data.frame

# PC 2 loadings
(imp.pca$rotation[,2] %>%
    abs %>%
    sort(decreasing = TRUE))[1:10] %>%
  data.frame