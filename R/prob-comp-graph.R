

RD <- function(p1, p2) p1 - p2
RR <- function(p1, p2) p1/p2
odds <- function(p) 1/(1/p-1)
OR <- function(p1, p2) odds(p1) / odds(p2)
OR_minus_RR <- function(p1, p2) OR(p1, p2) - RR(p1, p2)

if (run_graph) {
  n_ticks <- 201
  # probs <- c(10^-(3:1), seq(.02, .25, by = .02))
  # probs <- 10^seq(-4, log10(.99), length.out = n_ticks)
  probs <- seq(.1, .99, length.out = n_ticks)
  RD_mat <- outer(probs, probs, RD)
  RR_mat <- outer(probs, probs, RR)
  OR_mat <- outer(probs, probs, OR)
  OR_minus_RR_mat <- outer(probs, probs, OR_minus_RR)
  to_erase1 <- outer(probs, probs, `<`)
  to_erase2 <- abs(log(OR_mat)) > log(3)
  to_erase3 <- abs(OR_minus_RR_mat) > 10
  to_erase4 <- abs(RR_mat) > 15
  to_erase <-
    to_erase1 |
    to_erase3 | to_erase4
  RD_mat[to_erase] = NA
  RR_mat[to_erase] = NA
  OR_mat[to_erase] = NA
  OR_minus_RR_mat[to_erase] = NA

  opacity = .9

  plotly::plot_ly(
    x = ~probs,
    y = ~probs
  ) |>
    plotly::add_surface(
      z = ~ t(RD_mat),
      name = "risk difference",
      showscale = FALSE,
      opacity = .5,
      colorscale = list(c(0, 1), c("green", "green"))
    ) |>
    plotly::add_surface(
      opacity = .5,
      colorscale = list(c(0, 1), c("red", "red")),
      z = ~ t(RR_mat),
      showscale = FALSE,
      name = "risk ratio"
    ) |>
    plotly::add_surface(
      opacity = .5,
      colorscale = list(c(0, 1), c("blue", "blue")),
      z = ~ t(OR_mat),
      showscale = FALSE,
      name = "odds ratio"
    ) |>
    plotly::layout(
      scene = list(
        xaxis = list(
          # type = "log",
          title = "p1"
        ),
        yaxis = list(
          # type = "log",
          title = "p2"
        ),
        zaxis = list(
          # type = "log",
          title = "comparison"
        ),
        camera = list(eye = list(x = -1.25, y = -1.25))
      )
    )

}

{
  plotly::add_surface(
    opacity = .5,
    colorscale = list(c(0, 1), c("red", "red")),
    z = ~ t(OR_minus_RR),
    showscale = FALSE,
    name = "risk ratio"
  ) |>
    plotly::add_surface(
      opacity = opacity,
      colorscale = list(c(0, 1), c("blue", "blue")),
      z = ~ t(OR_mat),
      showscale = FALSE,
      name = "odds ratio"
    ) |>
    plotly::layout(
      scene = list(
        xaxis = list(
          # type = "log",
          title = "p1"
        ),
        yaxis = list(
          # type = "log",
          title = "p2"
        ),
        zaxis = list(
          # type = "log",
          title = "comparison"
        ),
        camera = list(eye = list(x = -1.25, y = -1.25))
      )
    )


}
