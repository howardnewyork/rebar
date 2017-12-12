/////////////////////////////////////////////////////
// 
//  Feauture Selection Model
//  Stan Implementation of the REBAR Distribution
// 
/////////////////////////////////////////////////////



data {
  int<lower=1> N; //number of samples
  int D;  // number of one-hot-encoding values
  matrix[N, D] x;  // covariates
  vector[N] y;  // output
  real tau;  //  concentration parameter
}

parameters {
  //vector<lower=0, upper =1>[N, D] U;  // uniform parameter
  vector[2] G[D];  // gumbel parameter
  simplex[2] alpha;  // probabilities of categorical distribution
  
  vector[D] beta;  // Mean parameter

}

transformed parameters{
  matrix[D,2] one_hot;  // Categorical one-hot encoding for derived from Concrete / REBAR distribution
  
  // Creation of the REBAR Distribition
  {
    
    for (d in 1:D){
      one_hot[d]= softmax((log(alpha)*(tau^2 + tau +1) / (tau+1) + G[d])/tau)';

    }
  }
}

model {
  // priors
  for (n in 1:D){
    G[n] ~ gumbel(0,1);
  }
  alpha ~ uniform(0,1);
  
  beta ~ normal(0, 2);

  // model
  y ~ normal(x * (one_hot[,2] .* beta), 1);
  

}
