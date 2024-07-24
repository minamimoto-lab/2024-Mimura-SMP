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



-   source


::: {.cell}

```{.r .cell-code}
source("R/source.R")
```
:::


-   path


::: {.cell}

```{.r .cell-code}
path <- 
  "data/dat_SMPresults_marmofeed.csv"

path_ts <-
  "data/dat_marmofeed_feedingTimeStamp.csv" # timestamp and type of feeding behavior
```
:::


-   data import


::: {.cell}

```{.r .cell-code}
dat_raw <-
  path %>% 
  fread() %>% 
  as_tibble() 

dat_ts <-
  path_ts %>% 
  read_csv(show_col_types = FALSE)
```
:::


-   tagging to the data segments detected by the Posture model (UMAP + k-means clustering)


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


- data segment length (median, mean, sd)


::: {.cell}

```{.r .cell-code}
dat_nest_motif <-
  dat %>% 
  group_nest(tag_motif, motif) %>% 
  mutate(len_motif = map_dbl(data, nrow))

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
dat_nest_kclust <-
  dat %>% 
  group_nest(tag_kclust18, kclust18) %>% 
  mutate(len_kclust = map_dbl(data, nrow))

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


-   compair length


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


- Comparison of performance in distinguishing feeding types


::: {.cell}

```{.r .cell-code}
dat_nest <-
  dat_ts %>% 
  mutate(data = nest(dat)$data) %>% 
  mutate(data = map2(
    data, dataid, \(x, y){ filter(x, dataid == y) }
    )) %>% 
  mutate(data = map2(
    data, sec,\(x, y){
      mutate(x, d = abs(sec - y)) %>% 
        filter(d == min(d)) %>% 
        select(motif, kclust18, kclust06)
    }
  )) 

dat_type <-
  dat_nest %>% 
  unnest(data) %>% 
  mutate(type2 = if_else(type == "wall", "wall", "floor"))
```
:::


- SMP results


::: {.cell}

```{.r .cell-code}
# wall vs. floor
dat_type %$% 
  table(type2, motif) %>% 
  rstatix::chisq_test()
```

::: {.cell-output .cell-output-stdout}
```
# A tibble: 1 × 6
      n statistic           p    df method          p.signif
* <int>     <dbl>       <dbl> <int> <chr>           <chr>   
1    58      51.9 0.000000284    11 Chi-square test ****    
```
:::

```{.r .cell-code}
# floor_head vs. floor_hand
dat_type %>% 
  filter(type != "wall") %$% 
  table(type, motif) %>% 
  rstatix::chisq_test()
```

::: {.cell-output .cell-output-stdout}
```
# A tibble: 1 × 6
      n statistic        p    df method          p.signif
* <int>     <dbl>    <dbl> <int> <chr>           <chr>   
1    46      26.2 0.000985     8 Chi-square test ***     
```
:::
:::


- Posture model (k = 18)


::: {.cell}

```{.r .cell-code}
# wall vs. floor
dat_type %$% 
  table(type2, kclust18) %>% 
  rstatix::chisq_test()
```

::: {.cell-output .cell-output-stdout}
```
# A tibble: 1 × 6
      n statistic            p    df method          p.signif
* <int>     <dbl>        <dbl> <int> <chr>           <chr>   
1    58        58 0.0000000521    12 Chi-square test ****    
```
:::

```{.r .cell-code}
# floor_head vs. floor_hand
dat_type %>% 
  filter(type != "wall") %$% 
  table(type, kclust18) %>% 
  rstatix::chisq_test()
```

::: {.cell-output .cell-output-stdout}
```
# A tibble: 1 × 6
      n statistic     p    df method          p.signif
* <int>     <dbl> <dbl> <int> <chr>           <chr>   
1    46      7.58 0.371     7 Chi-square test ns      
```
:::
:::
