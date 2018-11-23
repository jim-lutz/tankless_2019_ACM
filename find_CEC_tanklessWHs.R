# find_CEC_tanklessWHs.R
# script to find the tankless WHs in the CEC directory  
# started by Jim Lutz "Fri Nov 23 10:20:02 2018"

# set packages & etc
source("setup.R")

# load the CEC WH directory
load("data/DT_CEC_dir.Rdata")

names(DT_CEC_dir)
# 14985

# extract just the tankless WHs
DT_CEC_dir[`Energy Source` == "Natural Gas"]
# 8341

# and only ones rated by MaxGPM
DT_CEC_dir[`Energy Source` == "Natural Gas" &
             `Maximum GPM`  >  0 ]
# 1886

# with a rated UEF
DT_CEC_dir[`Energy Source` == "Natural Gas" &
             `Maximum GPM`  >  0 &
             `Uniform Energy Factor` > 0]
# 665

# pull over just those into a new data.table
DT_tankless <- DT_CEC_dir[`Energy Source` == "Natural Gas" &
                            `Maximum GPM`  >  0 &
                            `Uniform Energy Factor` > 0]

# are any columns completely NA?
summary(DT_tankless)
# `Pilot Light? (T/F)` vast majority are TRUE?
# `Heattraps` is FALSE or NA
# `First Hour Rating` is 0 or NA
# `Insulation Type` ? some Ozone depleting
# `First Hour Rating` are all NA
# `Recovery Efficiency` are as percents
# `Annual Energy Consumption KBTU` are all NA
# `Energy Factor` about half are NA
# `Energy Factor Std` are all NA
# `Pilot Light BTUH` are mostly zero, a few numeric <= 1 BTUH ?

# where are the ~300 ones?
order(DT_tankless$`Pilot Light BTUH`)
summary(DT_tankless$`Pilot Light BTUH`)
#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
# 0.00000 0.00000 0.00000 0.02744 0.00000 1.00000       9 

# they might be character?
str(DT_tankless)
# no

DT_tankless[`Pilot Light BTUH`>0.0, list(`Pilot Light BTUH`)]

DT_tankless[`Maximum GPM`>=1.5 &
              `Maximum GPM`<=2.5, 
            list(`Pilot Light BTUH`,`Maximum GPM`)]

DT_CEC_dir[`Maximum GPM`>=1.5 &
              `Maximum GPM`<=2.5, 
            list(`Pilot Light BTUH`,`Maximum GPM`)][order(-`Pilot Light BTUH`)]
# was getting confused between tankless and non-tankless in DT_CEC_dir
# only 0 | 1 | NA DT_tankless

# 
# look at some plots
qplot(x = `Uniform Energy Factor`,
      y = `Recovery Efficiency`,
      data = DT_tankless)
# looks OK, except some RE == 100 !
# 
