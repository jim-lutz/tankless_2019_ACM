# DOE_basic_models.R
# script to get basic models from the DOE tankless WH directory
# where basic models are defined by UEF, RE & MaxGPM
# find relations between variables.

# set packages & etc
source("setup.R")

# load DOE directory
load(file = "data/DT_DOE_dir.Rdata")

# look at the data.table
str(DT_DOE_dir)
names(DT_DOE_dir)
summary(DT_DOE_dir)

# remove NA only columns
DT_DOE_dir[ , names(which(unlist(lapply(DT_DOE_dir, function(x)all(is.na(x)))))) := NULL]  
# no columns to delete or assign RHS to.

# rename columns to work with
setnames(DT_DOE_dir, 
         old = c("draw.pattern"),
         new = c("bin")
         )

# review UEF, RE & MaxGPM data
summary(DT_DOE_dir[, list(UEF,RE,MaxGPM, bin)])
# DOE doesn't list rated input
  #      UEF               RE             MaxGPM          bin           
  # Min.   :0.7900   Min.   : 80.00   Min.   :3.000   Length:650        
  # 1st Qu.:0.8200   1st Qu.: 84.00   1st Qu.:4.500   Class :character  
  # Median :0.9200   Median : 96.00   Median :4.950   Mode  :character  
  # Mean   :0.8885   Mean   : 91.62   Mean   :4.855                     
  # 3rd Qu.:0.9300   3rd Qu.: 96.00   3rd Qu.:5.400                     
  # Max.   :0.9700   Max.   :100.00   Max.   :5.900                     

# convert RE to fraction
DT_DOE_dir[, RE := RE/100]

# count number of records for each set of basic models
DT_DOE_dir_mdlcount <-
  DT_DOE_dir[ , list(nDOErefnum = .N),
           by=c("MaxGPM","UEF","RE",  "bin")][order(-MaxGPM, -UEF)]

# add a mdlnum index
DT_DOE_dir_mdlcount[, mdlnum := .I]

# look at some plots
# https://www.r-bloggers.com/plot-matrix-with-the-r-package-ggally/
ggpairs(data = DT_DOE_dir_mdlcount, 
        columns = 1:3, # number of columns to plot
        axisLabels = "internal",
        mapping=ggplot2::aes(colour = bin),
        title = "DOE directory tankless models",
        lower = list(continuous = "smooth")
        )

# check out plot of RE vs UEF
ggplot(data=DT_DOE_dir_mdlcount,
       aes(x=UEF, y=RE)) +
  geom_point() +
  geom_smooth(method = lm)

# fit RE as linear function of UEF
fit <- lm( RE ~ UEF, DT_DOE_dir_mdlcount)

summary(fit)
# Call:
#   lm(formula = RE ~ UEF, data = DT_DOE_dir_mdlcount)
# 
# Residuals:
#   Min        1Q    Median        3Q       Max 
# -0.032776 -0.004969 -0.001429  0.007784  0.048571 
# 
# Coefficients:
#   Estimate Std. Error t value Pr(>|t|)    
# (Intercept) -0.04094    0.01943  -2.108   0.0375 *  
#   UEF          1.07866    0.02182  49.430   <2e-16 ***
#   ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Residual standard error: 0.0129 on 101 degrees of freedom
# Multiple R-squared:  0.9603,	Adjusted R-squared:  0.9599 
# F-statistic:  2443 on 1 and 101 DF,  p-value: < 2.2e-16

str(fit)
fit["coefficients"]

# manual fit of RE = UEF + 0.04
DT_DOE_dir_mdlcount[, RE.man := UEF + 0.04]
DT_DOE_dir_mdlcount[, RE.res.man := RE - RE.man]

# look at the distribution of RE.res.man
# check out plot of RE vs UEF
ggplot(data=DT_DOE_dir_mdlcount, aes(x=RE.res.man)) +
  geom_histogram()
# why a blank chart?

qplot(DT_DOE_dir_mdlcount[,RE.res.man])

# difference between RE & UEF
DT_DOE_dir_mdlcount[, RE.diff := RE - UEF]

# plot the histogram with a normal approximation
ggplot(DT_DOE_dir_mdlcount, aes(x=RE.diff)) + 
  geom_histogram() +
  stat_function(fun = dnorm, 
                args = list(
                  mean = mean(DT_DOE_dir_mdlcount$RE.diff), 
                  sd = sd(DT_DOE_dir_mdlcount$RE.diff)
                  )
                )

# mean & sd of RE.diff
mean(DT_DOE_dir_mdlcount$RE.diff)
# [1] 0.02893204
sd(DT_DOE_dir_mdlcount$RE.diff)
# [1] 0.01364196

# check out plot of RE vs UEF
ggplot(data=DT_DOE_dir_mdlcount,
       aes(x=UEF, y=RE)) +
  geom_point() +
  geom_smooth(method = lm) +
  geom_abline(slope = 1.0, intercept = mean(DT_DOE_dir_mdlcount$RE.diff) ) +
  geom_text(x = .9, y = .875,
            label= paste("sd =", sd(DT_DOE_dir_mdlcount$RE.diff)))








summary(DT_DOE_dir_mdlcount[,RE.res.man])
DT_DOE_dir_mdlcount[, list(RE.res.man)]

# # get date to include in file name
# d <- format(Sys.time(), "%F")
# 
# # save chart
# ggsave(filename = paste0("charts/","DOE_dir_THW_models_",d,".png"))

# fit RE as linear function of UEF & MaxGPM
fit <- lm( RE ~ UEF + MaxGPM, DT_DOE_dir_mdlcount)
summary(fit)
# no real improvement

# go back to RE ~ UEF
fit <- lm( RE ~ UEF, DT_DOE_dir_mdlcount)
summary(fit)
residuals(fit)

# add to DT_DOE_dir_mdlcount
DT_DOE_dir_mdlcount[ , RE.res := residuals(fit)]

# melt the data to long format
DT_DOE_dir_long_res <-
  melt(data = DT_DOE_dir_mdlcount,
       id.vars = c("RE.res","bin"),
       measure.vars = c("MaxGPM", "UEF", "RE"))

names(DT_DOE_dir_long_res)

# now try plotting it
ggplot(data = DT_DOE_dir_long_res,
       aes(x=value, y=RE.res, color = bin)) + 
  geom_point() +
  facet_wrap(facets = "variable",
             scales = "free_x") +
  labs(title = "DOE directory tankless models", 
       subtitle = "residual to UEF fit") 
  
# save chart
ggsave(filename = paste0("charts/","DOE_residuals_",d,".png"))

# try w/ squared term as well
# go back to RE ~ UEF
fit <- lm( RE ~ UEF + I(UEF*UEF) , DT_DOE_dir_mdlcount)
summary(fit)
residuals(fit)

# add to DT_DOE_dir_mdlcount
DT_DOE_dir_mdlcount[ , UEF2.res := residuals(fit)]

# melt the data to long format
DT_DOE_dir_long_res <-
  melt(data = DT_DOE_dir_mdlcount,
       id.vars = c("UEF2.res","bin"),
       measure.vars = c("MaxGPM", "UEF", "RE"))

# now try plotting it
ggplot(data = DT_DOE_dir_long_res,
       aes(x=value, y=UEF2.res, color = bin)) + 
  geom_point() +
  facet_wrap(facets = "variable",
             scales = "free_x") +
  labs(title = "DOE directory tankless models", 
       subtitle = "residual to UEF + UEF^2 fit") 




