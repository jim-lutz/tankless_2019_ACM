# parse_EnergyGuideLabels.txt.R
# script to parse the AHRI Energy Guide labels text files
# input is data/tiff/*.txt
# output is data DT_EGL.Rdata
# started by Jim Lutz "Sat Nov 24 10:34:19 2018"

# set packages & etc
source("setup.R")

# build a list of the text files there
l_fn <-
  list.files(path = "data/tiff", pattern = "*.txt", full.names = TRUE)
# 340 of them

# make a blank data.table to hold everything
DT_EGL <- data.table(character(length = length(l_fn))) #  creates a 340-row data.table

# loop through the txt files
for( fn in 1:length(l_fn) ) { 
  # for development use c(1,5,22,150,336,340)
  # for production use 1:length(l_fn)
  
  # show the filename
  # cat(l_fn[fn],"\n")
  
  # get the AHRIrefnum from the filename
  DT_EGL[fn, AHRIrefnum := str_extract(l_fn[fn], "[0-9]{6,}" )]
  
  # slurp in the file
  EGLtxt <- read_file(file = l_fn[fn] )
  
  # remove line breaks, returns & EOF
  EGLtxt <- str_replace_all(EGLtxt, "[\r\n\f]" , " ")
  
  # put into the data.table for parsing later
  DT_EGL[fn, EGL := EGLtxt]

}

DT_EGL 

# here's a sample of files to examine while developing parsing commands
# mousepad data/tiff/10014414-001.txt &
# mousepad data/tiff/4397486-001.txt &
# mousepad data/tiff/9970164-001.txt &
# mousepad data/tiff/10014415-001.txt &

# now build items of interest from the data.table

# get the MaxGPM
DT_EGL[, MaxGPM := str_extract(EGL, "\\:.+ g[op]m Model")]
DT_EGL[, MaxGPM := as.numeric(str_sub(MaxGPM, 2, 5))]

# look at some entries in the data.table
DT_EGL[AHRIrefnum %in% c('10014414', '4397486', '9970164', '10014415'),
       list(AHRIrefnum, 
            EGL = str_sub(EGL, 1, 20),
            MaxGPM
            )
       ] 

# list the number of AHRIrefnums by MaxGPM
DT_EGL[, list(n = length(AHRIrefnum)),
       by=MaxGPM][order(MaxGPM)]
# looks reasonable

# get the brand
DT_EGL[, brand := str_extract(EGL, "Gas [A-Z. /]+ Capacity")]
DT_EGL[, brand := str_replace(brand, "Gas ", "")]
DT_EGL[, brand := str_replace(brand, " Capacity", "")]

# look at some entries in the data.table
DT_EGL[AHRIrefnum %in% c('10014414', '4397486', '9970164', '10014415'),
       list(AHRIrefnum, 
            EGL = str_sub(EGL, 1, 20),
            brand
            )
       ] 

# look at the number of AHRIrefnums by brand
DT_EGL[, list(n = length(AHRIrefnum)),
       by=brand][order(-n)]
# looks reasonable

# find AHRIrefnum that are missing brands
DT_EGL[is.na(brand) & !is.na(EGL),
       list(AHRIrefnum, 
            EGL = str_sub(EGL, 1, 20),
            brand
            )
       ] 

# get the model numbers
DT_EGL[, model_num := str_extract(EGL, "Model [A-Z0-9l. -]+ Estimated")]
DT_EGL[, model_num := str_replace(model_num, "Model ", "")]
DT_EGL[, model_num := str_replace(model_num, " Estimated", "")]

# fix 'l' to 'I'
DT_EGL[, model_num := str_replace(model_num, "l", "I")]

# look at some entries in the data.table
DT_EGL[AHRIrefnum %in% c('10014414', '4397486', '9970164', '10014415'),
       list(AHRIrefnum, 
            brand,
            model_num
            )
       ] 

# look at at the number of AHRIrefnums by model_num
DT_EGL[, list(n = length(AHRIrefnum)),
       by=model_num][order(-n)]
# 5 missing, 2 duplicates, only 1 of everything else

DT_EGL[is.na(model_num) & EGL != "",
       list(AHRIrefnum, 
            EGL = str_sub(EGL, 1, 20),
            model_num
            )
       ] 


# get Eannual,f (if that's what it is)
# get the model number
DT_EGL[, Eannual_f := str_extract(EGL, "Estimated yearly energy use: [0-9.]+ therms")]
DT_EGL[, Eannual_f := str_replace(Eannual_f, "Estimated yearly energy use: ", "")]
DT_EGL[, Eannual_f := str_replace(Eannual_f, " therms", "")]

# convert to numeric
DT_EGL[, Eannual_f := as.numeric(Eannual_f)]

# look at some entries in the data.table
DT_EGL[AHRIrefnum %in% c('10014414', '4397486', '9970164', '10014415'),
       list(AHRIrefnum, 
            brand,
            Eannual_f
       )
       ] 

# look at all the model_num
DT_EGL[, list(n = length(AHRIrefnum)),
       by=Eannual_f][order(-n)]
# 5 missing, rest look reasonable

DT_EGL[is.na(Eannual_f) & EGL != "",
       list(AHRIrefnum, 
            EGL = str_sub(EGL, 1, 20),
            Eannual_f
            )
       ] 
# Empty data.table (0 rows) of 3 cols: AHRIrefnum,EGL,Eannual_f

# look at some plots
qplot(x = `Eannual_f`,
      data = DT_EGL)

# see if differences by brand
ggplot(data = DT_EGL) +
  geom_bar( aes(x = Eannual_f), width = 1 ) +
  facet_wrap(vars(brand))
# looks plausible

# get the Estimated Yearly Energy Cost
DT_EGL[, Eannual_cost := str_extract(EGL, "Energy Cost+.+Cost Range")]
DT_EGL[, Eannual_cost2 := str_extract(Eannual_cost, "[0-9$]{4}( |,)")]
DT_EGL[str_detect(Eannual_cost2,"^9"), Eannual_cost3 := str_replace(Eannual_cost2,"9","$") ]

# make sure nothing is missiong
DT_EGL[is.na(Eannual_cost), list(AHRIrefnum, Eannual_cost)]
DT_EGL[is.na(Eannual_cost2), list(AHRIrefnum, Eannual_cost, Eannual_cost2)]

# tesseract problems with $196?
DT_EGL[is.na(Eannual_cost2), list(AHRIrefnum, Eannual_cost, Eannual_cost2)]
DT_EGL[is.na(Eannual_cost2) & !is.na(Eannual_cost), list(AHRIrefnum, Eannual_cost, Eannual_cost2)]
DT_EGL[is.na(Eannual_cost2) & !is.na(Eannual_cost), AHRIrefnum]


DT_EGL[str_detect(Eannual_cost2,"196"),list(AHRIrefnum, Eannual_cost, Eannual_cost2, Eannual_cost3)]

DT_EGL[str_detect(Eannual_cost,"[0-9]"), list(AHRIrefnum, Eannual_cost)]


# convert to numeric
DT_EGL[, Eannual_cost := as.numeric(str_sub(Eannual_cost,2,4))]

# look at some plots
qplot(x = `Eannual_cost`,
      data = DT_EGL)

# look at the values
summary(DT_EGL$Eannual_cost)


# save DT_EGL as .Rdata for later use
save(DT_EGL, file = "data/DT_EGL.Rdata")

  



