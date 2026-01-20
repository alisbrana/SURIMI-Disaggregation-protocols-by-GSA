setwd("C:/Users/LENOVO/Gama_Workspace/surimi/includes")

library(dplyr)

df <- read.csv("vessel_by_port.csv",sep=",")
b <- df %>% group_by(MMSI,vlength) %>% distinct(MMSI,vlength)

dfp <- read.csv("vessel_by_cell.csv",sep=",")
a <- dfp %>% group_by(MMSI,vlength) %>% distinct(MMSI,vlength)

# to merge only df vessel and add gear
dfp_noid <- dfp %>% select(-id) %>% distinct(MMSI,vlength,gear)
  
fin <- left_join(df,dfp_noid, by=c("MMSI","vlength"))
write.csv(fin,file="combined_vessel.csv",row.names = F)
