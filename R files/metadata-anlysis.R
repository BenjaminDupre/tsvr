setwd("/Users/calypso/Dropbox/My Mac (glaroam2-185-117.wireless.gla.ac.uk)/Documents/Research MaxPlank/P1_propioception/R_tsvr_presentation/data")
# Loading csv file 
meta <- read.csv('meta-data.csv',header=T,sep = ',',dec = '.',fill = TRUE, na.strings=c(""," ","NA"), stringsAsFactors=FALSE) # this is the file sheet as from the drive.
meta <- meta[-23,c(-7,-10,-11)]
meta$post <- as.integer(meta$post) # correcting post consider as chr

##### GENERAL SAMPLE DESCRIPTIVE STATISTICS. 
summary(meta)
sd(meta$AGE)
library(ggpubr)
ggqqplot(meta$AGE)

###### Mean values for the pos-pre. 
mean(meta$post, na.rm=T)
mean(meta$pre, na.rm=T)

# histogram to see distribution difference visually (not too good need to do a better one)
b <- min(c(meta$pre,meta$post),na.rm = T) -1# Set the minimum for the breakpoints
e <- max(c(meta$pre,meta$post),na.rm = T) # Set the maximum for the breakpoints
ax <- pretty(b:e, n = 10) # Make a neat vector for the breakpoints
c1 <- rgb(173,216,230,max = 255, alpha = 225, names = "lt.blue")
c2 <- rgb(255,192,203, max = 255, alpha = 150, names = "lt.pink")


a <- hist(meta$pre, breaks = ax, plot = FALSE)
b <- hist(meta$post, breaks = ax, plot = FALSE)

plot(a, col = c1)
plot(b, col = c2, add = TRUE)

# runnign anova t test difference 
a<- aov(meta[,8]  ~ meta[,7])
summary(a)  

