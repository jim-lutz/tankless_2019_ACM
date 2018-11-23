# find_CEC_tanklessWHs.R
# script to find the tankless WHs in the CEC directory  
# started by Jim Lutz "Fri Nov 23 10:20:02 2018"

# set packages & etc
source("setup.R")

# load the CEC WH directory
load("data/DT_CEC_dir.Rdata")

names(DT_CEC_dir)
# [1] "Manufacturer"                       "Brand"                             
# [3] "Model Number"                       "Energy Source"                     
# [5] "Pilot Light? (T/F)"                 "Heattraps"                         
# [7] "Insulation Type"                    "Mobile Home?"                      
# [9] "Rated Volume"                       "First Hour Rating"                 
# [11] "Maximum GPM"                        "Input BTUH"                        
# [13] "Recovery Efficiency"                "Annual Energy Consumption KBTU"    
# [15] "Energy Factor"                      "Energy Factor Std"                 
# [17] "Tested Uniform Energy Factor (T/F)" "Pilot Light BTUH"                  
# [19] "Uniform Energy Factor"              "Regulatory Status"                 
# [21] "Uniform Energy Factor Std"          "Add Date"                          
# [23] "Add_Date"  

DT_CEC_dir
# 14985

# extract just the natural gas WHs
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

# pull over just these into a new data.table
DT_tankless <- DT_CEC_dir[`Energy Source` == "Natural Gas" &
                            `Maximum GPM`  >  0 &
                            `Uniform Energy Factor` > 0]

# are any columns completely NA? or have other problems?
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
# `Uniform Energy Factor` are as fractions
# `Uniform Energy Factor Std` is all .81? Yeah that's OK, fed minimums
# `Add_Date` are all since 2017-08-24,  good

# remove unneeded variables
DT_tankless[, c("Energy Source",
                "Pilot Light? (T/F)",
                "Heattraps",
                "Insulation Type", 
                "Mobile Home?",
                "First Hour Rating",
                "Energy Factor",
                "Energy Factor Std",
                "Tested Uniform Energy Factor (T/F)",
                "Pilot Light BTUH",
                "Regulatory Status",
                "Uniform Energy Factor Std",
                "Add Date"
                ) := NULL]

# clean up names of DT_tankless
names(DT_tankless)

# fix names
setnames(DT_tankless,
         old = c("Maximum GPM",
                 "Input BTUH",
                 "Recovery Efficiency",
                 "Annual Energy Consumption KBTU",
                 "Uniform Energy Factor"),
         new = c('MaxGPM',
                 "Input BTUH",
                 "RE",
                 "Qan",
                 "UEF")
        )

# look at some plots
qplot(x = `UEF`,
      y = `RE`,
      data = DT_tankless)
# looks OK, except some RE == 100 !

# same plot weighted by number of data elements at each point
DT_tankless[ , list(n=length(`Manufacturer`)),
             by = c('UEF','RE') ]

ggplot(data = DT_tankless[ , list(n=length(`Manufacturer`)),
                           by = c('UEF','RE') ]) +
  geom_point( aes(x = UEF,
                  y = RE,
                  size = n )
            )

# save DT_tankless as .Rdata for later use
save(DT_tankless, file = "data/DT_tankless_CEC.Rdata")

