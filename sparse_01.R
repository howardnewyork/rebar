## Implementation of Semi-Discrete Parameter Analysis in Stan

## Toy model to identify features in a sparse setup...
## Toy model derived from here:  https://arxiv.org/pdf/1707.01694.pdf
## "Sparsity information and regularization in the horseshoe and other shrinkage priors"


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
library(tidyr)
library(dplyr)

if (T){
  D =400 # number of features
  signal_no = 20 # number of features with signal
  signal = 1:signal_no
  noise = (signal_no+1):D
  N=100
  stan_list= list(
    N=N,
    D=D,
    tau = 0.035,
    beta_prior = 5
  )
  
  #####################################################################
  #####  REBAR Model for Sparsity Signal Selection
  #####################################################################
  model = stan_model(file = "sparse_02.stan")
  
  A_vec = 1:10 #c(1, 5, 10)
  mse = mse_2 = rep(0,length(A_vec))
  i=1
  for (A in A_vec){
    print(paste("Model A =", A))
    y= matrix(0, N, D)
    beta = c(
      rep(1, signal_no),
      rep(0,D-signal_no)
    ) * A 
    for (n in 1:N){
      y[n,] = rnorm(D, beta, 1)
    }
    #plot(colMeans(y))
    stan_list$y =y 
    run = sampling(model, stan_list, iter = 120, chains=6, control = list(max_treedepth = 16, adapt_delta = 0.993))
    #summary(run, pars=c('alpha'))$summary
    #summary(run, pars=c('beta'))$summary
    #summary(run, pars=c('one_hot'))$summary
    
    beta_sim = rstan::extract(run, "beta")[[1]]
    str(beta_sim)

    one_hot_sim = rstan::extract(run, "one_hot")[[1]]

    beta_mean = colMeans(beta_sim)
    one_hot_mean = colMeans(one_hot_sim)
    plot(beta_sim[,1])
    plot(beta_sim[,11])
    plot(beta_mean)
    plot(one_hot_mean)
    beta_mean_2 = colMeans(beta_sim * one_hot_sim)
    mse[i] = mean((beta_mean-beta)^2)
    mse_2[i] = mean((beta_mean_2-beta)^2)
    print(paste("A: ",A, "MSE:", mse[i], "  MSE_2:", mse_2[i]))
    
    # A Feature that produces signal should have one_hot value of 1 in chart below
    mean_data = data.frame(feature = 1:D, one_hot = one_hot_mean, beta = beta_mean, beta_adjusted = beta_mean_2)
    
    print(ggplot(mean_data) + geom_point(aes(feature, one_hot)) + labs(title=paste("Identified Features\n1=Signal; 0=Noise\nA = ", A)))
    print(ggplot(mean_data) + geom_point(aes(feature, beta)) + labs(title=paste("Beta Values", A)))
    print(ggplot(mean_data) + geom_point(aes(feature, beta_adjusted)) + labs(title=paste("Adjusted Beta Values", A)))
    
    stan_rhat(run)
    stan_ess(run)
    stan_mcse(run)
    
    
    i=i+1
  }
  
   # Summary of Mean Square Error
  errors = data.frame(A = A_vec, mse = mse, mse_2 = mse_2)
  print(errors)
  write.csv(errors, file = "errors_sparse_example.csv")
  #erorrs=errors[1:6,]
  errors_plot = errors %>%
    gather(error, value, -A)
  #errors=errors[1:6,]
  print(ggplot(errors_plot) + geom_line(aes(A, value, color = error)) + labs(title = "MSE of (i) beta and (ii) beta .* one_hot[,2]", y="Error"))
  print(ggplot(errors) + geom_line(aes(A, mse_2)) + labs(title = "MSE of  beta .* one_hot", y="Error", x="A") + 
    scale_x_continuous(breaks= 1:6))
  
  
  

}
