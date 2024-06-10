
# packages
library(tidyverse)
library(data.table)
library(patchwork)
library(magrittr)
library(ggrepel)

# visualization
theme_set(
  theme_classic() + 
    theme(strip.background = element_rect(color = NA)
    )
)

# inverse PCA
inv_pca <- function(dat, pca){
  
  .rot <- pca$rotation
  .scale <- pca$scale
  .mean <- pca$center
  .names <- names(.scale)
  
  # t_rot <- .rot %>% t()
  t_rot <- .rot %>% t()
  
  dat_pred <-
    dat %>% as.matrix() %>%
    {. %*% t_rot} %>%
    as_tibble() %>%
    set_names(.names) %>%
    map2_df(.scale, ~ .x * .y) %>%
    map2_df(.mean, ~ .x + .y)
  return(dat_pred)
}
