library(glmx)
beetles <- BeetleMortality |>
  mutate(
    pct = died/n,
    survived = n - died
  )

usethis::use_data(beetles, overwrite = TRUE)
