---
title: "r_OMS_motionrecovery"
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





**Packages**


::: {.cell}

```{.r .cell-code}
source("R/source.R")
source("R/f_OMS.R")
```
:::


**path**


::: {.cell}

```{.r .cell-code}
path_omp <- "data/rawdata_OMS"

path_mat <-
  path_omp %>% 
  list.files(pattern = "Batch", full.names = TRUE) %>% 
  map_chr(\(x){list.files(x, pattern = "coords_3D", full.names = TRUE)})

path_mat
```

::: {.cell-output .cell-output-stdout}
```
[1] "data/rawdata_OMS/Batch10/coords_3D.mat"
[2] "data/rawdata_OMS/Batch11/coords_3D.mat"
[3] "data/rawdata_OMS/Batch7/coords_3D.mat" 
[4] "data/rawdata_OMS/Batch9/coords_3D.mat" 
[5] "data/rawdata_OMS/Batch9a/coords_3D.mat"
[6] "data/rawdata_OMS/Batch9b/coords_3D.mat"
```
:::
:::