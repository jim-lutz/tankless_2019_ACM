# load_AHRI_directories.R
# script to read AHRI directories of Natural Gas Instantaneous WHs from spreadsheets
# /home/jiml/HotWaterResearch/projects/CECHWT24/2019 ACM tankless/AHRI/2018-11-22
# started by Jim Lutz "Thu Nov 22 14:14:35 2018"

# set packages & etc
source("setup.R")

# set up paths to working directories
wd_AHRI_dirs <- "/home/jiml/HotWaterResearch/projects/CECHWT24/2019 ACM tankless/AHRI/2018-11-22"

# find the xlsx files there
l_fn <-
  list.files(path = wd_AHRI_dirs, pattern = ".*_MaxGPM_.*.xlsx", full.names = TRUE)

# read the files
DT_AHRI_dir <-
  data.table(ldply(l_fn, read_excel, .progress = "text"))

# see what's there
names(DT_AHRI_dir)
nrow(DT_AHRI_dir)
# [1] 340
# OK

# number of AHRI Certified Reference Number
DT_AHRI_dir[ , list(nrefnum = length(unique(`AHRI Certified Reference Number`)))]
# [1] 340
# OK

