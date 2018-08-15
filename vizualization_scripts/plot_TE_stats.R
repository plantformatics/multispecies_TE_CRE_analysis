###################
## Plot TE stats ##
###################

## clean env, set WD and load libraries
rm(list=ls())
setwd("~/Desktop/sapelo2/reference_genomes/Athaliana/")
library(scales)
library(MASS)
library(RColorBrewer)
source("~/Desktop/sapelo2/CustomScripts/vioplot.R")

par(mar=c(3,3,2,3), oma=c(3,3,1,1), bty="n")
layout(matrix(c(1:6), ncol=2, byrow=T))

## read data
a <- read.table("At.ACR_TEmapped.bed.cov")
b <- read.table("At.ACR_TEstats.txt")
c <- read.table("At.cnt_teACR.distTE.bed")
c$V22 <- c$V21/1000
c$V21 <- abs(c$V21)
a$V14 <- factor(a$V14, levels=b$V2, ordered=TRUE)

## color palette
dnacols <- colorRampPalette(c("grey75","darkorchid4"))(11)
ltrcols <- colorRampPalette(c("darkorange","darkred"))(4)


## plot ACR strength by TE family
a$V15 <- as.character(a$V15)
a$cols <- ifelse(a$V15=="DNA", "darkorchid", 
                 ifelse(a$V15=="LTR", "forestgreen","darkorange"))
boxplot(a$V5~a$V15, col=c(dnacols,"dodgerblue",ltrcols,
                          "forestgreen","gold2","darkblue"), 
        las=2, boxwex=0.5, outline=F, notch=F)


## plot pie chart with different TE classes
par(mar=c(0,0,0,0), oma=c(3,3,1,1), bty="n")
dnacols <- colorRampPalette(c("grey75","darkorchid4"))(11)
ltrcols <- colorRampPalette(c("darkorange","darkred"))(4)
b$V3 <- b$V3/sum(b$V3)
pie(b$V3,labels=b$V2,
    col=c(dnacols,"dodgerblue",ltrcols,
          "forestgreen","gold2","darkblue"),
    border="white")


dna <- subset(b, b$V1=='DNA')
LTR <- subset(b, b$V1=='LTR')
types <- aggregate(b$V3~b$V1, FUN=sum)
colnames(types) <- c("class","count")
types$count <- types$count/sum(types$count)

dnacols <- colorRampPalette(c("grey75","darkorchid"))(11)
ltrcols <- colorRampPalette(c("darkorange","darkred"))(4)


## test for association between distance and ACR strength
#model <- lm(c$V5~c$V21)
teACR <- subset(c, c$V21<10)
nonteACR <- subset(c, c$V21>=10)
test <- wilcox.test(nonteACR$V5,c$V5)

## plot vioplots using source vioplot.R
par(mar=c(3,3,2,3), oma=c(3,3,1,1), bty="n")
vioplot(teACR$V5,nonteACR$V5,c$V5, 
        names=c("teACRs","non-teACRs","all ACRs"), 
        range=c(0.5,0.5,0.5),
        col=c("grey75","forestgreen","darkorchid"))
abline(h=median(c$V5), col="grey75",lty=3)

# plot parameters
cols <- colorRampPalette(
        c("white","darkslateblue", "magenta", 
          "red", "yellow", "white"), 
        bias=2, space="Lab")


## plot 2D density plot (ACR strength ~ distance to TE)
k <- kde2d(c$V22, c$V5, n=200, lims=c(-40,40,0,355))
image(k, col=cols(256), yaxt="none")#, #xlim=c(-50,50))

# axis parameters
minx <- round(min(c$V21), -1)
maxx <- round(max(c$V21), -1)
rangex <- as.integer((maxx-minx)/4)
miny <- round(min(c$V5),-1)
maxy <- round(max(c$V5),-1)
rangey <- (maxy-miny)/4
axis(2, at=seq(miny,maxy, by=rangey), las=1)
title(xlab="Distance to TE (kb)", 
      ylab="ACR strength (Normalized kernel density)",
      main="A.thaliana ACR distance to TE")

## load simulated data
s <- read.table("allTEstats.txt")
s$V2 <- as.character(s$V2)
s$prop <- s$V4/s$V6
s$cols <- ifelse(s$V2=="DNA", "darkorchid", 
                ifelse(s$V2=='LTR', "forestgreen","darkorange"))
s$V3 <- factor(s$V3, levels=b$V2, ordered=TRUE)
boxplot(s$prop~s$V3, outline=F, las=2, 
        col=s$cols, border=s$cols, 
        boxwex=0.5, notch=F, ylab="Proportion of teACRs")

## make new DF and plot family enrichment over background
b <- read.table("At.ACR_TEstats.txt")
b$prop <- b$V3/b$V5
meds <- c()
vals <- c()
stren <- c()
tes <- as.character(b$V2)
for (i in 1:nrow(b)){
        aa <- subset(a, a$V14==tes[i])
        ss <- subset(s, s$V3==tes[i])
        st <- median(aa$V5)
        f1 <- median(ss$V4)
        f2 <- median(ss$V6)
        r1 <- b[i,3]
        r2 <- b[i,5]
        test <- fisher.test(matrix(c(f1,f2,r1,r2),byrow=F,
                                   ncol=2))
        vals <- c(vals, test$p.value)
        med <- median(ss$prop)
        meds <- c(meds,med)
        stren <- c(stren, st)
}
vals <- p.adjust(vals, method="fdr")
tes2 <- as.character(b$V1)
b$sim_median <- meds
b$sim_pvals <- -log10(vals)
b$strength <- stren
b$fold <- log2(b$V7/b$sim_median)
b$radius <- sqrt(b$V7 / pi)
b$cols <- ifelse(tes2=="DNA", "darkorchid", 
                 ifelse(tes2=='LTR', "forestgreen","darkorange"))

symbols(b$sim_pvals,b$fold,circles=b$radius, inches=0.2, bg=b$cols,
        fg="white", xlab="-log10(P-value)",
        ylab="Log2(Enrichment/Background)")
abline(v=0, lty=2, col="grey")
abline(h=-log10(0.0001), lty=2, col="grey")
p <- b[order(-b$sim_pvals),]
p <- head(p, n=9)
text(p$sim_pvals+10, p$fold, p$V2, cex=0.75)
