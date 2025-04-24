# define snake_case with uppercase acronyms allowed;
# see https://github.com/r-lib/lintr/issues/2844 for details:
withr::local_package("rex")
snake_case_ACROs1 <- rex::rex(
  start,
  maybe("."),
  list(some_of(upper), maybe("s"), zero_or_more(digit)) %or% list(some_of(lower), zero_or_more(digit)),
  zero_or_more(
    "_",
    list(some_of(upper), maybe("s"), zero_or_more(digit)) %or% list(some_of(lower), zero_or_more(digit))
  ),
  end
)

linters <- lintr::linters_with_defaults(
  return_linter = NULL,
  trailing_whitespace_linter = NULL,
  lintr::pipe_consistency_linter(pipe = "|>"),
  lintr::object_name_linter(
    regexes = c(snake_case_ACROs1 = snake_case_ACROs1)
  )
)

# prevent warnings from lintr::read_settings:
rm(snake_case_ACROs1)
exclusions <- list(
  `data-raw` = list(
    pipe_consistency_linter = Inf
  )
)
