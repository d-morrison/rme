# define snake_case with uppercase acronyms allowed;
# see https://github.com/r-lib/lintr/issues/2844 for details:
withr::local_package("rex")
snake_case_ACRO <- rex::rex(
  start,
  rex::maybe("."),
  rex::some_of(lower, digit) %or%
    rex::some_of(upper, digit),
  rex::zero_or_more(
    "_",
    rex::some_of(lower, digit) %or%
      rex::some_of(upper, digit)
  ),
  end
)

linters <- lintr::linters_with_defaults(
  return_linter = NULL,
  trailing_whitespace_linter = NULL,
  lintr::pipe_consistency_linter(pipe = "|>"),
  lintr::object_name_linter(
    regexes = c(snake_case_ACRO = snake_case_ACRO)
  )
)

# prevent warnings from lintr::read_settings:
rm(snake_case_ACRO)
exclusions <- list(
  `data-raw` = list(
    pipe_consistency_linter = Inf
  )
)
