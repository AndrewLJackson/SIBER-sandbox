#-----------------------------------------------------------------------------
# Set up
#-----------------------------------------------------------------------------
rm(list=ls())

#-----------------------------------------------------------------------------
# Simulate some data
#-----------------------------------------------------------------------------

n.groups <- 10
n <- 10 # samples per group

V <- matrix(0, nrow = n.groups, ncol = 2)

for (i in 1:n.groups){
  b0 <- runif(2, -5, 5)
  V[i,] <- rmvnorm(1, mean = b0, sigma = matrix(c(1,-0.3,-0.3,1), nrow = 2, ncol = 2))
}

s <- rmvnorm(n * n.groups, mean = c(0,0), sigma = matrix(c(1,0,0,1), nrow = 2, ncol = 2))

Y <- matrix(0, nrow = n * n.groups, ncol = 2)

G <- sort(rep(1:n.groups, n))

for (i in 1:(n * n.groups)){
  Y[i,] <- V[G[i]] + s[i,]
}




# ----------------------------------------------------------------------------
# JAGS code for fitting Inverse Wishart version of SIBER to a single group
# ----------------------------------------------------------------------------

modelstring <- '

model {
  # ----------------------------------
  # define the priors
  # ----------------------------------
  

  # Define the group level random effect
  for (j in 1:n.groups) {

    # covariance of the group level random effect
    tau.group[1:2, 1:2, j] ~ dwish(R.group[1:n.iso,1:n.iso],k.group)
    Sigma2.group[1:2, 1:2, j] <- inverse(tau.group[1:2,1:2,j])
    
    # mean of the group level random effect
    b0.group[j,1] ~ dnorm(0, tau.mu)
    b0.group[j,2] ~ dnorm(0, tau.mu)

    # the group-level random deviate
    V[j,1:2] ~ dmnorm(c(0,0), tau.group[,,j])
  }

  # prior for the precision matrix
  tau[1:n.iso,1:n.iso] ~ dwish(R[1:n.iso, 1:n.iso], k)
  
  # convert to covariance matrix
  Sigma2[1:n.iso, 1:n.iso] <- inverse(tau[1:n.iso, 1:n.iso]) 
  
  #----------------------------------------------------
  # specify the likelihood of the observed data
  #----------------------------------------------------
  
  for(i in 1:n.obs) {
    mu[i,1:2] <- b0.group[G[i],] + V[G[i],1:2] 
    Y[i,1:2] ~ dmnorm(mu[i, 1:n.iso], tau[1:n.iso,1:n.iso])
  }

  
  
  
}' # end of jags model script


# ----------------------------------------------------------------------------
# Prepare objects for passing to jags
# ----------------------------------------------------------------------------

# options for running jags
parms <- list()
parms$n.iter <- 2 * 10^4   # number of iterations to run the model for
parms$n.burnin <- 1 * 10^3 # discard the first set of values
parms$n.thin <- 10     # thin the posterior by this many
parms$n.chains <- 2        # run this many chains

# define the priors
priors <- list()
priors$R <- 1 * diag(2)
priors$k <- 2
priors$tau.mu <- 1.0E-3
priors$R.group <- 1 * diag(2)
priors$k.group <- 2

n.obs <- nrow(Y)
n.iso <- ncol(Y)

jags.data <- list("Y"= Y, "G" = G, "n.groups" = n.groups, 
                  "n.obs" = n.obs, "n.iso" = n.iso,
                  "R"= priors$R, "k" = priors$k, "tau.mu" = priors$tau.mu,
                  "R.group" = priors$R.group, "k.group" = priors$k.group)

inits <- list(
  list(mu = stats::rnorm(2,0,1)),
  list(mu = stats::rnorm(2,0,1))
)


# monitor all the parameters
parameters <- c("mu","Sigma2", "Sigma2.group")

model <- rjags::jags.model(textConnection(modelstring),
                           data = jags.data, n.chains = 2)

output <- rjags::coda.samples(model = model,
                              variable.names = c("b0.group",'Sigma2', "Sigma2.group"),
                              n.iter = parms$n.iter,
                              thin = 10)

