library(dplyr)
library(DatawRappr)

if (length(Sys.getenv("DW_KEY"))) {

  args <- commandArgs(trailingOnly = TRUE)

  reference <- read.csv("./reference_output.csv")
  data <- read.csv("./data/data.csv")



  for (i in 1:nrow(reference)) {
    filtered <- filter(data, series_id == reference[i,]$series_id)

    print(filtered)

    dw_data_to_chart(filtered, reference[i,]$chart_id)

    published <- dw_publish_chart(reference[i,]$chart_id, return_object = TRUE)

    message('Chart republished to ', published$publicUrl)

  }



} else {
  message('Datawrapper token not set. Set by running datawrapper_auth(api_key = "12345678")')
}
