# elec_calcs.R
# calculate Eannual,e and F by manufacturer
# input is data DT_EGL.Rdata
# started by Jim Lutz "Sat Nov 24 15:41:17 2018"

# set packages & etc
source("setup.R")

# load DT_EGL
load(file = "data/DT_EGL.Rdata")
names(DT_EGL)

# read in DT_AHRI_dir.csv
DT_AHRI <- data.table(read_csv(file = "data/DT_AHRI_dir.csv"))
names(DT_AHRI)

# merge only useful fields
DT_params <-
  merge(DT_EGL[,list(AHRIrefnum,
                     MaxGPM,
                     brand,
                     model_num,
                     Eannual_f)],
        DT_AHRI[,list(AHRIrefnum = as.character(AHRIrefnum),
                      MaxGPM2    = `Max GPM`,
                      brand2     = `Brand Name`,
                      model_num2 = `Model Number`,
                      UEF        = `Uniform Energy Factor`,
                      Qin_rated  = `Input (MBtu/h)`,
                      RE         = `UED Recovery Efficiency, %`)
                ],
        by='AHRIrefnum')

# make sure MaxGPM matches
DT_params[MaxGPM!=MaxGPM2]
# Empty data.table (0 rows) of 11 cols

# make sure brand matches
DT_params[brand!=brand2]
# Empty data.table (0 rows) of 11 cols

# trim off space in model_nums
DT_params[, model_num := str_trim(model_num)]
DT_params[, model_num2 := str_trim(model_num2)]

# change 199O to 1990 in modelnum2
DT_params[, model_num2 := str_replace(model_num2,"199O", "1990")]

# change '-1 2' to '-I 2' in modelnum
DT_params[, model_num := str_replace(model_num, "\\-1 2", '-I 2')]

# make sure model_num matches
DT_params[model_num!=model_num2,
          list(model_num, model_num2)]
# Empty data.table (0 rows) of 2 cols: model_num,model_num2

# remove duplicate columns
DT_params[, c('MaxGPM2', 'brand2', 'model_num2') := NULL]




# instantaneous water heaters					
# from /home/jiml/HotWaterResearch/projects/CECHWT24/2019 ACM tankless/spreadsheet models/UEF draw patterns.v22.xls
# bin        FMax   Qout V_UEF Ndraws              GPM
# very small    0  5,452    10      9   0 ≤ FMax < 1.7
# low          18 20,718    38     11 1.7 ≤ FMax < 2.8
# medium       51 29,987    55     12 2.8 ≤ FMax < 4.0
# high         75 45,798    84     14       4.0 ≤ FMax     

