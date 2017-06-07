rm(list=ls())
graphics.off()

set.seed(1)
library(SIBER)

fname = "may-2017/UMI_SIBER_KZ_UZ.csv"
mydata <- read.csv(fname, header=T)
siber.umi <- createSiberObject(mydata)

#The data plot fine
community.hulls.args <- list(col = 1, lty = 1, lwd = 1)
group.ellipses.args  <- list(n = 100, p.interval = 0.95, lty = 1, lwd = 2)
group.hull.args      <- list(lty = 2, col = "grey20")

palette(viridis::viridis(4))

par(mfrow=c(1,1))
plotSiberObject(siber.umi,
                ax.pad = 2, 
                hulls = F, community.hulls.args, 
                ellipses = T, group.ellipses.args,
                group.hulls = F, group.hull.args,
                bty = "L",
                iso.order = c(1,2),
                xlab = expression({delta}^13*C~'\u2030'),
                ylab = expression({delta}^15*N~'\u2030')
                )

# The group metrics calculate fine
group.ML <- groupMetricsML(siber.umi)
print(group.ML)

#Output
# KZ.Arys   KZ.Ili UZ.Ferghana UZ.Zerafshan UZ.Tashkent UZ.Khoresm
# TA   9.755000 6.800150    3.829950     2.541700    2.047300   2.085050
# SEA  5.461812 3.269967    1.459662     1.816222    1.223853   1.229873
# SEAc 6.242070 3.567237    1.571943     2.075682    1.427829   1.405570

# The Layman metrics for the communities break
community.ML <- communityMetricsML(siber.umi)
print(community.ML)

#Output
# KZ        UZ
# dY_range 0.5093162 2.2822222
# dX_range 2.1292308 4.7788889
# TA       0.0000000 5.9499254
# CD       1.0946491 1.9395738
# MNND     2.1892982 2.3811600
# SDNND    0.0000000 0.8075202


# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 
# AJ - plot the hulls for each community to see what's going on

community.hulls.args <- list(col = 1, lty = 1, lwd = 1)
group.ellipses.args  <- list(n = 100, p.interval = 0.95, lty = 1, lwd = 2)
group.hull.args      <- list(lty = 2, col = "grey20")

par(mfrow=c(1,1))
plotSiberObject(siber.umi,
                ax.pad = 2, 
                hulls = T, community.hulls.args, 
                ellipses = F, group.ellipses.args,
                group.hulls = F, group.hull.args,
                bty = "L",
                iso.order = c(1,2),
                xlab = expression({delta}^13*C~'\u2030'),
                ylab = expression({delta}^15*N~'\u2030')
)

# Remember that my interpretation of the Layman metrics is to only apply them 
# to the means of each group for a given community. Your KZ only has two groups
# and so you cant draw a hull between two points. This is why you are getting
# zeros values in that table, and why the numbers reported dont match what you 
# eye-ball from the graph. You can if you want calculate the layman metrics on 
# each group, but you wont be able to derive bayesian estiamtes for the 
# uncertainty around them which is only possible if you draw the hulls between 
# the centroids of each group within a community.

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 

#Zero values are no good!

#When I try to plot the bivariate means, I get:
#Error in eigen(sigma/c.scale) : infinite or missing values in 'x'
plotGroupEllipses(siber.umi, n = 100, p.interval = 0.95, ci.mean = T,
                  lty = 1, lwd = 2)

#I don't know what's going on, since the data looks correctly organized in the csv.
#You'll also notice that the dY_range and dX_range are wrong, based on the plot
#The KZ community should have a greater dX_range than UZ
#It seems wrong that the dY_range of UZ is more than four times greater than that of KZ