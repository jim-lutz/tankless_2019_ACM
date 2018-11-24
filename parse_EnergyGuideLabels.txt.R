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
  cat(l_fn[fn],"\n")
  
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
DT_EGL[c(1,5,22,150,336,340), list(AHRIrefnum, 
                                   EGLtxt = str_sub(EGLtxt, 1, 20)
                                   )] 
