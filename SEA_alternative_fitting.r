# this demo generates some random data for M consumers based on N samples and
# constructs a standard ellipse for each based on SEAc and SEA_B

rm(list = ls())

library(siar)
library(R2jags)

# ------------------------------------------------------------------------------
# ANDREW - REMOVE THESE LINES WHICH SHOULD BE REDUNDANT
# change this line
#setwd("c:/rtemp")

source("SEA_fitting.R")
source("BUGS_models.R")

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

# We have a choice about which fitting algorithm to use. 
# Up until now (and into the foreseeable future) SIBER uses the function
# rmultireg from package bayesm to fit the model.
# The new function siber.ellipses.test() allows us now to also use
# JAGS to fit the code which takes slightly different priors.
# In the code below, I fit using both algorithms. They give similar results.
# In a future release of SIBER, I will most likely move to using JAGS as I 
# find it to be more transparent and flexible about the types of models that
# can be fitted. JAGS also gives more easy control over thinning and burnin.


# ------------------------------------------------------------------------------
# Fit rmultireg()
# ------------------------------------------------------------------------------
# fit a model using the existing method (as of 12/09/13) which is
# to use rmultireg()

parms <- list()
parms$n.iter <- 10^4 # number of iterations to run the model for

# NB the rest of these settings are not functional yet under my coding for 
# rmultireg. Hence my preference for JAGS (see below)
parms$n.burnin <- 0
parms$n.thin <- 1
parms$n.chains <- 1

priors <- list()
priors$Bbar <- c(0, 0)
priors$A <- 10^-3
priors$nu <- 2
priors$V <- 1 * diag(2)


# fit the ellipses using the rmultireg() method.
SIBER1 <- siber.ellipses.test(x,y,group,method="rmultireg",parms, priors)

# ------------------------------------------------------------------------------
# Fit JAGS IW prior
# ------------------------------------------------------------------------------
# fit same Inverse Wishart (IW) model using JAGS
parms <- list()
parms$n.iter <- 2 * 10^4   # number of iterations to run the model for
parms$n.burnin <- 1 * 10^4 # discard the first set of values
parms$n.thin <- 10         # thin the posterior by this many
parms$n.chains <- 2        # run this many chains


priors <- list()
priors$R <- 1 * diag(2)
priors$k <- 2
priors$tau.mu <- 1.0E-3

# fit the ellipses using the Inverse Wishart JAGS method.
SIBER2 <- siber.ellipses.test(x,y,group,method="IWJAGS",parms, priors)



# ------------------------------------------------------------------------------
# Plot out some of the data and results
# ------------------------------------------------------------------------------


# Plot the credible intervals for the estimated ellipse areas now
# stored in the matrix SEA.B

dev.new()
siardensityplot(SIBER1$SEA.B,
  xlab="Group",ylab="Area (permil^2)",
  main="Fit using rmultireg",
  ct="mode", ylims=c(0,3))

# and now overlay the other metrics on teh same plot for comparison
points(1:ngroups,SEAc,pch=15,col="red")
legend("topright",c("SEAc"),pch=c(15,17),col=c("red","blue"))

# also overlay the mean of the posterior, which seems to be more closely
# related to the Maximum likelihood estimated SEAc
points(1:ngroups,apply(SIBER1$SEA.B,2,mean),pch=4,col="black")

# ------------------------
dev.new()
siardensityplot(SIBER2$SEA.B,
  xlab="Group",ylab="Area (permil^2)",
  main="Fit using JAGS",
  ct="mode", ylims=c(0,3))
  

# and now overlay the other metrics on teh same plot for comparison
points(1:ngroups,SEAc,pch=15,col="red")
legend("topright",c("SEAc"),pch=c(15,17),col=c("red","blue"))

# also overlay the mean of the posterior, which seems to be more closely
# related to the Maximum likelihood estimated SEAc
points(1:ngroups,apply(SIBER2$SEA.B,2,mean),pch=4,col="black")

# ----------------------------------------------------------------------------

