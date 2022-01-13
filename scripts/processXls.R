library(dplyr)
library(readxl)
library(readr)

path <- list.files(path="data/raw/", pattern="*.xlsx", full.names=TRUE, recursive=FALSE)
sheet_names <- excel_sheets(path)

data_list <- list()

for (name in sheet_names) {
  if (!name %in% c("meta", "raw")) {
    sheet <- read_excel(path, name)
    
    sheet <- sheet %>% 
      mutate(series_id = name) %>% 
      select(series_id, everything())
    
    data_list[[length(data_list) + 1]] <- sheet
  }
}

df <- bind_rows(data_list)

write_csv(df, "data/data.csv")
