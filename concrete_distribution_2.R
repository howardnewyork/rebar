## Implementation of Semi-Discrete Parameter Analysis in Stan

## For mor details see:
# https://casmls.github.io/general/2017/02/01/GumbelSoftmax.html
# 
# "THE CONCRETE DISTRIBUTION: A CONTINUOUS RELAXATION OF DISCRETE RANDOM VARIABLES"
#    http://www.stats.ox.ac.uk/~cmaddis/pubs/concrete.pdf 
# 
# "REBAR: Low-variance, unbiased gradient estimates for discrete latent variable models"
#    https://arxiv.org/pdf/1703.07370.pdf


library(rstan)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

library(ggplot2)

generate_data = function(no_sims, mu1, mu2, p){
  
  
  sim1 = rnorm(no_sims, mu1)
  sim2 = rnorm(no_sims, mu2)
  sims = ifelse(runif(no_sims) <=p, sim1,sim2)
  
  sims

}

if (F){
  no_sims=2000
  sims=generate_data(no_sims, mu1 = 0, mu2 = 5, p = .25)
  ggplot(data.frame(sims=sims)) + geom_density(aes(sims))
  
  
  stan_list= list(
    N=no_sims,
    y=sims,
    D=2,
    tau = 0.02
  )
  
  
  #####################################################################
  #####  Concrete Model
  #####################################################################
  model = stan_model(file = "concrete_2.stan")
  
  run = sampling(model, stan_list, iter = 100, chains=6, control = list(max_treedepth = 15, adapt_delta = 0.95))
  summary(run, pars=c('alpha'))$summary
  summary(run, pars=c('mu'))$summary
  summary(run, pars=c('X'))$summary
  stan_rhat(run)
  stan_ess(run)
  stan_mcse(run)
  
  
  # Check some results
  X = rstan::extract(run, pars='X')[[1]]
  str(X)
  sims[5]
  plot(X[,5,1])
  
  #####################################################################
  #####  REBAR Model
  #####################################################################
  model = stan_model(file = "rebar_1.stan")
  
  run = sampling(model, stan_list, iter = 100, chains=6, control = list(max_treedepth = 15, adapt_delta = 0.95))
  run
  summary(run, pars=c('alpha'))$summary
  summary(run, pars=c('mu'))$summary
  summary(run, pars=c('X'))$summary
  stan_rhat(run)
  stan_ess(run)
  stan_mcse(run)
  
  
  # Check some results
  X = rstan::extract(run, pars='X')[[1]]
  str(X)
  sims[5]
  plot(X[,5,1])
  
}