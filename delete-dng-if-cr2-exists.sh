#!/bin/bash
dry_run_flag=0

while getopts "d" opt; do
  case ${opt} in
    d )
      # dry run
      dry_run_flag=1
      ;;
    \? )
      echo "Invalid option: $OPTARG" 1>&2
      ;;
    : )
      echo "Invalid option: $OPTARG requires an argument" 1>&2
      ;;
  esac
done
shift $((OPTIND -1))

FILES=./*
CR2=".cr2"
DNG=".dng"
for f in $FILES
do
  if [[ $f = *$DNG ]]; then
    FILENAME="${f/$DNG/''}"
    if [[ -f "$FILENAME.cr2" ]]; then
      if [[ $dry_run_flag -eq 1 ]]; then
        STRING=$"Found DNG that has CR2\nCR2: $FILENAME.cr2\nDNG: $f"
      else
        STRING=$"Deleting DNG that has CR2\nCR2: $FILENAME.cr2\nDNG: $f"
      fi
      echo "$STRING"
    fi
  fi
done
