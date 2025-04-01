model{
  # likelihood
  for (cur_subject in 1:N) {
    # loop in subject
    intercept[cur_subject] ~ dnorm(0, tau.subject)
    cur_group = group[cur_subject]
    for (cur_time in 1:times) {
      # loop in time
      mu[cur_subject, cur_time] <-
        intercept[cur_subject] +
        alpha.c[cur_group] +
        (beta[cur_group] * cur_time)

      ability[cur_subject, cur_time] ~ dnorm(mu[cur_subject, cur_time], tau.resid)

    } # end of time loop
  } # end of subject loop
  # priors
  var.subject ~ dunif(0, 1.0E4)

  var.resid ~ dunif(0, 1.0E4)

  beta[1] ~ dnorm(0, 1.0E-4)
  # Linear effect of time (group=A)
  beta[2] ~ dnorm(0, 1.0E-4)
  # Linear effect of time (group=B)
  beta[3] ~ dnorm(0, 1.0E-4)
  # Linear effect of time (group=C)
  alpha.c[1] ~ dnorm(0, 1.0E-4)
  # Centered intercept (group=A)
  alpha.c[2] ~ dnorm(0, 1.0E-4)
  # Centered intercept (group=B)
  alpha.c[3] ~ dnorm(0, 1.0E-4)
  # Centered intercept (group=C)
  # scalars
  tau.subject <- 1 / var.subject

  tau.resid <- 1 / var.resid

  rho <- var.subject / (var.resid + var.subject)
  # Within-sub corr.
  b.diff[1] <- beta[2] - beta[1]

  b.diff[2] <- beta[3] - beta[1]

  a.diff[1] <- alpha.c[2] - alpha.c[1]

  a.diff[2] <- alpha.c[3] - alpha.c[1]

}
