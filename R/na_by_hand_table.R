#' Build a Nelson-Aalen by-hand table
#'
#' Takes a data frame with `time` and `death` columns and returns a
#' `knitr_kable` table showing the time-point, risk set, hazard increment,
#' cumulative hazard, and Nelson-Aalen survival estimate at each time point.
#'
#' @param data A data frame with columns `time` (numeric) and `death`
#'   (0/1 integer or logical).
#'
#' @details
#' The "NA Survival" column is rendered with the `\expf` macro from the
#' book's `latex-macros/macros.qmd`, so this function is intended for use
#' inside the `rme` book render pipeline. Outside that environment (a bare
#' `knitr` document or `pkgdown` page) define `\expf` or that column will
#' show an undefined control sequence.
#'
#' @returns A `knitr_kable` object (LaTeX/HTML math strings, `escape = FALSE`).
#' @export
#' @examples
#' d <- data.frame(time = c(1, 2, 3, 3, 5), death = c(1, 0, 1, 1, 0))
#' na_by_hand_table(d)
na_by_hand_table <- function(data) {
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

  # Running cumulative-hazard numerator/denominator are doubles so that
  # whole-number products beyond .Machine$integer.max stay exact instead
  # of overflowing.
  cum_haz_n   <- 0
  cum_haz_d   <- 1
  cum_haz_str <- "0"

  tbl <- dplyr::tibble(
    `Time-point`        = numeric(nrow(df)),
    `Risk set`          = integer(nrow(df)),
    `Hazard increment`  = character(nrow(df)),
    `Cumulative hazard` = character(nrow(df)),
    `NA Survival`       = character(nrow(df))
  )

  for (i in seq_len(nrow(df))) {
    ni <- as.integer(df$n_risk[i])
    di <- as.integer(df$deaths[i])

    inc_str <- if (di == 0L) {
      sprintf("$\\frac{0}{%d} = 0$", ni)
    } else {
      sprintf("$\\frac{%d}{%d}$", di, ni)
    }

    prev_cum_haz_str <- cum_haz_str

    if (di > 0L) {
      new_num   <- cum_haz_n * ni + di * cum_haz_d
      new_den   <- cum_haz_d * ni
      g         <- gcd_fn(new_num, new_den)
      cum_haz_n <- new_num %/% g
      cum_haz_d <- new_den %/% g

      cum_haz_str <- if (cum_haz_d == 1) {
        sprintf("%.0f", cum_haz_n)
      } else {
        sprintf("\\frac{%.0f}{%.0f}", cum_haz_n, cum_haz_d)
      }

      cum_haz_cell <- sprintf(
        "$%s + \\frac{%d}{%d} = %s$",
        prev_cum_haz_str, di, ni, cum_haz_str
      )
    } else {
      cum_haz_cell <- sprintf("$%s$", cum_haz_str)
    }

    surv_val  <- exp(-cum_haz_n / cum_haz_d)
    surv_cell <- sprintf(
      "$\\expf{-%s} \\approx %s$",
      cum_haz_str,
      fmt_dec(surv_val)
    )

    tbl$`Time-point`[i]        <- df$time[i]
    tbl$`Risk set`[i]          <- ni
    tbl$`Hazard increment`[i]  <- inc_str
    tbl$`Cumulative hazard`[i] <- cum_haz_cell
    tbl$`NA Survival`[i]       <- surv_cell
  }

  knitr::kable(tbl, escape = FALSE)
}
