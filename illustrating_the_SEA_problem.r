# this demo generates some random data for M consumers based on N samples and
# constructs a standard ellipse for each based on SEAc and SEA_B

rm(list = ls())

library(siar)

# ------------------------------------------------------------------------------
# ANDREW - REMOVE THESE LINES WHICH SHOULD BE REDUNDANT
# change this line
#setwd("c:/rtemp")
# ------------------------------------------------------------------------------



# now close all currently open windows
graphics.off()


# read in some data
# NB the column names have to be exactly, "group", "x", "y"
mydata <- read.table("adults.txt" , sep="\t",header=T)

# make the column names availble for direct calling
attach(mydata)


# now loop through the data and calculate the ellipses
ngroups <- length(unique(group))



# split the isotope data based on group
spx <- split(x,group)
spy <- split(y,group)

# create some empty vectors for recording our metrics
SEA <- numeric(ngroups)
SEAc <- numeric(ngroups)
TA <- numeric(ngroups)

dev.new()
plot(x,y,col=group,type="p")
legend("topright",legend=as.character(paste("Group ",unique(group))),
        pch=19,col=1:length(unique(group)))

for (j in unique(group)){


  # Fit a standard ellipse to the data
  SE <- standard.ellipse(spx[[j]],spy[[j]],steps=1)
  
  # Extract the estimated SEA and SEAc from this object
  SEA[j] <- SE$SEA
  SEAc[j] <- SE$SEAc
  
  # plot the standard ellipse with d.f. = 2 (i.e. SEAc)
  # These are plotted here as thick solid lines
  lines(SE$xSEAc,SE$ySEAc,col=j,lty=1,lwd=3)
  
  
  # Also, for comparison we can fit and plot the convex hull
  # the convex hull is plotted as dotted thin lines
  #
  # Calculate the convex hull for the jth group's isotope values
  # held in the objects created using split() called spx and spy
  CH <- convexhull(spx[[j]],spy[[j]])
  
  # Extract the area of the convex hull from this object
  TA[j] <- CH$TA
  
  # Plot the convex hull
  lines(CH$xcoords,CH$ycoords,lwd=1,lty=3)

  
}

# print the area metrics to screen for comparison
# NB if you are working with real data rather than simulated then you wont be
# able to calculate the population SEA (pop.SEA)
# If you do this enough times or for enough groups you will easily see the
# bias in SEA as an estimate of pop.SEA as compared to SEAc which is unbiased.
# Both measures are equally variable.
print(cbind(SEA,SEAc,TA))

# So far we have fitted the standard ellipses based on frequentist methods
# and calculated the relevant metrics (SEA and SEAc). Now we turn our attention
# to producing a Bayesian estimate of the standard ellipse and its area SEA_B


reps <- 10^4 # the number of posterior draws to make

# Generate the Bayesian estimates for the SEA for each group using the 
# utility function siber.ellipses
SEA.B <- siber.ellipses(x,y,group,R=reps)

# ------------------------------------------------------------------------------
# Plot out some of the data and results
# ------------------------------------------------------------------------------


# Plot the credible intervals for the estimated ellipse areas now
# stored in the matrix SEA.B
dev.new()
siardensityplot(SEA.B,
  xlab="Group",ylab="Area (permil^2)",
  main="Different estimates of Standard Ellipse Area (SEA)")

# and now overlay the other metrics on teh same plot for comparison
points(1:ngroups,SEAc,pch=15,col="red")
legend("topright",c("SEAc"),pch=c(15,17),col=c("red","blue"))

# There is clearly some concern about the mismatch between the ML and Bayesian
# estimates for Groups 1 and 3 in particular, but in all cases, the Bayesian
# estimates are larger than the ML ones.

# ------------------------------------------------------------------------------
# Do some checks of the distirubtion of data in problematic groups
# ------------------------------------------------------------------------------

dev.new()
par(mfrow=c(2,2))

# Visually, both the x and y data for Group 1 are not entirely satisfactorily
# distributed along the predicted line.
qqnorm(x[group==1],main="Group 1 Isotope X")
qqline(x[group==1],col="red")

qqnorm(y[group==1],main="Group 1 Isotope Y")
qqline(y[group==1],col="red")

# Group 3 has a few "odd" data points, pariculary the point (-18.23, 13.76)
qqnorm(x[group==3],main="Group 3 Isotope X")
qqline(x[group==3],col="red")

qqnorm(y[group==3],main="Group 3 Isotope Y")
qqline(y[group==3],col="red")

library(mvnormtest)

# Grp 1 appears to be pretty MVN distributed
gp1.norm.test <- mshapiro.test(t(as.matrix(mydata[group==1,3:4])))

# Grp 3 not so
# However... i wouldnt put a huge amount of trust into this mshapior test
# as there are geometries that behave well with ellipse fitting, even though
# they are not "normal" and vice versa.
gp3.norm.test <- mshapiro.test(t(as.matrix(mydata[group==3,3:4])))



