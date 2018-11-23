# load_DOE_directories.R
# script to read DOE directory  
# /home/jiml/HotWaterResearch/projects/CECHWT24/2019 ACM tankless/DOE/Water_Heaters_2018-11-23_9-15-54.csv
# started by Jim Lutz "Fri Nov 23 15:01:16 2018"

# set packages & etc
source("setup.R")

# DOE directory filename
fn_DOE_dir <- "/home/jiml/HotWaterResearch/projects/CECHWT24/2019 ACM tankless/DOE/Water_Heaters_2018-11-23_9-15-54.csv"

# read the file
DT_DOE_dir <- data.table( read_csv(file = fn_DOE_dir) )
# Parsed with column specification:
#   cols(
#     Brand_Name_s__s = col_character(),
#     Basic_Model_Number_m = col_character(),
#     Individual_Model_Number_Covered_by_Basic_Model_m = col_character(),
#     Type_of_Heater_s = col_character(),
#     Rated_Storage_Volume__gallons__d = col_double(),
#     Draw_Pattern_s = col_character(),
#     Uniform_Energy_Factor__UEF__d = col_double(),
#     Energy_Factor__EF__d = col_double(),
#     First_Hour_Rating__Gallons__d = col_logical(),
#     Maximum_Gallons_Per_Minute_d = col_double(),
#     Recovery_Efficiency_____d = col_double(),
#     Is_the_Certification_for_this_Basic_Model_Based_on_a_Waiver_of_DOE_s_Test_Procedure_Requirements__s = col_character(),
#     Is_the_Certification_based_upon_any_Exception_Relief_from_an_Applicable_Standard_by_DOE_s_Office_of_Hearing_and_Appeals__s = col_character()
#   )

summary(DT_DOE_dir)
# First_Hour_Rating__Gallons__d is all NA's
# Uniform_Energy_Factor__UEF__d is fraction
# Recovery_Efficiency_____d is percent

# remove First_Hour_Rating__Gallons__d
DT_DOE_dir[, First_Hour_Rating__Gallons__d := NULL]

# look at the Is_the_Certification variables
DT_DOE_dir[ , 
            list(n=length(Is_the_Certification_for_this_Basic_Model_Based_on_a_Waiver_of_DOE_s_Test_Procedure_Requirements__s)),
            by=Is_the_Certification_for_this_Basic_Model_Based_on_a_Waiver_of_DOE_s_Test_Procedure_Requirements__s
            ]
# all of them are No

DT_DOE_dir[ , 
            list(n=length(Is_the_Certification_based_upon_any_Exception_Relief_from_an_Applicable_Standard_by_DOE_s_Office_of_Hearing_and_Appeals__s)),
            by=Is_the_Certification_based_upon_any_Exception_Relief_from_an_Applicable_Standard_by_DOE_s_Office_of_Hearing_and_Appeals__s
            ]
# all of these ones are No as well

# remove those variables
DT_DOE_dir[ ,
            Is_the_Certification_for_this_Basic_Model_Based_on_a_Waiver_of_DOE_s_Test_Procedure_Requirements__s :=
              NULL]
DT_DOE_dir[ ,
            Is_the_Certification_based_upon_any_Exception_Relief_from_an_Applicable_Standard_by_DOE_s_Office_of_Hearing_and_Appeals__s :=
              NULL]

# clean up the names
names(DT_DOE_dir)
setnames(DT_DOE_dir,
         old = c("Brand_Name_s__s",
                 "Basic_Model_Number_m",
                 "Individual_Model_Number_Covered_by_Basic_Model_m",
                 "Type_of_Heater_s",
                 "Rated_Storage_Volume__gallons__d",
                 "Draw_Pattern_s",
                 "Uniform_Energy_Factor__UEF__d",
                 "Energy_Factor__EF__d",
                 "Maximum_Gallons_Per_Minute_d",
                 "Recovery_Efficiency_____d"),
         new = c('brand',
                 'Basic_Model_Number',
                 'Individual_Model_Number',
                 'type',
                 'rated.vol',
                 'draw.pattern',
                 'UEF',
                 'EF',
                 'MaxGPM',
                 'RE')
         )

# now save it as an .Rdata file for late use and clean up
save(DT_DOE_dir, file = "data/DT_DOE_dir.Rdata")

# look at some plots
qplot(x = `UEF`,
      y = `RE`,
      data = DT_DOE_dir)
# looks OK, except some RE == 100 !

# same plot weighted by number of data elements at each point
DT_DOE_dir[ , list(n=length(`brand`)),
             by = c('UEF','RE') ]

ggplot(data = DT_DOE_dir[ , list(n=length(`brand`)),
                          by = c('UEF','RE') ]) +
  geom_point( aes(x = `UEF`,
                  y = `RE`,
                  size = n )
  )
# looks very similar to same chart of CEC data

