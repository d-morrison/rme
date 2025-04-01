# Contributing to `rme`

Contributions to these notes are very much appreciated; anything from
one-character typo corrections to new chapters or rewrites. 
The [GitHub repository for this project](https://github.com/d-morrison/rme)
provides a Pull Request system for submitting contributions. 
See <https://happygitwithr.com/pr-extend> for an explanation of the pull request system
and the available R utility functions for working with pull requests.

## Style guide

- Every abstract concept (definition or theorem) should have at least one concrete example immediately following it.

- More structure (headers, labels) is better.

- Make each conceptual chunk as compact as possible:
  - Decompose large, complicated, difficult concepts into smaller, simpler, and easier pieces.
  - Decompose long derivations into smaller lemmas.
  - When manipulating part of a larger expression, isolate that part in a lemma.
  

## Fixing typos

This book is written using [Quarto](https://quarto.org/docs/books/).
You can fix typos, spelling mistakes, or grammatical errors directly using the GitHub web interface by making changes in the corresponding *source* file. 
This generally means you'll need to edit a `.qmd` file. 


## Bigger changes

If you want to make a bigger change, it's a good idea to first file an issue and make sure someone from the development team agrees that it’s needed. 

### [Pull request](https://usethis.r-lib.org/articles/pr-functions.html#whats-a-pull-request) process

*   Fork the package and clone onto your computer. If you haven't done this before, we recommend using `usethis::create_from_github("d-morrison/rme", fork = TRUE)`.

*   Install all development dependencies with `devtools::install_dev_deps()`. Make sure you can build the book by running `quarto render` in a Terminal.

*   Create a Git branch for your pull request (PR). 
We recommend using `usethis::pr_init("brief-description-of-change")`. 
Details at <https://usethis.r-lib.org/articles/pr-functions.html>

*   Make your changes, commit to git, and then create a PR by running `usethis::pr_push()`, and following the prompts in your browser.
    The title of your PR should briefly describe the change.
    The body of your PR should contain `Fixes #issue-number`.

*  Add a bullet to the top of `NEWS.md` (i.e. just below the first header). Follow the style described in <https://style.tidyverse.org/news.html>.

### Code style

*   New code should follow the tidyverse [style guide](https://style.tidyverse.org). 
    You can use the [styler](https://CRAN.R-project.org/package=styler) package to apply these styles, but please don't restyle code that has nothing to do with your PR.  

## Code of Conduct

Please note that the `rme` project is released with a
[Contributor Code of Conduct](CODE_OF_CONDUCT.md). By contributing to this
project you agree to abide by its terms.

## Additional references

For a detailed discussion on contributing to this and other projects, 
please see the [Tidyverse development contributing guide](https://rstd.io/tidy-contrib) 
and the [Tidyverse code review principles](https://code-review.tidyverse.org/). 
This project is not part of the tidyverse, but we have borrowed their development processes.
