# batch-datawrapper-generator

This repository contains R scripts for batch chart and map creation using the Datawrapper API via the DatawRappr package. While the API does support generating a chart or map from scratch, this workflow assumes you are cloning an exisiting chart already created in Datawrapper.

## Requirements

- R, along with `DatawRappr` and `dplyr`
- A [Datwrapper API-token](https://app.datawrapper.de/account/api-tokens)
- The id of the chart you are cloning

## Getting started

You can either copy this repo using degit and place your data there or simply reference a local version of one of the scripts. Note, due to some limited functionality within `DatawRappr`, a Bash script is executed to call the API directly, so if you are not copying the entire repo make sure to include this file as well.

The script outputs a csv containing the public urls for each file to your working directory. To set the working directory to the script location, run:

```r
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
```

#### Using degit

`degit` is a package that makes copies of a git repository's most recent commit. This allows for generating the scaffolding from this template directly from the command line. 

Since this is a private repository, you'll need to set up SSH keys with your Github account. More information on how to do that [here](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent).

To install degit: `npm install -g degit` 

To create a new project based on this template using [degit](https://github.com/Rich-Harris/degit):

```bash
npx degit axiosvisuals/batch-datawrapper-generator --mode=git project-name
cd project-name
```

#### Preparing your base graphic

#### Preparing your data

Your data should be formatted the same way as the data in your base chart with the addition of a `series_id` field. This value indicates the group or local the row belongs to. The script uses the `series_id` value to split the dataset into chunks.

| series_id | Label    | Men  | Women |
| --------- | -------- | ---- | ----- |
| Group A   | Agree    | 1653 | 858   |
| Group A   | Disagree | 559  | 407   |
| Group B   | Agree    | 819  | 1857  |
| Group B   | Disagree | 815  | 1883  |
| Group C   | Agree    | 1507 | 394   |
| Group C   | Disagree | 266  | 1030  |

#### API token set-up

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

#### Running the scripts

The scripts are designed to be run from the command line but can easily be modified to run in RStudio.

###### makeChartFromBase.R

This script clones an exisiting chart and replaces the data, along with any templated hed, and dek values, publishes each chart, and returns a table containing the public urls. It takes two required arguments and an option third.

| Parameter          | Description                                                  | Required |
| ------------------ | ------------------------------------------------------------ | -------- |
| base_chart_id      | Alphnumeric code of chart to clone                           | Yes      |
| "path/to/data.csv" | Path to dataset                                              | Yes      |
| group_name         | The name of a new folder to store the charts created in this batch. | No       |
| group_folder_id    | The numeric code of an existing folder. Cannot contain non-numeric values, else will be interpreted as `group_name` | No       |

Run script:

```
Rscript makeChartFromBase.R base_chart_id "path/to/data.csv" [group_name|group_folder_id]
```

