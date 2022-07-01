# batch-datawrapper-generator

This repository contains R scripts for batch chart and map creation using the Datawrapper API via the `DatawRappr` package, as well as a Bash script wrapper. While the API does support generating a chart or map from scratch, this workflow assumes you are duplicating an existing chart already created in Datawrapper. There are two CSV files within the `data` folder that should be edited depending on the type of chart you are making.

A complete list of [DatawRappr functions can be found here](https://munichrocker.github.io/DatawRappr/reference/index.html).

## Requirements

- R
-  `DatawRappr` ,  `dplyr`, `readr`, `googledrive`, `googlesheets4`
- A [Datwrapper API-token](https://app.datawrapper.de/account/api-tokens)
- The ID of the chart you are duplicating

## Getting started

### For Axions
Copy this repo using the `new-project-shell` [script](https://github.com/axiosvisuals/new-project-shell).

### For everyone else, use degit

`degit` is a package that makes copies of a git repository's most recent commit. This allows for generating the scaffolding from this template directly from the command line.

If this is a private repository, you'll need to set up SSH keys with your Github account. More information on how to do that [here](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent).

To install degit: `npm install -g degit`

To create a new project based on this template using [degit](https://github.com/Rich-Harris/degit):

```bash
npx degit axiosvisuals/batch-datawrapper-generator --mode=git project-name
cd project-name
```
### Google authorization set-up

The first time you use `googledrive` and `googlesheets4` you will need to authorize the package to access your Axios Google account.

Start an R session in RStudio and run

```R
library(googledrive)
library(googlesheets4)
drive_auth()
gs4_auth()
```
You will be directed to a web browser, asked to sign in to your Google account, and to grant libraries permission to operate on your behalf with Google Drive and Google Sheets. Check the "See, edit, create, and delete" permission and click Continue to authorize. You may need to restart any existing R sessions for the authorization to take place.

### API token set-up

The first time you use `DatawRappr` you will need to authenticate your API token. Start an R session either in RStudio. Copy the API token [created in Datawrapper](https://app.datawrapper.de/account/api-tokens) and run

```R
# install.packages("devtools") # if not already installed on your system
devtools::install_github("munichrocker/DatawRappr")
library(DatawRappr)
datawrapper_auth(api_key = "TOKEN")
```

to save the key to your `.Renviron` file. If a key already exists, you may add the argument `overwrite = TRUE ` to `datawrapper_auth()`.

To make sure, your key is working as expected, you can run

```R
dw_test_key()
```

### `.Renviron` set-up

Along with Datawrapper and Drive authorization, there are two environmental variables that need to be set in your machine's `.Renviron` file.

| Name                   | Description                                                           | Example                           |
|------------------------|-----------------------------------------------------------------------|-----------------------------------|
| `DW_ORGANIZATION_ID`     | Alphanumeric ID of your team's Datawrapper account                    | `xMwlyuwN`                          |
| `DRIVE_REFERENCE_FOLDER_ID` | Google Drive ID of the Drive folder where reference sheets are stored | `1FtlzowesJ-uuOdVKqf2BeFCuwrRbEnah` |


## Running the scripts

To source any of the R scripts, run `./batch.sh` and follow the prompts. Continue reading for instructions on how to use each script. After your batch is run, a reference sheet with the links to each chart is created and [uploaded to Google Drive](https://drive.google.com/drive/folders/1FtlzowesJ-uuOdVKqf2BeFCuwrRbEnah). The link to this Google Sheet will be printed to the terminal.

### Axios Demo

You can test out the script with the included dummy data. This will duplicate a template chart in the `Axios Visuals/dw auto test/` folder in Datawrapper (assuming it wasn't accidentally deleted), update the new charts with the dummy data, and place them in the testing folder.

- Copy the repo using the `new-project-shell` [script](https://github.com/axiosvisuals/new-project-shell) or with degit
  - ```
    npx degit axiosvisuals/batch-datawrapper-generator --mode=git project-name
    cd project-name`
    ```
- Run `./batch.sh`
- Select `downloadSheet.R`
- Pass the `1Z7ZWw21AFx_hJvl1K7ukyGovj1x6FLeENVnOSn3m8bI` for the demo sheet ID and hit enter; The demo data should now be in `data/data,csv`
- Run `./batch.sh`
- Select `makeChartsFromBase.R`
- Pass `mnX0x` for the base chart ID
- Pass `76624` for the folder ID
- View results on [Datawrapper](https://app.datawrapper.de/archive/team/xMwlyuwN/76624)
- View the reference sheet with published URLs [on the Google Drive](https://drive.google.com/drive/folders/1FtlzowesJ-uuOdVKqf2BeFCuwrRbEnah)
- To update the charts after modifying the data file, run `./batch.sh` and select `updateChartsInReference.R`
- To delete the charts, run `./batch.sh` and select `deleteChartsInReference.R`

### Charts | `makeChartsFromBase.R`

##### Preparing your data

Your data should be formatted the same way as the data in your base chart with the addition of a `series_id` field. This value indicates the group – most likely a local – the row belongs to. The script uses the `series_id` value to split the dataset into chunks.

| series_id | Label    | Men  | Women |
| --------- | -------- | ---- | ----- |
| Group A   | Agree    | 1653 | 858   |
| Group A   | Disagree | 559  | 407   |
| Group B   | Agree    | 819  | 1857  |
| Group B   | Disagree | 815  | 1883  |
| Group C   | Agree    | 1507 | 394   |
| Group C   | Disagree | 266  | 1030  |

After preparing your data, save it to `data/data.csv`.

Alternatively, data can be inputted for each series individually using either the [city](https://docs.google.com/spreadsheets/d/1sbAGPCY73Hxa3tQhoALMqbFvats9YxuSnLgRGlsxNBE/edit#gid=0) or [state](https://docs.google.com/spreadsheets/d/1y5dzvUFt_esSur820MTSp72-lp3IcGCIkou1p1-3ew0/edit#gid=0) Google Sheet template. Once complete, run `./batch.sh` and select `downloadSheet.R`. This will download and compile the sheets into a single table, prepend the `series_id` using the sheet name, and save it to `data/data.csv` to be used in `makeChartsFromBase.R`. **Note: This workflow is intended for when reporters are filling out their local's data sheet individually. If working from a national file, manually isolating the data, assigning the `series_id`, and saving it as a single spreadsheet to `data/data.csv` is the preferred method.**

##### Preparing your base graphic

Copied charts retain any style and textual information, so make sure your base graphic looks the way you want your published versions to appear. If you need to dynamically change the styles of a graphic, add additional arguments to `dw_edit_chart()`  within `deployChart()`.

Using the `series_id` value, the name of the group can be inserted in the graphic's hed and dek. Use `%series_id%` to indicate where it should be inserted.

![alt text](https://user-images.githubusercontent.com/15233857/136981359-a43005e8-b41d-414a-922c-b15af6b9987b.png)

### Choropleth maps | `makeChoroplethMapsFromBase.R`

If you are creating zoomed in versions of a national map, an efficient method is to include the entire national dataset in your base graphic and then instead of updating the data, simply change the basemap ID. While every duplicated map will contain the entire dataset, it will only render those with matching FIPS codes.

##### Preparing your data

Make a table containing the `series_id` and truncated `basemap_id` for each local. The geography level of the template will be used. Note, county or smaller geography must be used.

Paste your data into `data/locals.csv`.

##### Preparing your base graphic

Make a basemap using the boundary type (state, county, etc.) you want to use in the batched versions. Upload your data and stylize the choropleth and popups.

Copied charts retain any style and textual information, so make sure your base graphic looks the way you want your published versions to appear. If you need to dynamically change the styles of a graphic, add additional arguments to `dw_edit_chart()`  within `deployChart()`.

Using the `series_id` value, the name of the group can be inserted in the graphic's hed and dek. Use `%series_id%` to indicate where it should be inserted.

When running the script, you wil be prompted to add city names to your map. If selected, the city labels will be copied from a [template map](https://app.datawrapper.de/map/4b6fj/visualize#refine) and applied to your batch. You may need to manually delete floating city names of bordering states afterwards (this is a DW bug). If you think a new city should be added, [edit the template](https://app.datawrapper.de/map/4b6fj/visualize#refine).

### Symbol maps | `makeSymbolMapsFromBase.R`

The symbol map workflow is a combination of the chart and choropleth workflows. You will still be cloning a national map and updating the `basemap_id`, but in order to prevent points from overflowing beyond your target region, you will also insert the subsetted data into it it.

##### Preparing your data

You will need to edit both `data/data.csv` and `data/locals.csv`. `data.csv` follows the same format used in `makeChartsFromBase.R` with the addition of latitude and longitude columns. `locals.csv` follows the same format used in `makeChoroplethMapsFromBase.R`.

##### Preparing your base graphic

Make a basemap using the boundary type (state, county, etc.) you want to use in the batched versions. Upload a sample of your data to set up the variable schema and give you points to stylize.

Copied charts retain any style and textual information, so make sure your base graphic looks the way you want your published versions to appear. If you need to dynamically change the styles of a graphic, add additional arguments to `dw_edit_chart()`  within `deployChart()`.

Using the `series_id` value, the name of the group can be inserted in the graphic's hed and dek. Use `%series_id%` to indicate where it should be inserted.

When running the script, you wil be prompted to add city names to your map. If selected, the city labels will be copied from a [template map](https://app.datawrapper.de/map/4b6fj/visualize#refine) and applied to your batch. You may need to manually delete floating city names of bordering states afterwards (this is a DW bug). If you think a new city should be added, [edit the template](https://app.datawrapper.de/map/4b6fj/visualize#refine).


## Additional scripts


##### downloadSheet.R

Prompts for an Axios [Google Sheet template](https://drive.google.com/drive/u/0/folders/15AInhBKCbwznQ-sEUZpu_3tqwVYElaZk) url or ID, downloads the data from each tab, merges it into a single table and saves it to `data/data.csv`.

***

##### publishReferenceSheet.R

Publishes `reference_output.csv` to [Google Drive](https://drive.google.com/drive/u/0/folders/1FtlzowesJ-uuOdVKqf2BeFCuwrRbEnah). This is automatically run at the end of each generator

***

##### updateChartsInReference.R

Replaces the data of charts referenced in `reference_output.csv` with the data in `data/data.csv`.

***

##### deleteChartsInReference.R

Delets charts referenced in `reference_output.csv`.
