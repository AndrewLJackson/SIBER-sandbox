rm(list=ls())
graphics.off()

set.seed(1)
library(SIBER)

fname = "~/Dropbox/Kiel/Data/UZ Medieval Isotope/UMI_SIBER_KZ_UZ.csv"
mydata <- read.csv(fname, header=T)
siber.umi <- createSiberObject(mydata)

plotSiberObject(siber.umi,
                ax.pad = 2, 
                hulls = F, community.hulls.args, 
                ellipses = F, group.ellipses.args,
                group.hulls = F, group.hull.args,
                bty = "L",
                iso.order = c(1,2),
                xlab=expression({delta}^13*C~'\u2030'),
                ylab=expression({delta}^15*N~'\u2030'),
                cex = 0.5
)

#Bayesian ellipse overlap
# options for running jags
parms <- list()
parms$n.iter <- 2 * 10^6   # number of iterations to run the model for
parms$n.burnin <- 1 * 10^4 # discard the first set of values
parms$n.thin <- 100     # thin the posterior by this many
parms$n.chains <- 2        # run this many chains

# define the priors
priors <- list()
priors$R <- 1 * diag(2)
priors$k <- 2
priors$tau.mu <- 1.0E-3

# fit the ellipses which uses an Inverse Wishart prior
# on the covariance matrix Sigma, and a vague normal prior on the 
# means. Fitting is via the JAGS method.
ellipses.posterior <- siberMVN(siber.umi, parms, priors)

#Specify which community.group to compare
ellipse1 <- "UZ.Zerafshan" 
ellipse2 <- "UZ.Tashkent"

#Plotting ellipses to display
bayesianOverlap(ellipse1, ellipse2, ellipses.posterior,
                draws = 10, p.interval = 0.95, n = 100, do.plot = T)

# The function is selecting the wrong community.group.
# It looks like it's taking one from KZ (I can't tell which), and comparing to 
# UZ.Ferghana. I get this with other tries too.