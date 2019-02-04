data(demo.siber.data)

library(tidyverse)

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 
# This first chunk of code just checks that my understanding of how
# the piped tidyverse code is working is correct. 

# test with groupMetrics
my.siber.data <- createSiberObject(demo.siber.data)
SEA_siber <- groupMetricsML(my.siber.data)

# this code calculates SEA using dplyr to check my syntax works
SEA_dplyr <- demo.siber.data %>% group_by(group, community) %>% 
  summarize(test = sigmaSEA(cov(cbind(iso1, iso2)))$SEA)

# these are the same as calculated using groupMetricsML() 
# but the order of presentation is different
print(SEA_dplyr)

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 
# Now we can safely calculate eccentricity

# knowing this is behaving correctly, we can calculate eccentricity 
# in a similar way
eccentricity_dplyr <- demo.siber.data %>% group_by(group, community) %>% 
  summarize(test = sigmaSEA(cov(cbind(iso1, iso2)))$eccentricity)

print(eccentricity_dplyr)

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 