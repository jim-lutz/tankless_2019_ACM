# parse_EnergyGuideLabels.txt.R
# script to parse the AHRI Energy Guide labels text files in
# /home/jiml/HotWaterResearch/projects/CECHWT24/2019 ACM tankless/tankless_2019_ACM/data/tiff/
# started by Jim Lutz "Sat Nov 24 10:34:19 2018"

# set packages & etc
source("setup.R")

# build a list of the text files there
l_fn <-
  list.files(path = "data/tiff", pattern = "*.txt", full.names = TRUE)
# 340 of them

# make a blank data.table to hold everything
DT_EGL <- data.table(character(length = length(l_fn))) #  creates a 0-row data.table

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
  
  # put into the data.table for debugging later
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

# look at all the MaxGPMs
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

# look at all the brands
DT_EGL[, list(n = length(AHRIrefnum)),
       by=brand][order(-n)]
# looks reasonable

DT_EGL[is.na(brand) & !is.na(EGL),
       list(AHRIrefnum, 
            EGL = str_sub(EGL, 1, 20),
            brand
            )
       ] 


# get the model number
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

# look at all the model_num
DT_EGL[, list(n = length(AHRIrefnum)),
       by=model_num][order(-n)]
# 7 missing, 2 duplicates, only 1 of everything else

DT_EGL[is.na(model_num) & EGL != "",
       list(AHRIrefnum, 
            EGL = str_sub(EGL, 1, 20),
            model_num
            )
       ] 

