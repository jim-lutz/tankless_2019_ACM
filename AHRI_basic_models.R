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
                 "Max GPM",
                 "Input (MBtu/h)",
                 "Usage Bin"),
         new = c("UEF", "RE", "MaxGPM", "Input.rated", "bin")
         )

# review UEF, RE & MaxGPM data
summary(DT_AHRI[, list(UEF,RE,MaxGPM,Input.rated, bin)])
  #      UEF               RE            MaxGPM       Input.rated        bin           
  # Min.   :0.7900   Min.   :79.00   Min.   :3.100   Min.   :120.0   Length:340        
  # 1st Qu.:0.8100   1st Qu.:83.00   1st Qu.:4.450   1st Qu.:160.0   Class :character  
  # Median :0.8200   Median :85.00   Median :4.850   Median :180.0   Mode  :character  
  # Mean   :0.8594   Mean   :89.29   Mean   :4.719   Mean   :176.1                     
  # 3rd Qu.:0.9300   3rd Qu.:96.00   3rd Qu.:5.200   3rd Qu.:199.0                     
  # Max.   :0.9600   Max.   :99.00   Max.   :5.900   Max.   :199.9                     
  # NA's   :41                                                                         

# what's with the missing UEFs?
DT_AHRI[is.na(UEF)]
# a bunch of Rheem models

# keep the others
DT_AHRI <- 
  DT_AHRI[!is.na(UEF)]

# convert RE to fraction
DT_AHRI[, RE := RE/100]

# count of records for each set of models
DT_AHRI_mdlcount <-
  DT_AHRI[ , list(nAHRIrefnum = .N),
           by=c("MaxGPM","UEF","RE", "Input.rated", "bin")][order(-MaxGPM, -UEF)]

# add a mdlnum
DT_AHRI_mdlcount[, mdlnum := .I]

# look at some plots
# https://www.r-bloggers.com/plot-matrix-with-the-r-package-ggally/
ggpairs(data = DT_AHRI_mdlcount, 
        columns = 1:4, # columns to plot, default to all.
        axisLabels = "internal",
        mapping=ggplot2::aes(colour = bin),
        title = "AHRI directory tankless models",
        lower = list(continuous = "smooth")
        )

# get date to include in file name
d <- format(Sys.time(), "%F")

# save chart
ggsave(filename = paste0("charts/","AHRI_dir_THW_models_",d,".png"))

# fit RE as linear function of UEF
fit <- lm( RE ~ UEF, DT_AHRI_mdlcount)

summary(fit)
# Call:
#   lm(formula = RE ~ UEF, data = DT_AHRI_mdlcount)
# 
# Residuals:
#       Min        1Q    Median        3Q       Max 
# -0.030981 -0.002279 -0.000069  0.007720  0.021878 
# 
# Coefficients:
#             Estimate Std. Error t value Pr(>|t|)    
# (Intercept) -0.03095    0.02174  -1.423     0.16    
# UEF          1.06491    0.02505  42.513   <2e-16 ***
#   ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Residual standard error: 0.01126 on 55 degrees of freedom
# Multiple R-squared:  0.9705,	Adjusted R-squared:  0.9699 
# F-statistic:  1807 on 1 and 55 DF,  p-value: < 2.2e-16

# fit RE as linear function of UEF & MaxGPM
fit <- lm( RE ~ UEF + MaxGPM, DT_AHRI_mdlcount)
summary(fit)
# doesn't look to be any good

# go back to RE ~ UEF
fit <- lm( RE ~ UEF, DT_AHRI_mdlcount)
residuals(fit)

# add to DT_AHRI_mdlcount
DT_AHRI_mdlcount[ , UEF.res := residuals(fit)]

# melt the data to long format
DT_AHRI_long_res <-
  melt(data = DT_AHRI_mdlcount,
       id.vars = c("UEF.res","bin"),
       measure.vars = c("MaxGPM", "UEF", "RE", "Input.rated" ))

# now try plotting it
ggplot(data = DT_AHRI_long_res,
       aes(x=value, y=UEF.res, color = bin)) + 
  geom_point() +
  facet_wrap(facets = "variable",
             scales = "free_x") +
  labs(title = "AHRI directory tankless models", 
       subtitle = "residual to UEF fit") 
  
# save chart
ggsave(filename = paste0("charts/","AHRI_residuals_",d,".png"))


