source("renv/activate.R")

if (interactive()) {
  require(usethis)
  require(devtools)
}

# Give headless Chrome more time to open its debugging port when `webshot2`
# screenshots the interactive `plotly` figures during the PDF book build.
# The chromote default waits only 10 seconds, which intermittently times out
# under CI load ("Chrome debugging port not open after 10 seconds").
options(chromote.timeout = 60)
