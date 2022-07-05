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

fileId <- meta$spreadsheet_id

drive_mv(
  file=as_id(url),
  path = as_id(Sys.getenv('DRIVE_REFERENCE_FOLDER_ID')),
  overwrite = TRUE
)

drive_publish(as_id(fileId))

drive_share(as_id(fileId),
            role="reader",
            type="anyone"
)


message('Reference Google Sheet: ', drive_link(sheet))

message('Batch preview link: https://visuals.axioscode.tools/batch-previewer#',  paste0(fileId))



