#!/bin/bash

FILES=./*
CR2=".cr2"
for f in $FILES
do
  if [[ $f = *$CR2 ]]; then
    FILENAME="${f/$CR2/''}"
    echo "Found CR2: $FILENAME"
    if [[ -f "$FILENAME.dng" ]]; then
      echo "Has DNG: $FILENAME.dng"
    fi
  fi
done
