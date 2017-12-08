# CONCRETE and REBAR:  Modeling Discrete Random Variables in Stan

The CONCRETE and REBAR distributions are continuous distributions that approximate a discrete categorical distribution where the categories are described in a one-hot encoding vector style.  The distributions are derived as a reparameterization of a Uniform to a Gumbel to a CONCRETE / REBAR distrbution. Since Stan has a Gumbel distribution, it is possible to go straight from Gumbel to REBAR.  Since these are continous distributions, they can be incorporated in Stan as parameters, even they produce values that are (very) close to being discrete.

As an example, if we are trying to model a categorical parameter with 2 options, this can be encoded as:
- Category 1:  [1 0]
- Category 2:  [0 1]

In practice, the REBAR will produce something like [0.9999, 0.0001] for category 1 and occasionaly will produce an wild outlier that differs materially from a one-hot encoding.

The two papers that describe these distributions are:

 "THE CONCRETE DISTRIBUTION: A CONTINUOUS RELAXATION OF DISCRETE RANDOM VARIABLES"
    http://www.stats.ox.ac.uk/~cmaddis/pubs/concrete.pdf 
 
 "REBAR: Low-variance, unbiased gradient estimates for discrete latent variable models"
    https://arxiv.org/pdf/1703.07370.pdf

A good blog post can also be found here:
   https://casmls.github.io/general/2017/02/01/GumbelSoftmax.html
   
  Both distributions are similar and have two parameters:
  alpha:  this is a simplex of k numbers and defines the probability of any category being selected
  tau: this is a concentration parameter.  As tau -> 0, the distribution becomes more discrete like, as t -> infinity, the distribution will tend to alpha.
 
 The REBAR distribution is an unbiased version of the CONCRETE distribution and appears to be the prefered option to use.
 
  I have found that a good value for tau in some toy examples is around 0.1 to 0.5.  As you make tau lower, the Stan chains tend to have more difficulty converging.
  
  As an example, if you are modeling a distribution with two modes, mu[1] and mu[2], where mu = [mu[1], mu[2]], and X is a N x 2 matrix where each row is a one-hot encoding of the category, then it would be nice to model this in stan using the line:
  
  y ~ normal( X * mu, sigma);
  
  Modeling each row of X as a CONCRETE or REBAR allows this model to be constructed without the need to resort to marginalizing over the alpha parameter.
  
  
  
  
