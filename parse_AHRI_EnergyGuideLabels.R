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
for( fn in 1:length(l_fn) ) { 
  # for development use c(1,22,150,340)
  # for production use 1:length(l_fn)
  
  # show the filename
  # cat(l_fn[fn],"\n")

  # just the AHRIrefnum
  AHRIrefnum <- str_extract(l_fn[fn],"[0-9]{6,}")
  
  cat(AHRIrefnum,"\n")
  
  # extract images to a tiff file with pdfimages
  system2(command = "pdfimages",
          args = c("-tiff",   # Change the default output format to TIFF.
                   paste0("'",l_fn[fn],"'"), # PDF-file
                   paste0("data/tiff/",AHRIrefnum) ) # image-root
          )
  
  # use convert from imagemagick to change the threshold to turn it black and white
  system2(command = "convert",  # convert [input-option] input-file [output-option] output-file
          args = c(paste0("data/tiff/",AHRIrefnum,"-000.tif"), # input-file
                   "-threshold", "50%", "-unsharp", "10",      # output-options
                   paste0("data/tiff/",AHRIrefnum,"-001.tif")  # output-file
                   )
          )
  
  # OCR using tesseract
  system2(command = "tesseract",  # tesseract imagename|stdin outputbase|stdout [options...]
          args = c(paste0("data/tiff/",AHRIrefnum,"-001.tif"), # imagename
                   paste0("data/tiff/",AHRIrefnum,"-001")    # outputbase
                   )
          )

  # now clean up, remove since they're so big
  unlink("data/tiff/*.tif")
  
}


