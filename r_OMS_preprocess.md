---
title: "r_OMS_preprocess"
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



**packages**


::: {.cell}

```{.r .cell-code}
source("R/source.R")
source("R/f_OMS.R")
```
:::


**path**


::: {.cell}

```{.r .cell-code}
path_dat <- "data/dat_oms.csv"
```
:::

::: {.cell}

```{.r .cell-code}
path_output <- "data/oms_for_smp"

dir.create(path_output, showWarnings = FALSE)
```
:::


**data**


::: {.cell}

```{.r .cell-code}
dat <-
  path_dat %>% 
  read_csv()
```
:::


**pca**


::: {.cell}

```{.r .cell-code}
.params <-
  dat %>% 
  select(starts_with("x_"), starts_with("y_"), starts_with("z_")) %>% 
  names()

pca <-
  dat %>% 
  select(all_of(.params)) %>% 
  prcomp(scale = TRUE)

dat_pca <-
  dat %>% 
  cbind(pca$x)
```
:::


**scale**


::: {.cell}

```{.r .cell-code}
dat_pc_scaled <-
  dat_pca %>% 
  mutate_at(vars(starts_with("PC")), \(x){ x / max(abs(x)) }) %>% 
  group_nest(batch, fragment) %>%
  rowid_to_column("id") %>% 
  mutate(id = id - 1) %>% 
  unnest(data) %>% 
  select(batch, fragment, id, everything())
```
:::


**preprocess**


::: {.cell}

```{.r .cell-code}
dat_fragment <-
  dat_pc_scaled %>% 
  group_nest(batch, fragment, id, keep = TRUE) %>% 
  mutate(pcs = map(data, \(x){select(x, PC1, PC2)})) %>% 
  mutate(w = formatC(id, width = 2, flag = "0"),
         w = str_c(path_output, "/dat_oms_", w, ".txt")) %>% 
  mutate(w_csv = str_replace(w, ".txt", ".csv"))
```
:::


**save**


::: {.cell}

```{.r .cell-code}
dat_fragment %$% 
  map2(pcs, w, \(x, y){write.table(x, y, row.names = F, col.names = F)})

dat_fragment %$% 
  map2(data, w_csv, \(x, y){write_csv(x, y)})
```
:::
