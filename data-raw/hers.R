# https://regression.ucsf.edu/sites/g/files/tkssra16191/files/wysiwyg/home/data/hersdata.dta
hers <- haven::read_dta(fs::path_package("rme", "extdata/hersdata.dta"))

hers |> readr::write_rds("inst/extdata/hers.rds")

usethis::use_data(hers, overwrite = TRUE)
