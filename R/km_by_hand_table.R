#' Build a Kaplan-Meier by-hand table
#'
#' Takes a data frame with `time` and `death` columns and returns a
#' `knitr_kable` table showing the time-point, risk set, contribution, and
#' survival estimate at each event or censoring time.
#'
#' @param data A data frame with columns `time` (numeric) and `death`
#'   (0/1 integer or logical).
#'
#' @returns A `knitr_kable` object (LaTeX/HTML math strings, `escape = FALSE`).
#' @export
#' @examples
#' d <- data.frame(time = c(1, 2, 3, 3, 5), death = c(1, 0, 1, 1, 0))
#' km_by_hand_table(d)
km_by_hand_table <- function(data) {
  stopifnot(
    "data must have a 'time' column"  = "time"  %in% names(data),
    "data must have a 'death' column" = "death" %in% names(data),
    "'death' must be 0/1 or logical"  = all(data$death %in% c(0, 1)),
    "'time' must not contain NA"       = !anyNA(data$time)
  )

  time   <- data$time
  status <- data$death
  n      <- length(time)

  gcd_fn <- function(a, b) {
    while (b != 0) {
      tmp <- b
      b   <- a %% b
      a   <- tmp
    }
    a
  }

  # `format()` falls back to scientific notation for small values (e.g.
  # `format(1e-6)` -> "1e-06"), which is invalid inside a `$...$` math
  # environment; this always produces fixed-point output.
  fmt_dec <- function(x) {
    formatC(x, format = "f", digits = 4, drop0trailing = TRUE)
  }

  df <- dplyr::tibble(time = time, status = status) |>
    dplyr::arrange(time) |>
    dplyr::group_by(time) |>
    dplyr::summarise(
      deaths   = sum(status),
      censored = sum(1L - as.integer(status)),
      .groups  = "drop"
    )

  # Number at risk at each time = sample size minus everyone who left
  # (via death or censoring) at an *earlier* time point.
  left_before <- cumsum(c(0L, utils::head(df$deaths + df$censored, -1L)))
  df$n_risk   <- n - left_before

  # Running survival numerator/denominator are doubles so that whole-number
  # products beyond .Machine$integer.max stay exact instead of overflowing.
  surv_n        <- 1
  surv_d        <- 1
  prev_surv_str <- "1"

  tbl <- dplyr::tibble(
    `Time-point`        = numeric(nrow(df)),
    `Risk set`          = integer(nrow(df)),
    `Contribution`      = character(nrow(df)),
    `Survival Estimate` = character(nrow(df))
  )

  for (i in seq_len(nrow(df))) {
    ni     <- as.integer(df$n_risk[i])
    di     <- as.integer(df$deaths[i])
    cn_raw <- ni - di

    if (cn_raw == ni) {
      c_n <- 1
      c_d <- 1
    } else if (cn_raw == 0L) {
      c_n <- 0
      c_d <- 1
    } else {
      g   <- gcd_fn(cn_raw, ni)
      c_n <- cn_raw %/% g
      c_d <- ni %/% g
    }

    surv_n <- surv_n * c_n
    surv_d <- surv_d * c_d
    if (surv_n > 0) {
      g      <- gcd_fn(surv_n, surv_d)
      surv_n <- surv_n %/% g
      surv_d <- surv_d %/% g
    }

    frac_str <- if (c_n == 1 && c_d == 1) {
      "1"
    } else if (c_n == 0) {
      "0"
    } else {
      sprintf("\\frac{%.0f}{%.0f}", c_n, c_d)
    }

    contrib_cell <- if (di == 0L) {
      sprintf(
        "$\\left(1 - \\frac{%d}{%d}\\right) = 1$",
        di, ni
      )
    } else if (c_n == 0) {
      sprintf(
        "$\\left(1 - \\frac{%d}{%d}\\right) = 0$",
        di, ni
      )
    } else {
      sprintf(
        "$\\left(1 - \\frac{%d}{%d}\\right) = \\frac{%.0f}{%.0f} = %s$",
        di, ni, c_n, c_d, fmt_dec(c_n / c_d)
      )
    }

    surv_cell <- if (di == 0L) {
      sprintf("$%s$", prev_surv_str)
    } else if (surv_n == 0) {
      sprintf("$%s \\times %s = 0$", prev_surv_str, frac_str)
    } else {
      sprintf(
        "$%s \\times %s = \\frac{%.0f}{%.0f} = %s$",
        prev_surv_str, frac_str, surv_n, surv_d, fmt_dec(surv_n / surv_d)
      )
    }

    if (di > 0L) {
      prev_surv_str <- if (surv_n == 0) {
        "0"
      } else {
        sprintf("\\frac{%.0f}{%.0f}", surv_n, surv_d)
      }
    }

    tbl$`Time-point`[i]        <- df$time[i]
    tbl$`Risk set`[i]          <- ni
    tbl$`Contribution`[i]      <- contrib_cell
    tbl$`Survival Estimate`[i] <- surv_cell
  }

  knitr::kable(tbl, escape = FALSE)
}
