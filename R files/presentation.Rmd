---
title: "TSVR"
author: "Benjamin Dupre"
date: "11/22/2020"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
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
```

#### 1. File description

The file to analyse includes the number of the participant (ptcp), the 'set' refers to the number of the block, the level ('lvl') is the number assign to the trial presented in each block. 

The varaible 'start' correponds to the moment the ball placed in the hand of the participant and is shown in row number. Likewise, 'end' correponds to the explosion of the board and is also shown in row number. 

The variable 'accuracry' takes value 1 when there is a mistake 0 otherwise.

Finally, 'diff' refers to the time difference between 'start' and 'end' expresed in seconds and 'stimulus' signal wether where the participant felt the vibration on the same hand or if they did not received any vibration.   

```{r tsvr, echo=FALSE}
summary(tsvr)
```

#### 2. Testing time difference between conditions withing subjects (base, congruent, incongruent).

a.- Its important to have in mind that reponse time is not a normally distributed variable, nontheless ANOVA can handle non normality. 
```{r , echo=FALSE, fig.align = "center"}
qqnorm(tsvr$diff, pch = 1, frame = FALSE)
qqline(tsvr$diff, col = "steelblue", lwd = 2)
```

b.- We run an ANOVA to test for the difference (this code is based on Esra )

```{r, echo=TRUE, warning=FALSE}
output_anova = ezANOVA(data = tsvr,
        dv = diff,
        wid = ptcp,
        within = .(stimulus),
        within_covariates = set,
        detailed = T)

print(output_anova)
```

c.- We show the resultsof the graphic portraing the difference.
```{r, echo=FALSE, fig.align = "center"}
df <- data_summary(tsvr, varname="diff", grps = "stimulus")
rt <- ggplot(df, aes(x = stimulus, y = diff,
                     ymin=diff-0.05*sd, ymax=diff+0.05*sd))
rt <- rt + geom_pointrange() +
  labs(title ="Response Time per Condition", x = "visual-heptic", y = "(in seconds)")+
  theme(panel.grid.minor = element_line(size = 0.25, linetype = 'solid', colour = "grey") ,
        panel.grid.minor.x = element_blank())
rt
```

#### 3. Testing for accuracy difference between conditions withing subjects (base, congruent, incongruent).

a.- Because the dependand varaible is binary we run linear mixed effect model using the participants as randome effect varaibles. 
```{r , echo=TRUE, fig.align = "center"}
fm1<- lmer(accuracy ~ stimulus + (1 | ptcp) , data= tsvr)
summary(fm1)
```












