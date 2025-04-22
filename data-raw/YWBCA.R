library(haven)
conflicts_prefer(haven::read_sas)
ywbca0 = read_sas("inst/extdata/YWBCA/ywbca.sas7bdat")


# :::{.callout-tip}
#
# You may find the `haven::read_sas()` function helpful for loading the data file.
#
# I don't know of an easy way to automate the data formatting using the `YWBCA Formats.sas` file, so you might need to open it in Microsoft Word or another text editor
#
# :::

ywbca = ywbca0 |>
  mutate(
    R57 =
      R57 |>
        case_match(
          1 ~ '0',
          2 ~ '1-2',
          3 ~ '3-5',
          4 ~ '6-9',
          5 ~ '10+'
        ),

    R58 = R58 |>
      case_match(
        1 ~ 'More',
        2 ~ 'Fewer',
        3 ~ 'Same'
      ),

    TUMORMK1 = TUMORMK1 |>
      case_match(
        1 ~ "positive",
        2 ~ "negative",
        c(0,3,8,9) ~ "unknown"
      ),
    RACE5 = RACE5 |>
      case_match(
        0 ~ 'White',
        1 ~ 'Black',
        2 ~ 'Latina',
        3 ~ 'Asian',
        4 ~ 'Others'
      ),
    MARITAL = MARITAL |>
      case_match(
        1 ~ 'married/partner',
        0 ~ 'single'
      ),

    surg_rad = surg_rad |>
      case_match(
        3 ~ "Mast & radn",
        2 ~ "Mast no radn",
        1 ~ "Lump & radn",
        0 ~ "Lump no radn"),

    EDUC = EDUC |>
      case_match(
        1 ~ '<HS',
        0 ~ '>HS'
      ),

    across(c(MOREFRND:FEWFRND, EMPLOY:HORM1), as.logical),

    vital1 = vital1 |>
      case_match(
        1 ~ "Alive (Censored)",
        0 ~ "Deceased"
      )

  )

if(!all(names(ywbca0) == names(ywbca))) stop('why?')

library(labelled)
var_label(ywbca) = var_label(ywbca0)[names(ywbca)]


usethis::use_data(ywbca, overwrite = TRUE)

ywbca |> readr::write_rds("inst/extdata/ywbca.rds")
