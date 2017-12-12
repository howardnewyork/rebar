//  Stan Implementation of the REBAR Distribution



data {
  int<lower=1> N; //number of samples
  int D;  // number of one-hot-encoding values
  vector[D] y[N];  // output
  real tau;  // concrete concentration parameter
  real<lower=0> beta_prior;  // prior for beta
}

parameters {
  //vector<lower=0, upper =1>[N, D] U;  // uniform parameter
  vector[2] G[D];  // gumbel parameter
  simplex[2] alpha;  // probabilities of categorical distribution
  
  vector[D] beta;  // Mean parameter

}

transformed parameters{
  vector[D] one_hot;  // Categorical one-hot encoding for derived from Concrete distribution
  
  // Creation of the REBAR Distribition
  {
    
    for (d in 1:D){
      one_hot[d]= softmax((log(alpha)*(tau^2 + tau +1) / (tau+1) + G[d])/tau)[2]; //pick the second element

    }
  }
}

model {
  // priors
  for (n in 1:D){
    G[n] ~ gumbel(0,1);
  }
  alpha ~ uniform(0,1);
  
  beta ~ normal(0, beta_prior);

  // model
  for (n in 1:N){
    y[n] ~ normal(one_hot .* beta, 1);
  }
}
