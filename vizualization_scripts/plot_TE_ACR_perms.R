rm(list=ls())
setwd("~/Desktop/sapelo2_mnt/reference_genomes/Athaliana/")
library(scales)


ol <- 2328
a <- read.table("At.TE.perm.txt")

# plot parameters
den <- density(a$V1, from=min(a$V1), to=max(a$V1))
par(xaxp = c(min(ol,den$x),max(den$x,ol) , 4),
    yaxp = c(min(den$y),max(den$y), 4))

plot(den, col=alpha("grey75",0.5), 
     xaxt="none",yaxt="none",
     main="A.thaliana ACR transposon overlap",
     xlab="Simulated overlap rate (10,000x)", 
     ylab="",
     xlim=c(min(den$x,ol),max(den$x,ol)))

polygon(den, col=alpha("grey75",0.5), border=NA)

abline(v=ol, col="darkorchid", lwd=3)

minx <- round(min(ol,den$x), -2)
maxx <- round(max(ol,den$x), -2)
rangex <- as.integer((maxx-minx)/4)
miny <- round(min(den$y),3)
maxy <- round(max(den$y),3)
rangey <- (maxy-miny)/4
axis(1, at=seq(minx,maxx, by=rangex))
axis(2, at=seq(miny,maxy, by=rangey), las=1)