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

# clean up ref num name
setnames(DT_AHRI_dir, old = "AHRI Certified Reference Number", new = "AHRIrefnum")

# save DT_AHRI_dir as csv
write_csv(DT_AHRI_dir, path = "data/DT_AHRI_dir.csv")

# make a the urls for EnergyGuide labels
# https://www.ahridirectory.org/Certificate/RenderFTCLabel?ReferenceId=5526763&Program=24
url.1 <- "https://www.ahridirectory.org/Certificate/RenderFTCLabel?ReferenceId="
url.2 <- "&Program=24"
DT_AHRI_dir[ , url := paste0(url.1,AHRIrefnum,url.2)]

# directory for Energy Guide Labels
egl_dir <- "/home/jiml/HotWaterResearch/projects/CECHWT24/2019 ACM tankless/AHRI/2018-11-22/EnergyGuideLabels/"

# loop through all the ref numbers
with(DT_AHRI_dir, {
  for(rn in 1:nrow(DT_AHRI_dir) ) { # 1:2 for testing
    download.file(url = DT_AHRI_dir$url[rn],
                  destfile = paste0(egl_dir,
                                    DT_AHRI_dir$AHRIrefnum[rn],
                                    ".pdf"),
                  mode = "wb")
    }
  }
)  
