library(googlesheets4)
library(dplyr)
library(readr)

# gs4_auth()
args <- commandArgs(trailingOnly = TRUE)

url <- args[1]

sheet_names <- sheet_names(url)

data_list <- list()

for (name in sheet_names) {
  if (!name %in% c("meta", "raw")) {
    sheet <- read_sheet(url, name)
    
    sheet <- sheet %>% 
      mutate(series_id = name) %>% 
      select(series_id, everything())
    
    data_list[[length(data_list) + 1]] <- sheet
  }
}

df <- bind_rows(data_list)

write_csv(df, "data/data.csv")
