---
title: "UMAP & k-means clustering"
format: 
  html: 
    fig-width: 8
    fig-height: 6
execute: 
  keep-md: TRUE
  message: FALSE
  warning: FALSE
editor: visual
---

The UMAP and k-means clustering results for marmoset free-feeding data used in the paper are included in the file `dat_SMPresults_marmofeed.csv` (columns `kclust06` and `kclust18`).

The following code is provided to reproduce these results.

-   source file


``` {.r .cell-code}
source("R/source.R")
```

-   path

``` {.r .cell-code}
path <- 
  "data/dat_SMPresults_marmofeed.csv"
```

-   import data

``` {.r .cell-code}
dat_raw <-
  path %>% 
  fread() %>% 
  as_tibble() %>% 
  select(!starts_with("kclust"))
```

-   PC score

``` {.r .cell-code}
prams_for_pca <-
  dat_raw %>% 
  select(starts_with("x_"), starts_with("y_"), starts_with("z_"), starts_with("v_")) %>% 
  names()

fit_pca <-
  dat_raw %>% 
  select(all_of(prams_for_pca)) %>% 
  prcomp(scale = TRUE)


dat <-
  dat_raw %>% 
  select(!starts_with("PC")) %>% 
  bind_cols(fit_pca$x)
```


-   UMAP

``` {.r .cell-code}
fit_umap <-
  dat %>% 
  select(PC1, PC2) %>% 
  umap::umap()
```


-   k-means clustering

``` {.r .cell-code}
kclust18 <-
  fit_umap$layout %>% 
  kmeans(centers = 18)

kclust6 <-
  fit_umap$layout %>% 
  kmeans(centers = 6)
```


-   output

``` {.r .cell-code}
dat_umap <-
  dat %>%
  cbind(fit_umap$layout %>% as_tibble()) %>% 
  mutate(kclust18 = kclust18$cluster)  %>% 
  mutate(kclust06 = kclust6$cluster) %>% 
  as_tibble() %>% 
  mutate(kclust18 = factor(kclust18),
         kclust06 = factor(kclust06))

dat_umap %>% 
  write_csv("data/dat_marmofeed_umap_kclust.csv")
```

