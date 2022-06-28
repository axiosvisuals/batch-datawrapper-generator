library(dplyr)
library(DatawRappr)

if (length(Sys.getenv("DW_KEY"))) {

  args <- commandArgs(trailingOnly = TRUE)

  reference <- read.csv(args[1])

  for (i in 1:nrow(reference)) {
    dw_delete_chart(reference[i,]$chart_id)
  }



} else {
  message('Datawrapper token not set. Set by running datawrapper_auth(api_key = "12345678")')
}
