---
title: "Syntactic Motion Parser"
format: html
execute: 
  keep-md: TRUE
  eval: FALSE
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

Clone this repository to the location where you built your Python environment.

```
git clone https://github.com/minamimoto-lab/2024-Mimura-SMP
```

SMP works in this environment at a minimum. If you wish to reproduce the data analysis, please also prepare the R environment using R 4.3.3 and following packages were used.

```
 [1] ggrepel_0.9.5     magrittr_2.0.3    patchwork_1.2.0  
 [4] data.table_1.15.0 lubridate_1.9.3   forcats_1.0.0    
 [7] stringr_1.5.1     dplyr_1.1.4       purrr_1.0.2      
[10] readr_2.1.4       tidyr_1.3.0       tibble_3.2.1     
[13] ggplot2_3.4.4     tidyverse_2.0.0  
```

# 2. Marmoset free-feeding behavior

## data processing
- [The UMAP and k-means clustering](r_marmofeed_UMAP_kmeans.md)
- [Comparison of data fragment length obtained by SMP and the Posture Model](r_marmofeed_SMPvsPosturemodel.md)


# 3. Macaque motion analysis

Run `SMP_omp.py` for SMP simulation on the data from [OpenMonkeyStudio](https://github.com/OpenMonkeyStudio) (takes several hours depending on CPU and RAM).

```
python SMP_omp.py
```

- about OpenMonkeyStudio: [Bala et al., Nat.Commun. 2020](https://doi.org/10.1038/s41467-020-18441-5)

## data processing

- [data cleaning (rotation, interpolation)](r_OMS_interpolation.md)

- [preprocess (PCA)](r_OMS_preprocess.md)

- [postprocess (inverse PCA)](r_OMS_postprocess.md)

## data

- `data/dat_SMPresults_OMP.csv`
  - batch, id_datafragment: data id
  - motif: SMP motif
  - motiftag: fragmented data id
  - frame, time: time stamp (1 Hz)
  - x_, y_, z_...: tracking data body keypoints
  - PC1-36: principal component scores

- `data/dat_OMS_invPCA.csv`
  - motif: SMP motif
  - lank: rank of motif observation
  - time: time stamp (1 Hz)
  - PC1-36: mean of PCs
  - x_, y_, z_...: motion data recovered by inverse PCA


# 4. Chemogenetic manipulation in marmoset

- about chemogenetic neural manipulation in marmoset: [Mimura et al., iScience 2021](https://pubmed.ncbi.nlm.nih.gov/34568790/)
  - We injected adeno-associated virus vectors expressing the excitatory DREADD (designer receptor exclusively activated by designer drugs) hM3Dq into the unilateral substantia nigra (SN) in marmosets. 
  - The marmosets rotated in a contralateral direction relative to the activated side 30-90 min after consuming food containing the highly potent DREADD agonist deschloroclozapine (DCZ).