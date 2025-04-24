# define snake_case with uppercase acronyms allowed;
# see https://github.com/r-lib/lintr/issues/2844 for details:
withr::local_package("rex")
snake_case_ACROs <- rex::rex(
  start,
  maybe("."),
  some_of(lower, upper, digit),
  zero_or_more(
    "_",
    some_of(lower, upper, digit)
  ),
  end
)

linters <- lintr::linters_with_defaults(
  return_linter = NULL,
  trailing_whitespace_linter = NULL,
  lintr::pipe_consistency_linter(pipe = "|>"),
  lintr::object_name_linter(
    regexes = c(snake_case_ACROs = snake_case_ACROs)
  )
)

# prevent warnings from lintr::read_settings:
rm(snake_case_ACROs)
exclusions <- list(
  `data-raw` = list(
    pipe_consistency_linter = Inf
  )
)
