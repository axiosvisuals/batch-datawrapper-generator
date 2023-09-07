library(dplyr)
library(readr)
library(DatawRappr)

# Primary function that gets called for each individual chart
deployChart <- function(chart_data, series_id) {

  # Get the data from your template chart
  base_meta <- dw_retrieve_chart_metadata(base_chart_id)

  # Build the hed and dek based off of your `%series_id%` value. This templating
  # convention can be used with any other variable.
  chart_hed = gsub("%series_id%", series_id, base_meta$content$title)
  chart_dek = gsub("%series_id%", series_id, base_meta$content$metadata$describe$intro)

  # Make a new chart and move it to the right folder in the DW web app
  chart <- dw_copy_chart(base_chart_id)
  system(paste("./scripts/moveFile.sh", chart$id, group_folder_id, Sys.getenv("DW_KEY"), sep=" "))

  # Update the the new chart with the series data
  dw_data_to_chart(chart_data, chart$id)

  # Make additional updates including hed, dek, and alt text. Additional changes can be made here using
  # the various API endpoints.
  dw_edit_chart(
    chart$id,
    title = chart_hed,
    intro = chart_dek,
    describe = list(
      "aria-description" = gsub("%series_id%", series_id, base_meta$content$metadata$describe$`aria-description`)
    )
  )

  # Publish the chart and return an object
  published <- dw_publish_chart(chart$id, return_object = TRUE)

  # Use the new published object to build a reference row
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
  
  # Make args list from arguments passed to script
  args <- commandArgs(trailingOnly = TRUE)
  
  # Get the ID of the template
  base_chart_id <- args[1]

  # Read in the batch data
  data <- read_csv(args[2])

  # Check to see if a folder name or ID was provided
  if (length(args)>2) {
    # Either create a new folder or reference an existing one
    if (grepl("\\D", args[3])) {
      group_name <- args[3]
      group_folder_id <- dw_create_folder(
        name=group_name,
        organization_id=Sys.getenv('DW_ORGANIZATION_ID')
      )
    } else {
      group_name <- ""
      group_folder_id <- args[3]
    }
  }

  # Split the data by series_id
  data_list <- group_split(data,
                           series_id,
                           .keep = TRUE)

  # Create new list to store reference data
  reference_list <- list()

  # Loop over each df split by series_id
  for (df in data_list) {

    # Get the ID of the series
    series_id <- df[1,]$series_id
    
    # Pass the data and ID to the primary function
    row <- deployChart(
      chart_data = select(df, -series_id),
      series_id
    )

    # Add the returned row to the reference list
    reference_list[[length(reference_list) + 1]] <- row
  }

  # Bind all the reference rows together
  reference_df <- bind_rows(reference_list)

  # Export the reference data as a CSV
  write_csv(reference_df, "reference_output.csv")

} else {
  message('Datawrapper token not set. Set by running datawrapper_auth(api_key = "12345678")')
}
