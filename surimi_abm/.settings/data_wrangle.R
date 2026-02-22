setwd("C:/Users/LENOVO/Gama_Workspace/surimi/includes")

library(dplyr)
library(sf)
library(tidyr)

df <- read.csv("vessel_by_port.csv",sep=",")
b <- df %>% group_by(MMSI,vlength) %>% distinct(MMSI,vlength)

dfp <- read.csv("vessel_by_cell.csv",sep=",")
a <- dfp %>% group_by(MMSI,vlength) %>% distinct(MMSI,vlength)

# to merge only df vessel and add gear
dfp_noid <- dfp %>% select(-id) %>% distinct(MMSI,vlength,gear)
  
fin <- left_join(df,dfp_noid, by=c("MMSI","vlength"))

spe <- read.csv("spe_by_port.csv",sep=",")

effort_cell <- read.csv("effort_by_cell.csv",sep=",")

#write.csv(fin,file="combined_vessel.csv",row.names = F)

# shape <- st_read("SMART_Data/IBM.agg.grid.shp")
# tapply(shape$CFR, shape$harbour, function(x) length(unique(x)))
# 
# 
# 
# shape %>%
#   group_by(CFR) %>%
#   summarise(
#     n_harbour = n_distinct(harbour),
#     .groups = "drop"
#   ) %>%
#   filter(n_harbour > 1)
# 
# shape$harbour[shape$CFR == "boat_23" & is.na(shape$harbour)] <- "PORTO SANTO STEFANO"
# shape <- st_zm(shape, drop = TRUE, what = "ZM")
# st_write(shape, "SMART_Data/IBM.agg.grid_RP.shp")
shape %>%
  group_by(CFR) %>%
  summarise(
    n_Gear = n_distinct(Gear),
    .groups = "drop"
  ) %>%
  filter(n_Gear > 1)
##
shape <- st_read("SMART_Data/IBM.agg.grid_RP.shp")
grid <- st_read("SMART_Data/grid_sf.shp")


shape_byspecies <- shape %>%
  group_by(id_grid, Species) %>%
  mutate(W_mean_sum = sum(W_mean, na.rm = TRUE)) %>%
  ungroup() %>%
  pivot_wider(
    names_from  = Species,
    values_from = W_mean_sum,
    names_glue  = "{Species}_W_mean"
  ) 

shape <- as.data.frame(shape)
shape_byspecies <- as.data.frame(shape_byspecies)

shapefin <- merge(shape, shape_byspecies, by = c("CFR","id_grid","MONTH","Gear","VL","harbour","effrt_m",
                                                 "lpue_mn","Pric_mn","GVL_men","depth","geometry"), all.x = TRUE)
shapefin <- st_as_sf(shapefin)
shapefin <- st_zm(shapefin, drop = TRUE, what = "ZM")
st_write(shapefin, "SMART_Data/IBM.agg.grid_RP2.shp")

nogrid <- grid %>% filter(id_grid %in% shapefin$id_grid)
length(unique(shapefin$id_grid))

unique(shapefin$W_mean.x != shapefin$W_mean.y)
