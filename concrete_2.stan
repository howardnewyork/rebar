//  Stan Implementation of the Concrete Distribution



data {
  int<lower=1> N; //number of samples
  vector[N] y;  // data
  int D;  // number of one-hot-encoding values
  real tau;  // concrete concentration parameter
}

parameters {
  //vector<lower=0, upper =1>[N, D] U;  // uniform parameter
  vector[D] G[N];  // gumbel parameter
  simplex[D] alpha;  // probabilities of categorical distribution
  
  ordered[D] mu;  // Mean parameter
  
  
}

transformed parameters{
  //vector[N,D] G;  // gumbel parameter
  matrix[N,D] X;  // Categorical one-hot encoding for derived from Concrete distribution
  
  // Creation of the Concrete Distribition
  {

    for (n in 1:N){
      X[n]= softmax((log(alpha) + G[n])/tau)';
    }
  }
}

model {
  // priors
  for (n in 1:N){
    G[n] ~ gumbel(0,1);
  }
  alpha ~ uniform(0,1);
  
  mu ~ normal(0, 20);

  // model
  y ~ normal(X * mu, 1);
  

}
