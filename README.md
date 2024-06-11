---
title: "Syntactic Motion Parser"
format: html
execute: 
  keep-md: TRUE
editor: visual
---





**Koki Mimura***, Jumpei Matsumoto, Daichi Mochihashi, Tomoaki Nakamura, Hisao Nishijo, Makoto Higuchi, Toshiyuki Hirabayashi, Takafumi Minamimoto: Unsupervised decomposition of natural monkey behavior into a sequence of motion motifs, bioRxiv, doi: https://doi.org/10.1101/2023.03.04.531044 (under revesion)

E-mail: kmimura@ism.ac.jp

This algorithm optimizes the kernel function and hyperparameters of the [HDP-GP-HSMM](https://github.com/naka-lab/HDP-GP-HSMM) by Dr. Tomoaki, Nakamura to conform to primate behavior analysis.


# 1. Environment

We run SMP in a python 3.9 and require the following packages.

- numpy == **1.20**
- matplotlib >= 3.7.5
- pandas >= 1.4.4
- cython >= 3.0.10

If you are using [Pipevn](https://pipenv.pypa.io/en/latest/) for Python virtual environment maneger, you can use the `Pipfile` in this repository for the environment setup. You can also refer the `requiremtens.txt` file.

The data analysis code has been verified to work with R 4.3.3. The following packages were used.

```
 [1] ggrepel_0.9.5     magrittr_2.0.3    patchwork_1.2.0  
 [4] data.table_1.15.0 lubridate_1.9.3   forcats_1.0.0    
 [7] stringr_1.5.1     dplyr_1.1.4       purrr_1.0.2      
[10] readr_2.1.4       tidyr_1.3.0       tibble_3.2.1     
[13] ggplot2_3.4.4     tidyverse_2.0.0  
```

# 2. Marmoset free-feeding behavior

# 3. Macaque motion analysis

- [data cleaning (interpolation)](r_OMS_interpolation.md)

- preprocess

- 


# 4. Marmoset chemogenetic manipulation behavior
