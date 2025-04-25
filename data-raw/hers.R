hers = haven::read_dta("https://regression.ucsf.edu/sites/g/files/tkssra6706/f/wysiwyg/home/data/hersdata.dta")

hers |> readr::write_rds("inst/extdata/hers.rds")

usethis::use_data(hers, overwrite = TRUE)
