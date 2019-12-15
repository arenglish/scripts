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
    CR2_FILE="$FILENAME.cr2"
    if [[ -f $CR2_FILE ]]; then
      if [[ $dry_run_flag -eq 1 ]]; then
        MESSAGE="Found DNG and matching CR2"
      else
        MESSAGE="Deleting DNG that matches existing CR2"
      fi
      printf "\n$MESSAGE\nCR2: $CR2_FILE\nDNG: $f\n"

      if [[ $dry_run_flag -eq 0 ]]; then
        rm $f
      fi
    fi
  fi
done
