library(dplyr)
library(readr)
library(DatawRappr)

axios_visuals_id <- "xMwlyuwN"

deployChart <- function(chart_data, series_id) {
  
  base_meta <- dw_retrieve_chart_metadata(base_chart_id)
  
  chart_hed = gsub("%series_id%", series_id, base_meta$content$title)
  chart_dek = gsub("%series_id%", series_id, base_meta$content$metadata$describe$intro)
  
  chart <- dw_copy_chart(base_chart_id)
  system(paste("./scripts/moveFile.sh", chart$id, group_folder_id, Sys.getenv("DW_KEY"), sep=" "))
    
  
  dw_data_to_chart(chart_data, chart$id)
  
  dw_edit_chart(
    chart$id,
    title = chart_hed,
    intro = chart_dek
  )
  
  published <- dw_publish_chart(chart$id, return_object = TRUE)
  
  row <- data.frame(
    series_id = series_id,
    chart_id = chart$id,
    public_url = published$publicUrl,
    public_png = paste('https://datawrapper.dwcdn.net/', chart$id,'/social.png', sep='')
  )
  
  message('Chart published to ', published$publicUrl)
  
  return(row)
}

if (length(Sys.getenv("DW_KEY"))) {

  args <- commandArgs(trailingOnly = TRUE)
  
  base_chart_id <- args[1]
  
  data <- read_csv(args[2])
  
  if (length(args)>2) {
    if (grepl("\\D", args[3])) {
      group_name <- args[3]
      group_folder_id <- dw_create_folder(
        name=group_name,
        organization_id=axios_visuals_id
      )
    } else {
      group_name <- "" 
      group_folder_id <- args[3]
    }    
  }

  data_list <- group_split(data,
                           series_id,
                           .keep = TRUE)
  
  reference_list <- list()
  
  for (df in data_list) {
    
    series_id <- df[1,]$series_id
    row <- deployChart(
      chart_data = df,
      series_id
    )
    
    reference_list[[length(reference_list) + 1]] <- row
  }
  
  reference_df <- bind_rows(reference_list)

  write_csv(reference_df, "reference_output.csv", row.names=FALSE)
  
} else {
  message('Datawrapper token not set. Set by running datawrapper_auth(api_key = "12345678")')
}


