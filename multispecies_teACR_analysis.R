##------------------------##
## analyze all teACR data ##
##------------------------##

## clean env
rm(list=ls())

## set wd
setwd("~/Desktop/sapelo2/reference_genomes/data_analysis/")

## load libraries

## load data
spe <- c("At","Sp","Pt","Gm","Pv","Os","Sv","Sb","Zm")

## loop over files, save data in list
dat <- list()
for (i in 1:length(spe)){
       n1 <- paste(spe[i],".allTEstats.txt",sep="")
       n2 <- paste(spe[i],".ACR_TEstats.txt",sep="")
       n3 <- paste(spe[i],".ACR_TEmapped.bed.GF.cov",sep="")
       n4 <- paste(spe[i],".annotated.ACR.distTE.bed",sep="")
       dats <- list()
       dats[[1]] <- read.table(n1)
       dats[[2]] <- read.table(n2)
       dats[[3]] <- read.table(n3)
       dats[[4]] <- read.table(n4)
       dat[[i]] <- dats
}

## look at Arabidopsis files
head(dat[[1]][[1]])     # allTEstats
head(dat[[1]][[2]])     # ACR_TEstats
head(dat[[1]][[3]])     # TEmapped.bed.GF.cov
head(dat[[1]][[4]])     # dist ACR to TE

##----------------##
## begin plotting ##
##----------------##

## simulations against TE overlap
sims <- list()
for (i in 1:length(spe)){
        sp <- dat[[i]][[1]] #species simulation
        dat[[i]][[4]]$id <- paste(dat[[i]][[4]]$V1,dat[[i]][[4]]$V2,
                                  dat[[i]][[4]]$V3,sep="_")
        acrsnum <- length(unique(dat[[i]][[4]])$id)
        sp$prop <- sp$V7/acrsnum
        sp$V2 <- as.character(sp$V2)
        perms <- unique(as.character(sp$V1))
        its <- c()
        for (j in 1:length(perms)){
                runj <- subset(sp, sp$V1==perms[j]) #individual simulation (1.TE)
                its <- c(its, runj$prop)
        }
        sims[[i]] <- its
}

