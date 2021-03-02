# Monday 22 February 2021
# Coding for getting insight into heart behavior. 
# Author: B.D.
library(ez) # for anovas
library(plyr) # for building the rt graph and revalue function.
library(ggplot2)
library(tidyverse)
#library(gapminder) # sacar si no uso
#library("viridis")           
normalize <- function(x) {
  return ((x - min(x)) / (max(x) - min(x)))
}
setwd("/Users/calypso/Dropbox/My Mac (glaroam2-185-117.wireless.gla.ac.uk)/Documents/MATLAB/projects/untitled/R files")
tsvr <- read.table('responsetime1.csv',header=T,sep = ',',dec = '.') # this is the file saved from the Matlab file 
# Removing specific participants &  wrongly assigned data, 
tsvr <- tsvr[!(tsvr$ptcp== 2   | tsvr$ptcp== 3 | tsvr$ptcp == 13 | tsvr$ptcp == 11),]
tsvr <- tsvr[!(tsvr$zyklus== "0"),]
#tsvr <- tsvr[!(tsvr$zyklus== "0" | tsvr$zyklus == "keine vibration"),]
# Arranging factors so to have base conditions in order
tsvr$stimulus <- factor(tsvr$stimulus, levels = c(3, 2, 1))
tsvr$stimulus <-revalue(tsvr$stimulus, c("3"="base", "2"="Incongruent", "1"="Congruent"))

tsvr$zyklus = factor(tsvr$zyklus,levels(tsvr$zyklus)[c(1, 3, 2, 4)])
tsvr$zyklus <- droplevels(tsvr$zyklus)

#tsvr$ptcp <- factor(tsvr$ptcp)

# Normalizing response time for every participant
for (i in min(tsvr$ptcp):max(tsvr$ptcp)){
  tsvr[tsvr$ptcp==i,5]=normalize(tsvr[tsvr$ptcp==i,5])
}





aggregate(tsvr[, 5], list(tsvr$zyklus), mean)
aggregate(tsvr[, 8], list(tsvr$zyklus), mean)

# ANOVA for the zyklus
output_anova = ezANOVA(data = tsvr,
                       dv = .(diff),
                       wid = .(ptcp),
                       within  = .(zyklus),
                       #within_covariates = stimulus,
                       #diff = .(stimulus),
                       detailed = T)

print(output_anova)

# ANOVA for the stimulus.
output_anova2 = ezANOVA(data = tsvr,
                       dv = .(diff),
                       wid = .(ptcp),
                       within  = .(stimulus),
                       #within_covariates = .(set,lvl),
                       #diff = .(stimulus),
                       detailed = T)
print(output_anova2)

# Visual for the Zyklus. 
sd = sd(df$diff)


df = tsvr %>%
  #filter(ptcp != 22) %>%
  #filter(zyklus %in% c("Diastole","Systole")) %>%
  group_by(ptcp,zyklus) %>%
  summarise(n_diff = mean(diff))
  #summarise(n_diff = mean(diff))

df %>%
  ggplot(aes(zyklus,n_diff, fill=zyklus)) +
  geom_boxplot() +
  scale_fill_brewer()+
  geom_line(aes(group=ptcp, col=ptcp)) +#, position = position_dodge(0.2)) +
  geom_point(aes(group=ptcp, col=ptcp)) +#, position = position_dodge(0.2)) +
  scale_color_viridis(option = "D")+
  theme(legend.position="none" )



normalize(tsvr$diff)
normalize(tsvr$diff)

plot(normalize(tsvr$diff))