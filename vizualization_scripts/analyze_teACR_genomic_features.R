#################################################
## Analyze teACRs and the genomic distribution ##
#################################################
rm(list=ls())
setwd("~/Desktop/sapelo2/reference_genomes/Athaliana")

## load libraries
library(scales)
library(plyr)

## load data
a <- read.table("At.ACR_TEmapped.bed.GF.cov")
b <- read.table("At.ACR_TEstats.txt")
c <- read.table("allTEstats.txt1")
d <- read.table("At.annotated.ACR.distTE.bed")

## format for plots

