



.hands <- c("RHand", "RShoulder", "Neck", "LShoulder", "LHand")

.foot <- c("RFoot", "RKnee", "Hip", "LKnee", "LFoot")

.body <-  c("Nose", "Head", "Neck", "Hip", "Tail")


import_omp_data <- function(matpath){
  
  parts <- 
    "Nose-Head-Neck-RShoulder-RHand-LShoulder-LHand-Hip-RKnee-RFoot-LKnee-LFoot-Tail" %>% 
    str_split(pattern = "-")
  
  matpath %>% 
    R.matlab::readMat() %>% 
    .$coords %>% 
    as_tibble() %>% 
    set_names(c("frame", "x", "y", "z")) %>% 
    group_nest(frame) %>% 
    mutate(parts = parts) %>% 
    unnest(everything())
}


arrange_batch <- function(dat){
  dat %>% 
    rename(batch = path) %>% 
    mutate(batch = str_remove(batch, str_c(path_omp, "/")),
           batch = str_remove(batch, str_c("/", basename(batch))))
}


rot_HipNeck <-function(dat_i){
  dat_f <-
    dat_i %>% 
    pivot_wider(values_from = c(x, y, z),
                names_from = parts) %>% 
    mutate(x0 = x_Hip,
           y0 = y_Hip,
           z0 = z_Hip) %>% 
    mutate(x1 = x_Neck,
           y1 = y_Neck,
           z1 = z_Neck) %>% 
    mutate(d = sqrt((x1 - x0)^2 + (y1 - y0)^2 + (z1 - z0)^2)) %>% 
    mutate_at(vars(starts_with("x_")), ~ {(. - x0) / d}) %>% 
    mutate_at(vars(starts_with("y_")), ~ {(. - y0) / d}) %>% 
    mutate_at(vars(starts_with("z_")), ~ {(. - z0) / d}) %>%
    mutate(theta = - atan2(z_Neck, x_Neck),
           sinN = sin(theta),
           cosN = cos(theta)) 
  
  dat_f_long <- 
    dat_f %>% 
    rename(x_ori = x0, y_ori = y0, z_ori = z0) %>% 
    select(starts_with("x_"),
           starts_with("y_"),
           starts_with("z_")) %>% 
    pivot_longer(cols = everything(),
                 names_to = c(".value", "parts"),
                 names_sep = "_")
  
  dat_f_rot <-
    dat_f_long %>% 
    mutate(sinN = dat_f$sinN,
           cosN = dat_f$cosN) %>% 
    mutate(x_rot = cosN * x - sinN * z,
           z_rot = sinN * x + cosN * z,
           x = x_rot,
           z = z_rot) %>% 
    select(-c(x_rot, z_rot, sinN, cosN))
  
  return(dat_f_rot)
}


wide_omp <- function(dat){
  dat %>% 
    pivot_wider(values_from = c(x, y, z),
                names_from = parts) %>% 
    mutate(y_Hip = y_ori) %>% 
    select(-c(x_Hip, z_Hip, x_ori, z_ori, y_ori, z_Neck))
}

arrange_fragment <- function(dat, .d = 200){
  dat %>% 
    group_by(batch) %>% 
    mutate(d = frame - lag(frame),
           d = ifelse(is.na(d), 0, d)) %>% 
    mutate(fragment = if_else(d <= .d, 0, 1),
           fragment = cumsum(fragment)) %>% 
    ungroup()
}

arrange_data_for_loess <- function(dat){
  dat %>% 
    mutate(data = map(
      data, 
      \(x){
        pivot_longer(x, 
                     cols = c(starts_with("x_"), starts_with("y_"), starts_with("z_"))) %>% 
          group_nest(name)
      }
    )) %>% 
    unnest(data) 
}



gg_OMS_xy <- 
  function(
    dat_f,
    .hands = c("RHand", "RShoulder", "Neck", "LShoulder", "LHand"),
    .foot = c("RFoot", "RKnee", "Hip", "LKnee", "LFoot"),
    .body =  c("Nose", "Head", "Neck", "Hip", "Tail")
  ){
  
  ggplot(dat_f) +
    aes(x, y) +
    geom_path(data = dat_f %>% 
                filter(parts %in% .foot) %>% 
                mutate(parts = factor(parts, levels = .foot)) %>% 
                arrange(parts)) +
    geom_path(data = dat_f %>% 
                filter(parts %in% .hands) %>% 
                mutate(parts = factor(parts, levels = .hands)) %>% 
                arrange(parts)) +
    geom_path(data = dat_f %>% 
                filter(parts %in% .body) %>% 
                mutate(parts = factor(parts, levels = .body)) %>% 
                arrange(parts)) +
    geom_point() 
}

gg_OMS_xz <- function(
    dat_f,
    .hands = c("RHand", "RShoulder", "Neck", "LShoulder", "LHand"),
    .foot = c("RFoot", "RKnee", "Hip", "LKnee", "LFoot"),
    .body =  c("Nose", "Head", "Neck", "Hip", "Tail")
  ){
  ggplot(dat_f) +
    aes(x, z) +
    geom_path(data = dat_f %>% 
                filter(parts %in% .foot) %>% 
                mutate(parts = factor(parts, levels = .foot)) %>% 
                arrange(parts)) +
    geom_path(data = dat_f %>% 
                filter(parts %in% .hands) %>% 
                mutate(parts = factor(parts, levels = .hands)) %>% 
                arrange(parts)) +
    geom_path(data = dat_f %>% 
                filter(parts %in% .body) %>% 
                mutate(parts = factor(parts, levels = .body)) %>% 
                arrange(parts)) +
    geom_point() 
}

geom_ad_head <- function(g, dat_f, 
                         .color = "red", 
                         .text = TRUE){
  g <- 
    g +
    geom_path(data = dat_f %>% 
                filter(parts %in% c("Head", "Nose")),
              color = .color, size = 1.5)+
    geom_point(data = dat_f %>% 
                 filter(parts %in% c("Head", "Nose")),
               color = .color, size = 2)
  
  if(.text == TRUE){
    g <-
      g +
      geom_text_repel(aes(label = parts))
  }
  
  return(g)
}






gg_OMS_xy2 <- 
  function(
    dat_f,
    .hands = c("RHand", "RShoulder", "Neck", "LShoulder", "LHand"),
    .foot = c("RFoot", "RKnee", "Hip", "LKnee", "LFoot"),
    .body =  c("Nose", "Head", "Neck", "Hip", "Tail")
  ){
    
    ggplot(dat_f) +
      aes(x, y, group = sec) +
      geom_path(data = dat_f %>% 
                  filter(parts %in% .foot) %>% 
                  mutate(parts = factor(parts, levels = .foot)) %>% 
                  arrange(parts)) +
      geom_path(data = dat_f %>% 
                  filter(parts %in% .hands) %>% 
                  mutate(parts = factor(parts, levels = .hands)) %>% 
                  arrange(parts)) +
      geom_path(data = dat_f %>% 
                  filter(parts %in% .body) %>% 
                  mutate(parts = factor(parts, levels = .body)) %>% 
                  arrange(parts)) 
  }
