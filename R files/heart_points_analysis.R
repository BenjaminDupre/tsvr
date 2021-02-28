# Monday 22 February 2021
# Coding for getting insight into heart behavior. 
# Author: B.D.
library(ez) # for anovas
library(plyr) # for building the rt graph and revalue function.

setwd("/Users/calypso/Dropbox/My Mac (glaroam2-185-117.wireless.gla.ac.uk)/Documents/MATLAB/projects/untitled/R files")
tsvr <- read.table('responsetime1.csv',header=T,sep = ',',dec = '.') # this is the file saved from the Matlab file 
# Removing specific participants &  wrongly assigned data, 
tsvr <- tsvr[!(tsvr$ptcp== 2 |tsvr$ptcp== 3 | tsvr$ptcp == 13 | tsvr$ptcp == 11),]
tsvr <- tsvr[!(tsvr$zyklus== "0"),]
# Arranging factors so to have base conditions in order
tsvr$stimulus <- factor(tsvr$stimulus, levels = c(3, 2, 1))
tsvr$stimulus <-revalue(tsvr$stimulus, c("3"="base", "2"="Incongruent", "1"="Congruent"))

tsvr$zyklus <-droplevels(tsvr$zyklus)
tsvr$zyklus = factor(tsvr$zyklus,levels(tsvr$zyklus)[c(2, 1, 3)])
#tsvr$ptcp <- factor(tsvr$ptcp)



aggregate(tsvr[, 5], list(tsvr$zyklus), mean)
aggregate(tsvr[, 8], list(tsvr$zyklus), mean)
# anova for the zyklus
output_anova = ezANOVA(data = tsvr,
                       dv = .(diff),
                       wid = .(ptcp),
                       within  = .(zyklus),
                       within_covariates = .(set),
                       #diff = .(stimulus),
                       detailed = T)

print(output_anova)

# ANOVA for the stimulus.
output_anova = ezANOVA(data = tsvr,
                       dv = .(diff),
                       wid = .(ptcp),
                       within  = .(stimulus),
                       within_covariates = .(set),
                       #diff = .(stimulus),
                       detailed = T)
print(output_anova)


# Visual for the zyklus. 


