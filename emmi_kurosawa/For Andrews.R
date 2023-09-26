setwd("/Users/gamba/Desktop/Test")

library(devtools)
library(MixSIAR)

#1. Spring 
mix <- load_mix_data(filename="mix_Spring.csv", 
                     iso_names=c("d13C","d15N"), 
                     factors=NULL, 
                     fac_random=NULL, #random = FALSE or TRUE did not matter to the MCMC error.
                     fac_nested=NULL, 
                     cont_effects=NULL)
mix
# Load the source data
source <- load_source_data(filename="source_Spring.csv",
                           source_factors=NULL,
                           conc_dep=FALSE, 
                           data_type="means", 
                           mix)
source

#Load discrimination data (SD neg. or pos. did not matter to the biplot)
discr <- load_discr_data(filename="tef.csv", mix)
discr

#Make isopace plot
plot_data(filename="isospace_Spring", plot_save_pdf=TRUE,
          plot_save_png=TRUE, mix,source,discr)

#1. using no priori
# default "UNINFORMATIVE" / GENERALIST prior (alpha = 1)
alpha.unif <- rep(1, source$n.sources)
plot_prior(alpha.prior=alpha.unif,
           source=source,
           filename="Prior_Spring")

#Write JAGS model file
##We’ll use the default Resid * Process error structure:
model_filename <- "Model_Spring.txt"
resid_err <- TRUE
process_err <- TRUE
write_JAGS_model(model_filename, resid_err, process_err, mix, source)#This creates MixSIAR_model.txt.

#W No priori
jags.spec <- run_model(run="long", mix, source, discr, model_filename,alpha.prior = alpha.unif, resid_err, process_err)

# Create diagnostics, summary statistics, and posterior plots
output_JAGS(jags.spec, mix = mix, source = source,
            output_options = 
              list(summary_save = TRUE, 
                   summary_name = "summary_statistics_Spring",
                   sup_post = FALSE, 
                   plot_post_save_pdf = TRUE, 
                   plot_post_name = "posterior_density_Spring",
                   sup_pairs = FALSE, 
                   plot_pairs_save_pdf = TRUE, 
                   plot_pairs_name = "pairs_plot_Spring", 
                   sup_xy = TRUE, 
                   plot_xy_save_pdf = FALSE, 
                   plot_xy_name = "xy_plot_Spring", 
                   gelman = TRUE, 
                   heidel =FALSE, 
                   geweke = TRUE, 
                   diag_save = TRUE, 
                   diag_name = "diagnostics_Spring", 
                   indiv_effect = FALSE, 
                   plot_post_save_png = FALSE, 
                   plot_pairs_save_png = FALSE, 
                   plot_xy_save_png = FALSE, 
                   diag_save_ggmcmc = TRUE))
################################################################################################
#2. Fall 
mix <- load_mix_data(filename="mix_Fall.csv", 
                     iso_names=c("d13C","d15N"), 
                     factors=NULL, 
                     fac_random=NULL, #random = FALSE or TRUE did not matter to the MCMC error.
                     fac_nested=NULL, 
                     cont_effects=NULL)
mix
# Load the source data
source <- load_source_data(filename="source_Fall.csv",
                           source_factors=NULL,
                           conc_dep=FALSE, 
                           data_type="means", 
                           mix)
source

#Load discrimination data (SD neg. or pos. did not matter to the biplot)
discr <- load_discr_data(filename="tef.csv", mix)
discr

#Make isopace plot
plot_data(filename="isospace_Fall", plot_save_pdf=TRUE,
          plot_save_png=TRUE, mix,source,discr)

#1. using no priori
# default "UNINFORMATIVE" / GENERALIST prior (alpha = 1)
alpha.unif <- rep(1, source$n.sources)
plot_prior(alpha.prior=alpha.unif,
           source=source,
           filename="Prior_Fall")

#Write JAGS model file
##We’ll use the default Resid * Process error structure:
model_filename <- "Model_Fall.txt"
resid_err <- TRUE
process_err <- TRUE
write_JAGS_model(model_filename, resid_err, process_err, mix, source)#This creates MixSIAR_model.txt.

#W No priori
jags.spec <- run_model(run="long", mix, source, discr, model_filename,alpha.prior = alpha.unif, resid_err, process_err)

# Create diagnostics, summary statistics, and posterior plots
output_JAGS(jags.spec, mix = mix, source = source,
            output_options = 
              list(summary_save = TRUE, 
                   summary_name = "summary_statistics_Fall",
                   sup_post = FALSE, 
                   plot_post_save_pdf = TRUE, 
                   plot_post_name = "posterior_density_Fall",
                   sup_pairs = FALSE, 
                   plot_pairs_save_pdf = TRUE, 
                   plot_pairs_name = "pairs_plot_Fall", 
                   sup_xy = TRUE, 
                   plot_xy_save_pdf = FALSE, 
                   plot_xy_name = "xy_plot_Fall", 
                   gelman = TRUE, 
                   heidel =FALSE, 
                   geweke = TRUE, 
                   diag_save = TRUE, 
                   diag_name = "diagnostics_Fall", 
                   indiv_effect = FALSE, 
                   plot_post_save_png = FALSE, 
                   plot_pairs_save_png = FALSE, 
                   plot_xy_save_png = FALSE, 
                   diag_save_ggmcmc = TRUE))
