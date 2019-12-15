#!/bin/bash
delete_flag=0
force_flag=0

while getopts "df" opt; do
  case ${opt} in
    d )
      # delete dupes found
      delete_flag=1
      ;;
    f )
      # force delete
      force_flag=1
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

FILES=**/*
CR2=".cr2"
DNG=".dng"
for f in $FILES
do
  if [[ $f = *$DNG ]]; then
    FILENAME="${f/$DNG/''}"
    CR2_FILE="$FILENAME.cr2"
    if [[ -f $CR2_FILE ]]; then
      if [[ $delete_flag -eq 0 ]]; then
        MESSAGE="Found DNG and matching CR2"
      else
        MESSAGE="Deleting DNG that matches existing CR2"
      fi
      printf "\n$MESSAGE\nCR2: ($(stat --printf="%s" $CR2_FILE) bytes) $CR2_FILE\nDNG: ($(stat --printf="%s" $f) bytes) $f"

      if [[ ($(stat --printf="%s" $CR2_FILE) < 10000000) ]]; then
        printf "\nWARNING - CR2 file is smaller than 10MB, it may not be valid! Will skip deletion unless forced"
      fi

      if ( [[ ! $(stat --printf="%s" $CR2_FILE) < 10000000 ]] && [[ $delete_flag -eq 1 ]] ) || [[ $force_flag -eq 1 ]]; then
        rm $f
      elif [[ $delete_flag -eq 1 ]]; then
        printf "\n skipped $f because it's CR2 was under 10MB"
      fi

      printf "\n"
    fi
  fi
done
