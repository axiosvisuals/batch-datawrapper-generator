# batch-datawrapper-generator

This repository contains R scripts for batch chart and map creation using the Datawrapper API via the `DatawRappr` package. While the API does support generating a chart or map from scratch, this workflow assumes you are duplicating an exisiting chart already created in Datawrapper.

A complete list of [DatawRappr functions can be found here](https://munichrocker.github.io/DatawRappr/reference/index.html).

## Requirements

- R, along with `DatawRappr` and `dplyr`
- A [Datwrapper API-token](https://app.datawrapper.de/account/api-tokens)
- The id of the chart you are duplicating

## Getting started

You can either copy this repo using degit and place your data there or simply reference a local versions of the scripts. Note, due to some limited functionality within `DatawRappr`, a few Bash scripts are used to call the API directly, so if you are not copying the entire repo make sure to include these files as well.

The scripts output a csv containing the public urls for each file to your working directory.

### Using degit

`degit` is a package that makes copies of a git repository's most recent commit. This allows for generating the scaffolding from this template directly from the command line. 

Since this is a private repository, you'll need to set up SSH keys with your Github account. More information on how to do that [here](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent).

To install degit: `npm install -g degit` 

To create a new project based on this template using [degit](https://github.com/Rich-Harris/degit):

```bash
npx degit axiosvisuals/batch-datawrapper-generator --mode=git project-name
cd project-name
```
### Demo
You can test out the script with the included dummy data using the following commands. This will duplicate a template chart in the `Axios Visuals/dw auto test` folder in Datawrapper (assuming it wasn't accidentally deleted, update the new charts with the dummy data, and place them in the testing folder.

```
npx degit axiosvisuals/batch-datawrapper-generator --mode=git project-name
cd project-name
Rscript scripts/makeChartFromBase.R mnX0x data/data.csv 76624
```

### Preparing your data

Your data should be formatted the same way as the data in your base chart with the addition of a `series_id` field. This value indicates the group – most likely a local – the row belongs to. The script uses the `series_id` value to split the dataset into chunks.

| series_id | Label    | Men  | Women |
| --------- | -------- | ---- | ----- |
| Group A   | Agree    | 1653 | 858   |
| Group A   | Disagree | 559  | 407   |
| Group B   | Agree    | 819  | 1857  |
| Group B   | Disagree | 815  | 1883  |
| Group C   | Agree    | 1507 | 394   |
| Group C   | Disagree | 266  | 1030  |

### Preparing your base graphic

Copied charts retain any style and textual information, so make sure your base graphic looks the way you want your published versions to appear. If you need to dynamically change the styles of a graphic, add additional arguments to `dw_edit_chart()`  within `deployChart()`.

Using the `series_id` value, the name of the group can be inserted in the graphic's hed and dek. Use `%series_id%` to indicate where it should be inserted.

![alt text](https://user-images.githubusercontent.com/15233857/136981359-a43005e8-b41d-414a-922c-b15af6b9987b.png)

##### Creating localized maps from national map

If you are creating zoomed in versions of a national map, an efficient method is to include the entire national dataset in your base graphic and then instead of updating the data, simply change the basemap id. While every duplicated map will contain the entire dataset, it will only render those with matching FIPS codes. An example of this workflow is in `makeLocalMapsFromNational.R`.

### API token set-up

The first time you use `DatawRappr` you will need to autheniticate your API token. Start an R session either in the terminal or RStudio. Copy the API token [created in Datawrapper]() and use

```R
> library(DatawRappr)
> datawrapper_auth(api_key = "TOKEN")
```

to save the key to your `.Renviron` file. If a key already exists, you may add the argument `overwrite = TRUE ` to `datawrapper_auth()`.

To make sure, your key is working as expected, you can run

```R
> dw_test_key()
```

### Running the scripts

The scripts are designed to be run from the command line <mark>and assume the project folder is the directory</mark>, but can easily be modified to run in RStudio.

***

##### makeChartFromBase.R

This script duplicates an exisiting chart and replaces the data, along with any templated hed, and dek values, publishes each chart, and returns a table containing the public urls. It takes two required arguments and an optional third.

| Parameter          | Description                                                  | Required |
| ------------------ | ------------------------------------------------------------ | -------- |
| base_chart_id      | Alphnumeric code of chart to duplicate                       | Yes      |
| "path/to/data.csv" | Path to dataset                                              | Yes      |
| group_name         | The name of a new folder to store the charts created in this batch. | No       |
| group_folder_id    | The numeric code of an existing folder. Cannot contain non-numeric values, else will be interpreted as `group_name` | No       |

Run script:

```
Rscript scripts/makeChartFromBase.R base_chart_id "path/to/data.csv" [group_name|group_folder_id]
```

***

##### makeLocalMapsFromNational.R

This script duplicates an existing map, updates the basemap, along with any templated hed, and dek values, publishes each chart, and returns a table containing the public urls. It takes two required arguments and an option third.

The base chart must include data for the corresponding FIPS codes in the local maps.

Make a table containing the `series_id` and `basemap_id` for each local. An example at the county level can be found at `data/locals.csv`. To get a table of the basemaps available in Datawrapper, run `dw_basemaps`.

If you need to make a map containing a custom geography, replace `basemap_id` with the chart id of an existing Datawrapper map. The script will then download the custom geojson of the existing map and upload it to the new one. Due to limitations with `DatawRappr`, this process is handled by `updateCustomJSON.sh`. It is possible to upload new geojson files directly with minor modifications to the `updateCustomJSON.sh`.

| Parameter            | Description                                                  | Required |
| -------------------- | ------------------------------------------------------------ | -------- |
| base_chart_id        | Alphnumeric code of chart to duplicate                       | Yes      |
| "path/to/locals.csv" | Path to table containing basemap ids                         | Yes      |
| group_name           | The name of a new folder to store the charts created in this batch. | No       |
| group_folder_id      | The numeric code of an existing folder. Cannot contain non-numeric values, else will be interpreted as `group_name` | No       |

Run script:

```
Rscript scripts/makeLocalMapsFromNational.R base_chart_id "path/to/locals.csv" [group_name|group_folder_id]
```

***

##### deleteChartsInReference.R

This script deletes all of the charts referenced by `chart_id` in a csv file.

Run script:

```
Rscript scripts/deleteChartsInReference.R "path/to/reference_output.csv"
```
