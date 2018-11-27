# combine_directories.R

# script to combing DOE, CEC and AHRI tankless WH directories

# set packages & etc
source("setup.R")

# AHRI
DT_AHRI <- data.table(read_csv(file = "data/DT_AHRI_dir.csv"))
names(DT_AHRI)
write_csv(data.table(AHRInames = names(DT_AHRI)), 
          path = "data/AHRInames.csv")

# Energy Guide labels
load("data/DT_EGL.Rdata")
names(DT_EGL)
write_csv(data.table(EGLnames = names(DT_EGL)), 
          path = "data/EGLnames.csv")

# DOE directory
load("data/DT_DOE_dir.Rdata")
names(DT_DOE_dir)
write_csv(data.table(DOEnames = names(DT_DOE_dir)), 
          path = "data/DOEnames.csv")

# CEC directory
load("data/DT_CEC_dir.Rdata")
names(DT_CEC_dir)
write_csv(data.table(CECnames = names(DT_CEC_dir)), 
          path = "data/CECnames.csv")



