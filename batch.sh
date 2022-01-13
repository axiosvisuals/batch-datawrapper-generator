#!/bin/bash

cd "$(dirname "$0")"
SCRIPTS=("processXls.R" "makeChartsFromBase.R" "makeLocalMapsFromNational.R" "deleteChartsInReference.R")
echo "Which script do you want to run?"
select SCRIPT in "${SCRIPTS[@]}"; do
  if [[ "processXls.R" == "${SCRIPT}" ]]
  then
    Rscript scripts/processXls.R
    break;
  elif [[ "deleteChartsInReference.R" == "${SCRIPT}" ]]
  then
    Rscript scripts/deleteChartsInReference.R "./reference_output.csv"
    break;
  else
    echo "What is the base chart ID?"
    echo -n "Base chart ID: "
    read -r BASE_ID
    echo "What is the folder ID or new folder name?"
    echo -n "Folder ID or name: "
    read -r FOLDER
    case "$SCRIPT" in
      "makeChartsFromBase.R" )
        Rscript scripts/$SCRIPT $BASE_ID "./data/data.csv" $FOLDER
        break;
        ;;
      "makeLocalMapsFromNational.R" )
        Rscript scripts/$SCRIPT $BASE_ID "./data/locals.csv" $FOLDER
        ;;
      * )
        echo "Invalid option. Exiting run."
        break;
        ;;
    esac
  fi
  exit
done
