SIBER-sandbox
=============

Testing a new approach to fitting ellipses to data by z-transforming, fitting using JAGS, 
then back-transforming to original scale. This seems to work much more consistently when
the axes scales are quite different from one another.

 I have been aware of some issues of fitting for a few months now whereby the maximum 
 likelihood calculates SEA and SEA_c seem do not match the Bayesian SEA_B analogues.
 I have implemented an alternative approach that seems to work much better in all cases.
 The times when it tends to fail is when there is a big difference in the x and y axis scales
 but I have seen other examples fail without apparent obvious reason.
 
 In this repository, I include some files to illustrate the problem and a workaround
 which will form part of an update for SIBER when I get time. However, this is unlikely
 to happen for several months as I have other commitments. In the future, the mixing 
 model part of SIAR will likely be subsumed into MixSIAR https://github.com/brianstock/MixSIAR
 leaving SIBER as a standalone package.
 
 There are two files of note in this repo.
 
 "illustrating_the_SEA_problem.R" demonstrates some mismatch between ML and Bayesian estimates.
 I am grateful to Alex Bond for supplying this toy dataset and for bringing this to my attention
 (there were also some others that showed me similar behaviour, but I dont have a record of who).
 
 "SEA_alternative_fitting.R" rescales the data to z-score prior to fitting via both the 
 package bayesm and the JAGS software, before back-transforming the data to the original scale.
 this approach appears to be much more satisfactory. I suspecthe fitting algorithms struggle
 when the x and y axes are quite different in scale (ie when one is much larger than the other)
 and / or because perhaps the priors are designed for z-score scaled data. The latter would require
 more investigation to confirm.
 
 "BUGS_models.R" contains the code for specifying the Bayesian models in the BUGS or JAGS language.
 It also contains the routines for simullating posterior draws from the function rmultireg() in 
 the package bayesm.
 
 "SEA_fitting.R" is a wrapper that interfaces with either the JAGS or bayesm approaches.
