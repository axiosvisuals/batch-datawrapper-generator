library(dplyr)
library(readr)
library(DatawRappr)


args <- commandArgs(trailingOnly = TRUE)

places_meta <- dw_retrieve_chart_metadata('4b6fj')
places <- places_meta$content$metadata$visualize$labels$places
includeLabels <- if (tolower(args[3]) %in% c("y", "yes", "true")) "true" else FALSE





deployChart <- function(chart_data, series_id, basemap_geography_id) {

  base_meta <- dw_retrieve_chart_metadata(base_chart_id)

  chart_hed = gsub("%series_id%", series_id, base_meta$content$title)
  chart_dek = gsub("%series_id%", series_id, base_meta$content$metadata$describe$intro)

  chart <- dw_copy_chart(base_chart_id)
  system(paste("./scripts/moveFile.sh", chart$id, group_folder_id, Sys.getenv("DW_KEY"), sep=" "))

  # basemap
  levels <- c("counties",
              "municipalities",
              "postcode",
              "census-2020")


  basemap_level_id <- levels[which(sapply(levels, grepl, base_meta$content$metadata$visualize$basemap))]

  basemap_id <- paste0(basemap_geography_id, '-', basemap_level_id)

  message(paste0("\n\nUsing ", basemap_id))


  if (basemap_id %in% dw_basemaps$id) {
    dw_edit_chart(
      chart$id,
      title = chart_hed,
      intro = chart_dek,
      visualize = list(
        basemap = basemap_id,
        labels = list(
          enabled = includeLabels,
          places = places
        )
      )
    )
  } else {
    dw_edit_chart(
      chart$id,
      title = chart_hed,
      intro = chart_dek
    )
    system(paste("./scripts/updateCustomJSON.sh", chart$id, basemap_geography_id, Sys.getenv("DW_KEY"), sep=" "))
  }

  dw_data_to_chart(chart_data, chart$id,)

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

  base_chart_id <- args[1]

  if (length(args)>2) {
    if (grepl("\\D", args[2])) {
      group_name <- args[2]
      group_folder_id <- dw_create_folder(
        name=group_name,
        organization_id=Sys.getenv('DW_ORGANIZATION_ID')
      )
    } else {
      group_name <- ""
      group_folder_id <- args[2]
    }
  }


  reference_list <- list()

  data <- read_csv("./data/data.csv")
  locals <- read_csv("./data/locals.csv")

  for (i in 1:nrow(locals)) {

    series_id <- locals[i,]$series_id
    chart_data <- filter(data, series_id == locals[i,]$series_id)
    row <- deployChart(
      chart_data = chart_data,
      series_id = series_id,
      basemap_geography_id = locals[i,]$basemap_geography_id
    )

    reference_list[[length(reference_list) + 1]] <- row
  }

  reference_df <- bind_rows(reference_list)

  write_csv(reference_df, "reference_output.csv")

} else {
  message('Datawrapper token not set. Set by running datawrapper_auth(api_key = "12345678")')
}
