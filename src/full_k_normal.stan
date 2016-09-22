data {
  int n_I;                    // number of sampled psus
  int n;                      // total sample size
  real y[n];                  // outcome
  int<lower=0,upper=1> z[n];  // individual-level variable
  vector[n_I] log_N_j;        // vector of psu population sizes
  int psuids_samp_new_rep[n];     // vector of renumbered psu ids for sample, repped for all n sampled obs
  int sum_z[n_I];             // sum of sampled z's in each PSU
}

transformed data {
  int n_j;
  n_j <- n / n_I;
}

parameters {
  real beta;
  real gamma0;
  real gamma1;
  real gamma2;
  real<lower=0> sigma_y;
  real<lower=0> sigma_a;
  vector[n_I] eta_a;
  real mu;
  real<lower=0> tau;
  vector[n_I] logit_rho;
}

transformed parameters {
  vector[n_I] alpha;
  vector[n] yhat;
  vector[n_I] rho;

  for (k in 1:n_I) {
    rho[k] <- inv_logit(logit_rho[k]);
  }
  alpha <- gamma0 + gamma1*rho + gamma2*log_N_j + sigma_a*eta_a;

  for (i in 1:n) {
    yhat[i] <- alpha[psuids_samp_new_rep[i]] + beta*z[i];
  }
}

model {
  beta ~ normal(0, 10);
  gamma0 ~ normal(0, 10);
  gamma1 ~ normal(0, 10);
  gamma2 ~ normal(0, 10);
  sigma_y ~ cauchy(0, 2.5);
  sigma_a ~ cauchy(0, 2.5);
  eta_a ~ normal(0, 1);
  mu ~ normal(0, 1);
  tau ~ cauchy(0, 2.5);
  logit_rho ~ normal(mu, tau);
  for (k in 1:n_I) {
    sum_z[k] ~ binomial(n_j, rho[k]);
  }
  y ~ normal(yhat, sigma_y);
}
