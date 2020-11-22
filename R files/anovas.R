########## Loading Domains
library(ez) # for anovas
library(ggplot2) # in every graph
library(plyr) # for building the rt graph
library(lme4) # to test difference in accuracy
library(lmerTest) # to test Now approx p-val w/Kenward-Roger’s approximations
library(gridExtra) # its used to mixed the two graphics together. 
########## Defining Working Folder
setwd('/Users/calypso/Dropbox/My Mac (glaroam2-185-117.wireless.gla.ac.uk)/Documents/Research MaxPlank/P1_propioception/R_tsvr_presentation/data/')
##########Loading File
 tsvr <- read.table('responsetime.csv',header=T,sep = ',',dec = '.') # this is the file saved from the matlab file 

########## Running ANOVA for RT
tsvr$stimulus <- factor(tsvr$stimulus, levels = c(3, 2, 1))
tsvr$stimulus <-revalue(tsvr$stimulus, c("3"="base", "2"="Incongruent", "1"="Congruent"))
tsvr$ptcp <- factor(tsvr$ptcp)
# tsvr$lvl <- factor(tsvr$lvl)
# tsvr$set <- factor(tsvr$set)

output_anova = ezANOVA(data = tsvr,
        dv = diff,
        wid = ptcp,
        within = .(stimulus),
        within_covariates = set,
        detailed = T)

print(output_anova)
########## Graphic for RT
data_summary <- function(data, varname, grps){
  require(plyr)
  summary_func <- function(x, col){
    c(mean = mean(x[[col]], na.rm=TRUE),
      sd = sd(x[[col]], na.rm=TRUE))
  }
  data_sum<-ddply(data, grps, .fun=summary_func, varname)
  data_sum <- rename(data_sum, c("mean" = varname))
  return(data_sum)
}
df <- data_summary(tsvr, varname="diff", grps = "stimulus")
rt <- ggplot(df, aes(x = stimulus, y = diff,
                     ymin=diff-0.05*sd, ymax=diff+0.05*sd))
rt <- rt + geom_pointrange() +
  labs(title ="Response Time per Condition", x = "visual-heptic", y = "(in seconds)")+
  theme(panel.grid.minor = element_line(size = 0.25, linetype = 'solid', colour = "grey") ,
        panel.grid.minor.x = element_blank())
  
########## ANOVA for ACCURACY
fm1<- lmer(accuracy ~ stimulus + (1| ptcp) , data= tsvr)
summary(fm1)
anova(fm1, ddf = "Kenward-Roger") 
########## Graphic for ACC
df2 <- data_summary(tsvr, varname="accuracy", grps = "stimulus")
incc <- ggplot(df2, aes(x = stimulus, y = accuracy,
                     ymin=accuracy-0.05*sd, ymax=accuracy+0.05*sd))
incc <- incc + geom_pointrange() +
  labs(title ="Innacuracy per Condition", x = "Visual - Heptic Stimuli ", y = "Proportion of mistakes") +
  theme(panel.grid.minor = element_line(size = 0.25, linetype = 'solid', colour = "grey") ,
          panel.grid.minor.x = element_blank())
########## Two together
grid.arrange(rt, incc, ncol = 1)

########## Running for inter-beat-interval
tsvr2 <- read.table('alles_hr/behavioral_a.csv',header=T,sep = ',',dec = '.')
tsvr2 <- tsvr2[!(tsvr2$ptcp== 2 |tsvr2$ptcp== 3 | tsvr2$ptcp == 13 | tsvr2$ptcp == 11),]
tsvr2$stimulus <- factor(tsvr2$stimulus, levels = c(3, 2, 1))
tsvr2$stimulus <-revalue(tsvr2$stimulus, c("3"="base", "2"="Incongruent", "1"="Congruent"))
#tsvr2<- na.omit(tsvr2)
#$stimulus <- factor(tsvr$stimulus, levels = c(3, 2, 1))
#tsv2r$stimulus <-revalue(tsvr$stimulus, c("3"="base", "2"="Incongruent", "1"="Congruent"))
output_anova = ezANOVA(data = tsvr2,
                       dv = IBI,
                       wid = ptcp,
                       within = .(stimulus),
                       within_covariates = set,
                       detailed = T)
print(output_anova)
########## Graphic for IBI
df2 <- data_summary(tsvr2, varname="IBI", grps = "stimulus")
hr <- ggplot(df2, aes(x = stimulus, y = IBI,
                        ymin=IBI-0.05*sd, ymax=IBI+0.05*sd))
hr <- hr + geom_pointrange() +
  labs(title ="IBI per Condition", x = "Visual - Heptic Stimuli ", y = "Fraction of a second (s)") +
  theme(panel.grid.minor = element_line(size = 0.25, linetype = 'solid', colour = "grey") ,
        panel.grid.minor.x = element_blank())
hr