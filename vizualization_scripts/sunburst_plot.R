rm(list=ls())
setwd("~/Desktop/sapelo2/reference_genomes/Athaliana")

## load libraries
library(scales)
library(sunburstR)
library(plyr)

## load data
a <- read.table("At.ACR_TEmapped.bed.GF.cov")

## format for sunburstR
b <- a[,c(7,16)]
colnames(b) <- c("genomic_feature","class")
df <- count(b)
df$id <- paste(df$class,df$genomic_feature,sep="-")
df1 <-df[,c(4,3)]
write.table(df1, file="df.txt",sep=",",row.names=F,col.names=F,quote=F)

sequences <- read.csv(
  "df.txt",
  header = FALSE
  ,stringsAsFactors = FALSE
)

labels <- unique(c(as.character(b$genomic_feature),as.character(b$class)))
cols <- c("darkorange","darkorchid","lightgrey","dodgerblue","darkslateblue",
          "forestgreen","gold","skyblue","cornsilk","red")

## plot
sunburst(data=sequences, count=T, colors=list(range=cols, domain=labels))
