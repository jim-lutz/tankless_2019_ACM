# AHRI_basic_models.R
# script to get basic models from the AHRI tankless WH directory
# where basic models are defined by UEF, RE & MaxGPM

# set packages & etc
source("setup.R")

# AHRI
DT_AHRI <- data.table(read_csv(file = "data/DT_AHRI_dir.csv"))

# column specifications
spec(read_csv(file = "data/DT_AHRI_dir.csv"))
str(DT_AHRI)
names(DT_AHRI)

# remove NA only columns
DT_AHRI[ , names(which(unlist(lapply(DT_AHRI, function(x)all(is.na(x)))))) := NULL]  

# rename columns to work with
setnames(DT_AHRI, 
         old = c("Uniform Energy Factor",
                 "UED Recovery Efficiency, %",
                 "Max GPM"),
         new = c("UEF", "RE", "MaxGPM")
         )

# review UEF, RE & MaxGPM data
summary(DT_AHRI[, list(UEF,RE,MaxGPM)])
#     UEF               RE            MaxGPM     
# Min.   :0.7900   Min.   :79.00   Min.   :3.100  
# 1st Qu.:0.8100   1st Qu.:83.00   1st Qu.:4.450  
# Median :0.8200   Median :85.00   Median :4.850  
# Mean   :0.8594   Mean   :89.29   Mean   :4.719  
# 3rd Qu.:0.9300   3rd Qu.:96.00   3rd Qu.:5.200  
# Max.   :0.9600   Max.   :99.00   Max.   :5.900  
# NA's   :41                                      

# what's with the missing UEFs?
DT_AHRI[is.na(UEF)]
# a bunch of Rheem models

# keep the others
DT_AHRI <- 
  DT_AHRI[!is.na(UEF)]

# convert RE to fraction
DT_AHRI[, RE := RE/100]

# count of records for each set
DT_AHRI_mdlcount <-
  DT_AHRI[ , list(nAHRIrefnum = .N),
           by=c("MaxGPM","UEF","RE")][order(-MaxGPM, -UEF)]

# add a mdlnum
DT_AHRI_mdlcount[, mdlnum := .I]

# look at some plots
# https://www.r-bloggers.com/example-9-17-much-better-pairs-plots/



