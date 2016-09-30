data {
  int N; # number of data points
  vector[N] T_i; # vector of treatment indicators
  vector[N] y_i0; # observed pre-treatment outcomes
  vector[N] y_i1; # observed post-treatment outcomes
}
parameters {
  real a;
  real b;
  real c;
  real d;
  real<lower=0> sigma_u;
  //real<lower=0> sigma_y;
  vector[N] u_i0;
  vector[N] u_i1;
}
transformed parameters {
  vector[N] u_i1_mean;
  
  u_i1_mean <- a + b * u_i0 + c * T_i + d * u_i0 .* T_i;
}
model {
  a ~ normal(0, 1);
  b ~ normal(0, 1);
  c ~ normal(0, 1);
  d ~ normal(0, 1);
  sigma_u ~ cauchy(0, 2.5);
  //sigma_y ~ cauchy(0, 2.5);
  u_i0 ~ normal(0, 1);
  u_i1 ~ normal(u_i1_mean, sigma_u);
  y_i0 ~ normal(u_i0, sigma_u);
  y_i1 ~ normal(u_i1, sigma_u);
}
