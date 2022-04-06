# batch-datawrapper-generator

This repository contains R scripts for batch chart and map creation using the Datawrapper API via the `DatawRappr` package, as well as a Bash script wrapper. While the API does support generating a chart or map from scratch, this workflow assumes you are duplicating an exisiting chart already created in Datawrapper.

A complete list of [DatawRappr functions can be found here](https://munichrocker.github.io/DatawRappr/reference/index.html).

## Requirements

- R
-  `DatawRappr` ,  `dplyr`, `readr`, `googledrive`, `googlesheets4`
- A [Datwrapper API-token](https://app.datawrapper.de/account/api-tokens)
- The ID of the chart you are duplicating

## Getting started

Copy this repo using the `new-project-shell` [script](https://github.com/axiosvisuals/new-project-shell) or with degit. There are two CSV files within the `data` folder that should be edited depending on the type of chart you are making.

### Using degit

`degit` is a package that makes copies of a git repository's most recent commit. This allows for generating the scaffolding from this template directly from the command line.

Since this is a private repository, you'll need to set up SSH keys with your Github account. More information on how to do that [here](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent).

To install degit: `npm install -g degit`

To create a new project based on this template using [degit](https://github.com/Rich-Harris/degit):

```bash
npx degit axiosvisuals/batch-datawrapper-generator --mode=git project-name
cd project-name
```
### Google authorization set-up

The first time you use `googledrive` and `googlesheets4` you will need to authorize the package to access your Axios Google account.

Start an R session either in RStudio and run

```R
library(googledrive)
library(googlesheets4)
drive_auth()
gs4_auth()
```
You will be directed to a web browser, asked to sign in to your Google account, and to grant libraries permission to operate on your behalf with Google Drive and Google Sheets. Check the "See, edit, create, and delete" permission and click Continue to authorize.

### API token set-up

The first time you use `DatawRappr` you will need to autheniticate your API token. Start an R session either in the terminal or RStudio. Copy the API token [created in Datawrapper]() and use

```R
library(DatawRappr)
datawrapper_auth(api_key = "TOKEN")
```

to save the key to your `.Renviron` file. If a key already exists, you may add the argument `overwrite = TRUE ` to `datawrapper_auth()`.

To make sure, your key is working as expected, you can run

```R
dw_test_key()
```

## Running the scripts

Run `./batch.sh` and follow the prompts. Continue reading for instructions on how to use each script. After your batch is run, a reference sheet with the links to each chart is created and [uploaded to Google Drive](https://drive.google.com/drive/folders/1FtlzowesJ-uuOdVKqf2BeFCuwrRbEnah). The link to this Google Sheet will be printed to the terminal.

### Demo

You can test out the script with the included dummy data. This will duplicate a template chart in the `Axios Visuals/dw auto test/` folder in Datawrapper (assuming it wasn't accidentally deleted), update the new charts with the dummy data, and place them in the testing folder.

- Copy the repo using the `new-project-shell` [script](https://github.com/axiosvisuals/new-project-shell) or with degit
  - ```
    npx degit axiosvisuals/batch-datawrapper-generator --mode=git project-name
    cd project-name`
    ```
- Run `./batch.sh`
- Select `downloadSheet.R`
- Pass the `1T_e-UDNy8hAU35ucua3xxJsoeQh5RPjxtoafclR9mpU` for the demo sheet ID and hit enter; The demo data should now be in `data/data,csv`
- Run `./batch.sh`
- Select `makeChartsFromBase.R`
- Pass `mnX0x` for the base chart ID
- Pass `76624` for the folder ID
- View results on [Datawrapper](https://app.datawrapper.de/archive/team/xMwlyuwN/76624)
- View the reference sheet with published URLs [on the Google Drive](https://docs.google.com/spreadsheets/d/1g69B4ialN9ylJspAKVzIIct7o9xYSIWEni8E6NNYg3I/edit#gid=2127911916)
- To delete the charts, run `./batch.sh` and select `deleteChartsInReference.R`

### For charts

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

If working from a national file, isolate your data and paste into `data/data.csv`.

If local reporters are filling out the data, clone and use either the [city](https://docs.google.com/spreadsheets/d/1sbAGPCY73Hxa3tQhoALMqbFvats9YxuSnLgRGlsxNBE/edit#gid=0) or [state](https://docs.google.com/spreadsheets/d/1y5dzvUFt_esSur820MTSp72-lp3IcGCIkou1p1-3ew0/edit#gid=0) Google Sheet template. Once complete, run `./batch.sh` and select `downloadSheet.R`. This will download and compile tne sheets into a single table, prepend the `series_id` using the sheet name, and save it to `data/data.csv` to be used in `makeChartsFromBase.R`

##### Preparing your base graphic

Copied charts retain any style and textual information, so make sure your base graphic looks the way you want your published versions to appear. If you need to dynamically change the styles of a graphic, add additional arguments to `dw_edit_chart()`  within `deployChart()`.

Using the `series_id` value, the name of the group can be inserted in the graphic's hed and dek. Use `%series_id%` to indicate where it should be inserted.

![alt text](https://user-images.githubusercontent.com/15233857/136981359-a43005e8-b41d-414a-922c-b15af6b9987b.png)

### For maps

If you are creating zoomed in versions of a national map, an efficient method is to include the entire national dataset in your base graphic and then instead of updating the data, simply change the basemap ID. While every duplicated map will contain the entire dataset, it will only render those with matching FIPS codes.

##### Preparing your data

Make a table containing the `series_id` and `basemap_id` for each local. An example at the county level can be found at `data/locals.csv`. To get a table of the basemaps available in Datawrapper, run `dw_basemaps`.

If you need to make a map containing a custom geography, replace `basemap_id` with the chart id of an existing Datawrapper map. The script will then download the custom geojson of the existing map and upload it to the new one. Due to limitations with `DatawRappr`, this process is handled by `updateCustomJSON.sh`. It is possible to upload new geojson files directly with minor modifications to the `updateCustomJSON.sh`.

Paste your data into `data/locals.csv`.

##### Preparing your base graphic

Copied charts retain any style and textual information, so make sure your base graphic looks the way you want your published versions to appear. If you need to dynamically change the styles of a graphic, add additional arguments to `dw_edit_chart()`  within `deployChart()`.

Using the `series_id` value, the name of the group can be inserted in the graphic's hed and dek. Use `%series_id%` to indicate where it should be inserted.

## A deeper look at the R scripts

The following R scripts are designed to be run indirectly via `batch.sh` but can be run from the command line if needed.

##### makeChartsFromBase.R

This script duplicates an exisiting chart and replaces the data, along with any templated hed, and dek values, publishes each chart, and returns a table containing the public urls. It takes two required arguments and an optional third.

| Parameter       | Description                                                  | Required |
| --------------- | ------------------------------------------------------------ | -------- |
| base_chart_id   | Alphnumeric code of chart to duplicate                       | Yes      |
| "Data/data.csv" | Path to dataset                                              | Yes      |
| group_name      | The name of a new folder to store the charts created in this batch. | No       |
| group_folder_id | The numeric code of an existing folder. Cannot contain non-numeric values, else will be interpreted as `group_name` | No       |

Run script:

```
Rscript scripts/makeChartsFromBase.R base_chart_id "data/data.csv" [group_name|group_folder_id]
```

***

##### makeLocalMapsFromNational.R

This script duplicates an existing map, updates the basemap, along with any templated hed, and dek values, publishes each chart, and returns a table containing the public urls. It takes two required arguments and an option third.

The base chart must include data for the corresponding FIPS codes in the local maps.

| Parameter         | Description                                                  | Required |
| ----------------- | ------------------------------------------------------------ | -------- |
| base_chart_id     | Alphnumeric code of chart to duplicate                       | Yes      |
| "data/locals.csv" | Path to table containing basemap ids                         | Yes      |
| group_name        | The name of a new folder to store the charts created in this batch. | No       |
| group_folder_id   | The numeric code of an existing folder. Cannot contain non-numeric values, else will be interpreted as `group_name` | No       |

Run script:

```
Rscript scripts/makeLocalMapsFromNational.R base_chart_id "data/locals.csv" [group_name|group_folder_id]
```

***

##### deleteChartsInReference.R

This script deletes all of the charts referenced by `chart_id` in a csv file.

Run script:

```
Rscript scripts/deleteChartsInReference.R "./reference_output.csv"
```
