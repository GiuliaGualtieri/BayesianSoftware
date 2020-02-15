
data {
  int<lower=0> N;         // number of data
  int<lower = 0> p_fix;   // number of covariates, fixed effects
	int<lower = 0> ngr;	// number of groups
	int<lower = 0> p_ran;   // number of covariates, random effects
	

  real Y[N];  	// response vector
  matrix[N, p_fix] X;   	// design matrix (fixed effects)
	matrix[N, ngr] G;  	// gropus (dummy) allocation ( e.g. row i-th: 1 0 0
	                                    // means that there are 3 groups and element i belongs to group 1)

  matrix[N,p_ran ] Z;              // design matrix (random effects)
  
  real<lower=0> a_hat;
  real<lower=0> b_hat;
}


parameters {
  vector[p_fix] beta;        	// regression coefficients (fixed effects)
	vector[ngr] theta;      	  // (group specific) random effects
	matrix[p_ran, ngr] gamma;     // regression coefficients (random)
	
  vector<lower=0>[p_fix] sigma2_beta;	        // variances for the prior on beta
	vector<lower=0>[ngr] sigma2_theta;	          // variances for the prior on theta
	matrix<lower=0>[p_ran, ngr] sigma2_gamma;    // (group specific) random effects
	
	real<lower=0> sigma2_e;    //error sd
	
	real<lower=0> a;
	real<lower=0> b;
		
	real<lower=0> ab;
	real<lower=0> bb;
		
	real<lower=0> at;
	real<lower=0> bt;
		
	real<lower=0> ag;
	real<lower=0> bg;
	
	
	
}



transformed parameters 
{
	vector[N] mu;
	for(i in 1:N){
    mu[i] =  X[i,] * beta +  Z[i,] * (gamma * G[i,]') + theta' * G[i,]';
	}
}
  	
model {
	// Likelihood     
	for (s in 1:N)
	{
		Y[s] ~ normal(mu[s],pow(sigma2_e,0.5)) ; 
	} 

  for (j in 1:p_fix){
	  	beta[j] ~ normal(0.0, pow(sigma2_beta[j], 0.5));
	    sigma2_beta[j] ~ inv_gamma(ab, bb);
	}

	for (j in 1:ngr){
	 	theta[j] ~ normal(0.0, pow(sigma2_theta[j], 0.5));
		sigma2_theta[j] ~ inv_gamma(at, bt);
	}
	
	
		for (j in 1:p_ran) {
	  for(i in 1:ngr){
	    gamma[j,i] ~ normal(0.0, pow(sigma2_gamma[j,i], 0.5));
	    sigma2_gamma[j,i] ~ inv_gamma(ag, bg);
	  }
	}
	
	sigma2_e ~ inv_gamma(a, b);
	
	a~ exponential(a_hat);
	b~ exponential (b_hat);
	
	ag~ exponential(a_hat);
	bg~ exponential (b_hat);
	
	at~ exponential(a_hat);
	bt~ exponential (b_hat);
	
	ab~ exponential(a_hat);
	bb~ exponential (b_hat);
}