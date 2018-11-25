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
                      bin        = `Usage Bin`,
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

names(DT_params)

# count records by bin
DT_params[,list(n=length(AHRIrefnum)), by=bin]
#             bin   n
# 1:   High Usage 267
# 2: Medium Usage  73

# instantaneous water heaters					
# from /home/jiml/HotWaterResearch/projects/CECHWT24/2019 ACM tankless/spreadsheet models/UEF draw patterns.v22.xls
# bin        FMax   Qout V_UEF Ndraws              GPM
# very small    0  5,452    10      9   0 ≤ FMax < 1.7
# low          18 20,718    38     11 1.7 ≤ FMax < 2.8
# medium       51 29,987    55     12 2.8 ≤ FMax < 4.0
# high         75 45,798    84     14       4.0 ≤ FMax     

# add Qout.UEF by bin
DT_params[bin == 'High Usage',   Qout.UEF := 45798 ]
DT_params[bin == 'Medium Usage', Qout.UEF := 29987 ]

# Calculate Eannual,e annual electicity consumption in kWh
 DT_params[, Eannual_e := ( (Qout.UEF / UEF) * 365 - (Eannual_f * 100000) ) / 3412 ]

# see what it looks like
qplot(x = `Eannual_e`,
      data = DT_params)
# negative numbers?

# look at some partial results
DT_params[c(1,5,22,150,336,340)]$UEF
# [1] 0.93 0.93 0.93 0.79 0.81 0.81
# OK

# Qin, annual total input
DT_params[c(1,5,22,150,336,340)]$Qout.UEF/
  DT_params[c(1,5,22,150,336,340)]$UEF * 365 
# [1] 17974484 17974484 17974484 13854753 13512660 20637370
# OK

# Qin_f, annual fossil input 
DT_params[c(1,5,22,150,336,340)]$Eannual_f * 100000
# [1] 18200000 18200000 18200000 14000000 13700000 20900000
# this is bigger than total?

# plot Qin vs Qin_f in BTU
DT_params[, Qin := (Qout.UEF/UEF) * 365 ]
DT_params[, Qin_f := Eannual_f * 100000 ]

qplot(x = Qin_f,
      y = Qin,
      data = DT_params)
# looks like it was calculated

# check the fit
fit <- lm( Qin ~ Qin_f, data=DT_params[!is.na(Qin_f) & !is.na(Qin)])
summary(fit)
# Call:
#   lm(formula = Qin ~ Qin_f, data = DT_params[!is.na(Qin_f) & !is.na(Qin)])
# 
# Residuals:
#   Min     1Q Median     3Q    Max 
# -52690 -12915  -4563  29497  44838 
# 
# Coefficients:
#   Estimate Std. Error  t value Pr(>|t|)    
# (Intercept) -3.277e+04  9.457e+03   -3.465 0.000607 ***
#   Qin_f        9.897e-01  5.124e-04 1931.490  < 2e-16 ***
#   ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Residual standard error: 25520 on 297 degrees of freedom
# Multiple R-squared:  0.9999,	Adjusted R-squared:  0.9999 
# F-statistic: 3.731e+06 on 1 and 297 DF,  p-value: < 2.2e-16

# obviously not independent measurement,
# well within rounding errors
