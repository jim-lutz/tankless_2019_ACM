# CEC_basic_models.R
# script to get basic models from the tankless WHs in the CEC directory
# where basic models are defined by UEF, RE & MaxGPM

# set packages & etc
source("setup.R")

# CEC
load(file = "data/DT_tankless_CEC.Rdata")

# column specifications
str(DT_tankless)
names(DT_tankless)

# remove NA only columns
DT_tankless[ , names(which(unlist(lapply(DT_tankless, function(x)all(is.na(x)))))) := NULL]  
# got rid of only Qan

# rename columns to work with
setnames(DT_tankless, 
         old = c( "Input BTUH"),
         new = c("Input.rated")
         )

# review UEF, RE & MaxGPM data
summary(DT_tankless[, list(UEF,RE,MaxGPM,Input.rated)])
#      UEF             RE             MaxGPM       Input.rated    
# Min.   :0.81   Min.   : 80.00   Min.   :2.500   Min.   :103200  
# 1st Qu.:0.82   1st Qu.: 84.00   1st Qu.:4.500   1st Qu.:160000  
# Median :0.93   Median : 96.00   Median :4.900   Median :180000  
# Mean   :0.89   Mean   : 91.71   Mean   :4.826   Mean   :176157  
# 3rd Qu.:0.94   3rd Qu.: 96.00   3rd Qu.:5.400   3rd Qu.:199000  
# Max.   :0.97   Max.   :100.00   Max.   :6.000   Max.   :199900  

# convert RE to fraction
DT_tankless[, RE := RE/100]

# count of records for each set of models
DT_CEC_mdlcount <-
  DT_tankless[ , list(nCECrefnum = .N),
               by=c("MaxGPM","UEF","RE", "Input.rated")
               ][order(-MaxGPM, -UEF)]

# add an index, mdlnum
DT_CEC_mdlcount[, mdlnum := .I]

DT_CEC_mdlcount[][order(-nCECrefnum)]

# look at some plots
# https://www.r-bloggers.com/plot-matrix-with-the-r-package-ggally/
ggpairs(data = DT_CEC_mdlcount, 
        columns = 1:4, # columns to plot, default to all.
        axisLabels = "internal",
        title = "CEC directory tankless models",
        lower = list(continuous = "smooth")
        )

# get date to include in file name
d <- format(Sys.time(), "%F")

# save chart
ggsave(filename = paste0("charts/","CEC_dir_THW_models_",d,".png"))

# fit RE as linear function of UEF
fit <- lm( RE ~ UEF, DT_CEC_mdlcount)

summary(fit)
# Call:
#   lm(formula = RE ~ UEF, data = DT_CEC_mdlcount)
# 
# Residuals:
#   Min        1Q    Median        3Q       Max 
# -0.033786 -0.004958 -0.001979  0.007276  0.048021 
# 
# Coefficients:
#   Estimate Std. Error t value Pr(>|t|)    
# (Intercept) -0.03654    0.01847  -1.978   0.0503 .  
# UEF          1.07448    0.02077  51.734   <2e-16 ***
#   ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Residual standard error: 0.01259 on 115 degrees of freedom
# Multiple R-squared:  0.9588,	Adjusted R-squared:  0.9584 
# F-statistic:  2676 on 1 and 115 DF,  p-value: < 2.2e-16

# fit RE as linear function of UEF & MaxGPM
fit <- lm( RE ~ UEF + MaxGPM, DT_CEC_mdlcount)
summary(fit)
# doesn't look to be any better

# go back to RE ~ UEF
fit <- lm( RE ~ UEF, DT_CEC_mdlcount)
residuals(fit)

# add to DT_CEC_mdlcount
DT_CEC_mdlcount[ , RE.res := residuals(fit)]

# melt the data to long format
DT_CEC_long_res <-
  melt(data = DT_CEC_mdlcount,
       id.vars = c("RE.res"),
       measure.vars = c("MaxGPM", "UEF", "RE", "Input.rated" ))

# now try plotting it
ggplot(data = DT_CEC_long_res,
       aes(x=value, y=RE.res)) + 
  geom_point() +
  facet_wrap(facets = "variable",
             scales = "free_x") +
  labs(title = "CEC directory tankless models", 
       subtitle = "residual to RE fit") 
  
# save chart
ggsave(filename = paste0("charts/","CEC_residuals_",d,".png"))

# plot of RE vs UEF
ggplot(data = DT_tankless) +
  geom_point(aes(x = UEF, y = RE)) +
  geom_smooth(aes(x = UEF, y = RE), method = "lm")

# examine outlier
DT_tankless[RE > .98 & UEF < .95]

DT_tankless[Brand == "Bosch"]

# plot of RE vs UEF
ggplot(data = DT_tankless[Brand == "Bosch"]) +
  geom_point(aes(x = UEF, y = RE)) +
  geom_smooth(aes(x = UEF, y = RE), method = "lm")


