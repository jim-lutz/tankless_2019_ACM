# combine_directories.R
# script to combine DOE, CEC and AHRI tankless WH directory names
# into data/dirnames.xlsx

# set packages & etc
source("setup.R")

# use openxlsx to make workbook with one sheet per data.table
#  Create a new workbook
wb <- createWorkbook()

# AHRI
DT_AHRI <- data.table(read_csv(file = "data/DT_AHRI_dir.csv"))

# add a worksheet to the workbook
addWorksheet(wb, sheetName = "AHRI")

# put in the data
writeData(wb, sheet = "AHRI", data.table(AHRInames = names(DT_AHRI)))


# Energy Guide labels
load("data/DT_EGL.Rdata")
names(DT_EGL)

# add a worksheet to the workbook
addWorksheet(wb, sheetName = "EGL")

# put in the data
writeData(wb, sheet = "EGL", data.table(EGLnames = names(DT_EGL) ) )


# DOE directory
load("data/DT_DOE_dir.Rdata")
names(DT_DOE_dir)

# add a worksheet to the workbook
addWorksheet(wb, sheetName = "DOE")

# put in the data
writeData(wb, sheet = "DOE", data.table(DOEnames = names(DT_DOE_dir) ) )


# CEC directory
load("data/DT_CEC_dir.Rdata")
names(DT_CEC_dir)

# add a worksheet to the workbook
addWorksheet(wb, sheetName = "CEC")

# put in the data
writeData(wb, sheet = "CEC", data.table(CECnames = names(DT_CEC_dir) ) )

# save the workbook
saveWorkbook(wb, "data/dirnames.xlsx", overwrite = TRUE)


