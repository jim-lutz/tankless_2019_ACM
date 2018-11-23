# load_CEC_directories.R
# script to read CEC directory  
# /home/jiml/HotWaterResearch/projects/CECHWT24/2019 ACM tankless/CEC/2018-11-23 Small Gas & Oil Water Htrs.csv
# started by Jim Lutz "Fri Nov 23 06:20:25 2018"

# set packages & etc
source("setup.R")

# CEC directory filename
fn_CEC_dir <- "/home/jiml/HotWaterResearch/projects/CECHWT24/2019 ACM tankless/CEC/2018-11-23 Small Gas & Oil Water Htrs.csv"

# read the file
DT_CEC_dir <- data.table( read_csv(file = fn_CEC_dir,
                                   guess_max = 15000) )
  # Parsed with column specification:
  #   cols(
  #     .default = col_double(),
  #     Manufacturer = col_character(),
  #     Brand = col_character(),
  #     `Model Number` = col_character(),
  #     `Energy Source` = col_character(),
  #     `Pilot Light? (T/F)` = col_logical(),
  #     Heattraps = col_logical(),
  #     `Insulation Type` = col_character(),
  #     `Mobile Home?` = col_logical(),
  #     `Tested Uniform Energy Factor (T/F)` = col_logical(),
  #     `Regulatory Status` = col_character(),
  #     `Add Date` = col_character(),
  #     X23 = col_logical()
  #   )
  # See spec(...) for full column specifications.
  # Warning message:
  #   Missing column names filled in: 'X23' [23] 

# see what's there
names(DT_CEC_dir)

# remove X23
DT_CEC_dir[, X23:=NULL]

nrow(DT_CEC_dir)
# [1] 14985

str(DT_CEC_dir)
# the logical columns are logicals
# 'Add Date' came in as character

summary(DT_CEC_dir)
# seems like it came in as it was saved

# change 'Add Date' to POSIXct with time zone attribute set to tz.
DT_CEC_dir[, Add_Date := mdy(`Add Date`, tz = 'America/Los_Angeles')]

# now save it as an .Rdata file for late use and clean up
save(DT_CEC_dir, file = "data/DT_CEC_dir.Rdata")

