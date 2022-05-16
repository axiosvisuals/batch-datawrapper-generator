#!/bin/bash

cd "$(dirname "$0")"
SCRIPTS=("downloadSheet.R" "makeChartsFromBase.R" "makeLocalMapsFromNational.R" "makeSymbolMapFromBase.R" "updateChartsInReference.R" "deleteChartsInReference.R")
echo "Which script do you want to run?"
select SCRIPT in "${SCRIPTS[@]}"; do
  if [[ "downloadSheet.R" == "${SCRIPT}" ]]
  then
    echo "What is the Google Sheet ID or url"
    echo -n "ID or url: "
    read -r GID
    Rscript scripts/downloadSheet.R ${GID}
    break;
  elif [[ "deleteChartsInReference.R" == "${SCRIPT}" ]]
  then
    Rscript scripts/deleteChartsInReference.R "./reference_output.csv"
    break;
  elif [[ "updateChartsInReference.R" == "${SCRIPT}" ]]
  then
    Rscript scripts/updateChartsInReference.R
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
        Rscript scripts/publishReferenceSheet.R
        break;
        ;;
      "makeLocalMapsFromNational.R" )
        echo "Do you want to include city labels?"
        echo -n "(y/n): "
        read -r LABELS_BOOL
        Rscript scripts/$SCRIPT $BASE_ID "./data/locals.csv" $FOLDER $LABELS_BOOL
        Rscript scripts/publishReferenceSheet.R
        ;;
      "makeSymbolMapFromBase.R" )
        echo "Do you want to include city labels?"
        echo -n "(y/n): "
        read -r LABELS_BOOL
        Rscript scripts/$SCRIPT $BASE_ID $FOLDER $LABELS_BOOL
        Rscript scripts/publishReferenceSheet.R
        ;;
      * )
        echo "Invalid option. Exiting run."
        break;
        ;;
    esac
  fi
  exit
done
