## Implementation of Semi-Discrete Parameter Analysis in Stan

## Feature Selection Model

# ## Description of Model:
# N = number of data points
# D = Number of Features.  All are noise except the first 10 which produce a signal
# beta = c(1,1,1,...1,.0,....,0) :First 10 are 1, rest are zero
# x = random feaures:  NxD matrix
# 
# y= beta %*% x
# 
# Task:   identify and noise and signal values, and model beta 


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


if (T){
  D =100
  signal = 1:10
  noise = 11:D
  N=50
  x = matrix(rnorm(D *N),N, D)
  A = 1  # level of signal
  beta = c(
    rep(1, 10),
    rep(0,D-10)
  ) * A
  
  y = x %*% beta

  stan_list= list(
    N=N,
    y=c(y),
    x=x,
    D=D,
    tau = 0.01
  )
  
  
  #####################################################################
  #####  REBAR Model
  #####################################################################
  model = stan_model(file = "feature_selection_01.stan")
  
  run = sampling(model, stan_list, iter = 200, chains=6, control = list(max_treedepth = 15, adapt_delta = 0.99))
  summary(run, pars=c('alpha'))$summary
  beta = summary(run, pars=c('beta'))$summary
  #summary(run, pars=c('sigma'))$summary
  one_hot_summary = summary(run, pars=c('one_hot'))$summary
  one_hot_summary
  head(one_hot_summary)
  # A Feature that produces signal should have one_hot value of 1 in chart below
  mean_data = data.frame(feature = 1:D, one_hot = one_hot_summary[(1:D)*2,1], beta = beta[,1])
  
  print(ggplot(mean_data) + geom_point(aes(feature, one_hot)) + labs(title="Identified Features\n1=Signal; 0=Noise"))
  print(ggplot(mean_data) + geom_point(aes(feature, one_hot * beta)) + labs(title="Adjusted Beta Values"))
  

  stan_rhat(run)
  stan_ess(run)
  stan_mcse(run)
  
  
  # Check some results
  one_hot = rstan::extract(run, pars='one_hot')[[1]]
  alpha = rstan::extract(run, pars='alpha')[[1]]
  str(one_hot)
  plot(one_hot[,1,2]) # feature
  plot(one_hot[,2,2]) # feature
  plot(one_hot[,11,2]) # non feature
  plot(one_hot[,12,2]) # non feature
  

  
  
}
