data {
  int n_I;                    // number of PSUs in sample
  int n;                      // total sample size
  real y[n];                  // outcome
  int<lower=0,upper=1> z[n];  // individual-level variable
  vector[n_I] p_j_star;       // vector of p^*_j's
  int psuids_samp_new_rep[n]; // vector of renumbered psu ids for sample, repped for all n sampled obs
}

parameters {
  real beta;
  real gamma0;
  real gamma1;
  real<lower=0> sigma_y;
  real<lower=0> sigma_a;
  vector[n_I] eta_a;
}

transformed parameters {
  vector[n_I] alpha;
  vector[n] yhat;

  alpha <- gamma0 + gamma1*p_j_star + sigma_a*eta_a;
  for (i in 1:n) {
    yhat[i] <- alpha[psuids_samp_new_rep[i]] + beta*z[i];
  }
}

model {
  beta ~ normal(0, 10);
  gamma0 ~ normal(0, 10);
  gamma1 ~ normal(0, 10);
  sigma_y ~ cauchy(0, 2.5);
  sigma_a ~ cauchy(0, 2.5);
  eta_a ~ normal(0, 1);
  y ~ normal(yhat, sigma_y);
}
