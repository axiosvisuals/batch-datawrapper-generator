library(googledrive)
library(googlesheets4)
library(dplyr)
library(readr)

fullpath = getwd()
directoryname = basename(fullpath)

reference_df <- read_csv("reference_output.csv")

sheet <- gs4_create(
  name=directoryname,
  sheets=reference_df
  )

meta <- gs4_get(sheet)

reference_folder <- "1FtlzowesJ-uuOdVKqf2BeFCuwrRbEnah"

drive_mv(
  file=as_id(meta$spreadsheet_id),
  path = as_id(reference_folder),
  overwrite = TRUE
)

message('Reference Google Sheet: ', drive_link(sheet))

