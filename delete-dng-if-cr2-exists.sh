#!/bin/bash

FILES=./*
CR2=".cr2"
DNG=".dng"
for f in $FILES
do
  if [[ $f = *$DNG ]]; then
    FILENAME="${f/$DNG/''}"
    if [[ -f "$FILENAME.cr2" ]]; then
      echo "Found DNG that has CR2\nCR2: $FILENAME.cr2\nDNG: $f"
    fi
  fi
done
