---
title: "SMPvsPosturemodel"
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



- source


::: {.cell}

```{.r .cell-code}
source("R/source.R")
```
:::


- path


::: {.cell}

```{.r .cell-code}
path <- 
  "data/dat_SMPresults_marmofeed.csv"
```
:::


- data import


::: {.cell}

```{.r .cell-code}
dat_raw <-
  path %>% 
  fread() %>% 
  as_tibble() 
```
:::


- tagging to the data segments detected by the Posture model (UMAP + k-means clustering)


::: {.cell}

```{.r .cell-code}
dat <-
  dat_raw %>% 
  group_by(dataid) %>% 
  mutate(tag_kclust18 = if_else(kclust18 != lag(kclust18), 1, 0)) %>% 
  mutate(tag_kclust18 = if_else(is.na(tag_kclust18), 1, tag_kclust18)) %>% 
  ungroup() %>% 
  mutate(tag_kclust18 = cumsum(tag_kclust18))
```
:::


- median, mean, sd


::: {.cell}

```{.r .cell-code}
dat_nest_motif <-
  dat %>% 
  group_nest(tag_motif, motif) %>% 
  mutate(len_motif = map_dbl(data, nrow))

dat_nest_kclust <-
  dat %>% 
  group_nest(tag_kclust18, kclust18) %>% 
  mutate(len_kclust = map_dbl(data, nrow))

dat_nest_motif %>% 
  summarise(median = median(len_motif) / 10,
            mean = mean(len_motif) / 10,
            sd = sd(len_motif) / 10)
```

::: {.cell-output .cell-output-stdout}
```
# A tibble: 1 × 3
  median  mean    sd
   <dbl> <dbl> <dbl>
1    2.3  2.23 0.589
```
:::

```{.r .cell-code}
dat_nest_kclust %>%  
  summarise(median = median(len_kclust) / 10,
            mean = mean(len_kclust) / 10,
            sd = sd(len_kclust) / 10)
```

::: {.cell-output .cell-output-stdout}
```
# A tibble: 1 × 3
  median  mean    sd
   <dbl> <dbl> <dbl>
1    0.3 0.471 0.531
```
:::
:::


- compair length


::: {.cell}

```{.r .cell-code}
lawstat::brunner.munzel.test(
  dat_nest_motif$len_motif,
  dat_nest_kclust$len_kclust
)
```

::: {.cell-output .cell-output-stdout}
```

	Brunner-Munzel Test

data:  dat_nest_motif$len_motif and dat_nest_kclust$len_kclust
Brunner-Munzel Test Statistic = -177.48, df = 2451.8, p-value < 2.2e-16
95 percent confidence interval:
 0.01845439 0.02897891
sample estimates:
P(X<Y)+.5*P(X=Y) 
      0.02371665 
```
:::
:::