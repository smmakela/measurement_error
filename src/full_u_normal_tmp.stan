data {
  int J;                      // number of psus
  int N;                      // total sample size
  real y[N];                  // outcome
  int<lower=0,upper=1> z[N];  // individual-level variable
  int psuids[N];              // vector of psu ids
}

transformed data {
  real<lower=0> sigma_a;
  real<lower=0> sigma_y;
  sigma_a <- 0.5;
  sigma_y <- 1;
}

parameters {
  real beta;
  real gamma0;
  real gamma1;
  vector[J] logit_rho;
  real mu;
  real<lower=0> tau;
  //real<lower=0> sigma_a;
  //real<lower=0> sigma_y;
  real eta_a;
  real eta_y;
}

transformed parameters {
  vector[J] alpha;
  vector[N] yhat;
  for (j in 1:J) {
    alpha[j] <- gamma0 + gamma1*inv_logit(logit_rho[j]) + sigma_a*eta_a;
  }
  for (i in 1:N) {
    yhat[i] <- alpha[psuids[i]] + beta*z[i] + sigma_y*eta_y;
  }
}

model {
  beta ~ normal(0, 2);
  gamma0 ~ normal(0, 2);
  gamma1 ~ normal(0, 2);
  mu ~ normal(0, 2);
  tau ~ cauchy(0, 5);
  logit_rho ~ normal(mu, tau);
  //sigma_a ~ cauchy(0, 5);
  //sigma_y ~ cauchy(0, 5);
  eta_a ~ normal(0, 1);
  eta_y ~ normal(0, 1);
  for (i in 1:N) {
    z[i] ~ bernoulli_logit(logit_rho[psuids[i]]);
  }
}
