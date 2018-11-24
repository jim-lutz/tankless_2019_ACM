# parse_AHRI_EnergyGuideLabels.R
# script to parse the AHRI Energy Guide labels pdf files of Natural Gas Instantaneous WHs in
# /home/jiml/HotWaterResearch/projects/CECHWT24/2019 ACM tankless/AHRI/2018-11-22/EnergyGuideLabels/
# started by Jim Lutz "Fri Nov 23 16:50:31 2018"

# based on /home/jiml/HotWaterResearch/projects/CECHWT24/2016/2016 CBECC UEF/default tankless/EnergyGuide labels/energyguide.pl
# calls pdfimages to extract the images out of the AHRIEnergyGuide_xxx.pdf files as tiff files
# calls tesseract to OCR the tiff files to text
# extracts manufacturer, MaxGPM, model, yearly_cost, yearly_therms from the text file
# puts pdfname and values into a csv file for later processing.

# set packages & etc
source("setup.R")

# set up path to working directory
wd_EGLs <- "/home/jiml/HotWaterResearch/projects/CECHWT24/2019 ACM tankless/AHRI/2018-11-22/EnergyGuideLabels"

# get a list of the pdf files there
l_fn <-
  list.files(path = wd_EGLs, pattern = "*.pdf", full.names = TRUE)
# 340 of them

# make a blank data.table to hold everything
DT_EGL <- data.table()

# loop through the pdf files
for( fn in c(1,4,22,50,340) ) { # for development use l_fn[c(1,4,22,50,340)
  # show the filename
  #cat(l_fn[fn],"\n")

  # just the AHRIrefnum
  AHRIrefnum <- str_extract(l_fn[fn],"[0-9]{6,}")
  
  cat(AHRIrefnum,"\n")
  
  args = c("-tiff", paste0("'",l_fn[fn],"'"), paste0("data/tiff/",AHRIrefnum) )
  cat(args,"\n")
  
  # extract a tiff file with pdfimages
  system2(command = "pdfimages",
          args
          )

}
  
