library(dplyr)
library(DatawRappr)

axios_visuals_id <- "xMwlyuwN"

deployChart <- function(series_id, basemap_id) {
  
  base_meta <- dw_retrieve_chart_metadata(base_chart_id)

  chart_hed = gsub("%series_id%", series_id, base_meta$content$title)
  chart_dek = gsub("%series_id%", series_id, base_meta$content$metadata$describe$intro)

  chart <- dw_copy_chart(base_chart_id)
  system(paste("./moveFile.sh", chart$id, group_folder_id, Sys.getenv("DW_KEY"), sep=" "))

  if (basemap_id %in% dw_basemaps$id) {
    dw_edit_chart(
      chart$id,
      title = chart_hed,
      intro = chart_dek,
      visualize = list(
        basemap = basemap_id
      )
    )
  } else {
    dw_edit_chart(
      chart$id,
      title = chart_hed,
      intro = chart_dek
    )
    system(paste("./updateCustomJSON.sh", chart$id, basemap_id, Sys.getenv("DW_KEY"), sep=" "))
  }

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
  
  data <- read.csv(args[2])
  
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

  reference_list <- list()
  
  locals <- read.csv(args[2])
  print(locals)
  
  for (i in 1:nrow(locals)) {
    
    row <- deployChart(
      series_id = locals[i,]$series_id,
      basemap_id = locals[i,]$basemap_id
    )
    
    reference_list[[length(reference_list) + 1]] <- row
  }
  
  reference_df <- bind_rows(reference_list)
  
  write.csv(reference_df, "reference_output.csv", row.names=FALSE)
  
} else {
  message('Datawrapper token not set. Set by running datawrapper_auth(api_key = "12345678")')
}


