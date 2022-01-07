#!/bin/bash

cd "$(dirname "$0")"
SCRIPTS=("makeChartFromBase.R" "makeLocalMapsFromNational.R" "deleteChartsInReference.R")
echo "Which script do you want to run?"
select SCRIPT in "${SCRIPTS[@]}"; do
  if [[ "deleteChartsInReference.R" == "${SCRIPT}" ]]
  then
    Rscript scripts/deleteChartsInReference.R "./reference_output.csv"
  else
    echo "What is the base chart ID?"
    echo -n "Base chart ID: "
    read -r BASE_ID
    echo "What is the folder ID or new folder name?"
    echo -n "Folder ID or name: "
    read -r FOLDER
    case "$SCRIPT" in
      "makeChartFromBase.R" )
        Rscript scripts/$SCRIPT $BASE_ID "./data/data.csv" $FOLDER
        ;;
      "makeLocalMapsFromNational.R" )
        Rscript scripts/$SCRIPT $BASE_ID "./data/locals.csv" $FOLDER
        ;;
      * )
        echo "Skip making a local git repo. Don't forget to set one up!"
        ;;
    esac
  fi
done


#
# echo "Where would you like to save your project? Leave blank to store at root."
# echo -n "Directory: "
# read -r path
# echo "What is the project name? Will default to slug if left blank."
# echo -n "Name: "
# read -r name
# [ -z "$name" ] && name=$slug
# read -p "Create local git repo (y/n)? " gitChoiceLocal
# read -p "Create remote git repo (y/n)? Requires GitHub CLI to be installed. " gitChoiceRemote
