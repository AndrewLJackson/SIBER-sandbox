library(ggplot2)
library(tidyverse)
library(readr)
library(coda)
library(SIBER)
 library(dplyr)

data <- read_csv("kerry-nicholson/SI 18MAR22 TipBaseMid.csv")
names(data)

claw<-as.data.frame(select(data, iso1, iso2, group, community))

siber.claw<-createSiberObject(claw)
siber.claw$sample.sizes
group.ML <- groupMetricsML(siber.claw)
print(group.ML)
write.csv(group.ML, "GroupMetrics_Case1.csv")

# Calculate the various Layman metrics on each of the communities.
community.ML <- communityMetricsML(siber.claw) 
print(community.ML)
write.csv(community.ML, "CommunityMetrics_Case1.csv")

parms <- list()
parms$n.iter <- 2 * 10^4   # number of iterations to run the model for
parms$n.burnin <- 1 * 10^3 # discard the first set of values
parms$n.thin <- 10     # thin the posterior by this many
parms$n.chains <- 2        # run this many chains
parms$save.output = TRUE
parms$save.dir <- getwd()
# define the priors
priors <- list()
priors$R <- 1 * diag(2)
priors$k <- 2
priors$tau.mu <- 1.0E-3

####################################################################

#Fitting ellipses  via the JAGS and calculating Standard Ellipse Area
####################################################################
# fit the ellipses which uses an Inverse Wishart prior
# on the covariance matrix Sigma, and a vague normal prior on the means. 
ellipses.posterior <- siberMVN(siber.claw, parms, priors)

SEA.B <- siberEllipses(ellipses.posterior)

siberDensityPlot(SEA.B, xticklabels = colnames(group.ML), 
                 xlab = c("Community | Group"),
                 ylab = expression("Standard Ellipse Area " ('\u2030' ^2) ),
                 bty = "L",
                 las = 1,
                 main = "SIBER ellipses on each group"
)

# Add red x's for the ML estimated SEA-c
points(1:ncol(SEA.B), group.ML[3,], col="red", pch = "x", lwd = 2)

# dev.copy(jpeg,'Posterior ellipse Tissue by GMU.jpg',
#          quality = 300, res = 300,
#          width = 15,
#          height = 6,
#          units = "in")
# dev.off()
##################################################
p.ell <- 0.4
ggplot(claw, aes(x = iso1, y = iso2, fill = group,
           lty = community,
           shape = group))+

        stat_ellipse(type = "norm", geom = "polygon", level = p.ell, alpha = 0.65,#alpha is transparency
                     size = .7,  color = "black", #fill = NA, #fill = NA used if do not want to see claw sections
                      aes(group = interaction(group, community)))+
                       #aes(group = community,lty = community)) + #use if want to not see claw sections
            scale_linetype_manual(values=c("solid", "dotted"))+
  
         geom_point(aes(fill = group),  size = 3.5)+  #moving points below ellipse puts points ontop of ellipse
            scale_shape_manual(values = c(21, 22, 25),labels = c("Tip", "Mid","Base"))+ #labels has to match 
              scale_fill_manual(values = c("white","grey","black"),
                       labels = c("Tip", "Mid","Base"))+ #labels has to match
        labs(x = expression(delta ^ 13 * "C (\u2030)"),
             y = expression(delta ^ 15 * "N (\u2030)")) +
        scale_x_continuous(breaks= seq(-26.5, -19.5, by = 0.5),
                           #labels = c( -24, rep("", 2), -23, rep("", 2), -21),
                           limits = c(-26.5, -19),
                           expand = c(0, 0)) +
        scale_y_continuous(breaks= seq(4, 11),
                           labels = c(4, "",6, "",8, "", 10, ""),
                           limits = c(3.5, 11),
                           expand = c(0, 0)) +
    guides (lty = guide_legend(override.aes = list(fill = NA)), #override the legend fill in for lyt which is the ellipses
      #shape = guide_legend(override.aes = list(fill = NA)), #white or NA makes shape legend all white background
            fill = guide_legend(override.aes = list(shape = c(21, 22, 25))))+ #Make's sure legend matches plot shapes
  theme_classic(base_size = 14) +
   theme(legend.position = c(0.1, 0.85))+
        theme(legend.title = element_blank())
ggsave(filename = 'Claw segments.jpg',
       dpi = 300,
       width = 8,
       height = 6,
       units = "in")
