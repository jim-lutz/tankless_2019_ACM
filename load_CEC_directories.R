# load_CEC_directories.R
# script to read CEC directory  
# /home/jiml/HotWaterResearch/projects/CECHWT24/2019 ACM tankless/CEC/2018-11-23 Small Gas & Oil Water Htrs.csv
# started by Jim Lutz "Fri Nov 23 06:20:25 2018"

# set packages & etc
source("setup.R")

# CEC directory filename
fn_CEC_dir <- "/home/jiml/HotWaterResearch/projects/CECHWT24/2019 ACM tankless/CEC/2018-11-23 Small Gas & Oil Water Htrs.csv"

# specify column types for read_csv, see cols()
col_type <- 'cccc||c|dddididd|idcdD'
  # Manufacturer	c	character
  # Brand	c	character
  # Model Number	c	character
  # Energy Source	c	character
  # Pilot Light? (T/F)	|	logical
  # Heattraps	|	logical
  # Insulation Type	c	character
  # Mobile Home?	|	logical
  # Rated Volume	d	double
  # First Hour Rating	d	double
  # Maximum GPM	d	double
  # Input BTUH	i	integer
  # Recovery Efficiency	d	double
  # Annual Energy Consumption KBTU	i	integer
  # Energy Factor	d	double
  # Energy Factor Std	d	double
  # Tested Uniform Energy Factor (T/F)	|	logical
  # Pilot Light BTUH	i	integer
  # Uniform Energy Factor	d	double
  # Regulatory Status	c	character
  # Uniform Energy Factor Std	d	double
  # Add Date	D	date

# read the file
DT_CEC_dir <- data.table( read_csv(file = fn_CEC_dir,
                                   # col_types = col_type,
                                   guess_max = 15000) )
# Error in is.list(col_types) : Unknown shortcut: |
# In addition: Warning message:
# Missing column names filled in: 'X23' [23] 

# see what's there
names(DT_CEC_dir)

# remove X23
DT_CEC_dir[, X23:=NULL]

nrow(DT_CEC_dir)
# [1] 14985

str(DT_CEC_dir)
# $ Uniform Energy Factor             : logi  NA NA NA NA NA NA ...
# the logical columns are logicals
# 'Add Date' came in as character

summary(DT_CEC_dir)



# have to subset this for tanless WHs


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
